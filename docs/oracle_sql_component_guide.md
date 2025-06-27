# Oracle SQL查询组件使用指南

本指南说明如何在Langflow中使用SQL Database组件连接和查询Oracle数据库。

## 📋 前提条件

1. Oracle数据库服务器（本地或远程）
2. 有效的Oracle数据库用户凭据
3. Langflow Docker环境（已包含Oracle驱动）

## 🔧 SQL Database组件配置

### 1. 基本连接配置

在Langflow的**SQL Database**组件中配置以下参数：

#### Database URL格式
```
oracle+oracledb://用户名:密码@主机:端口/服务名
```

#### 实际示例
```
oracle+oracledb://scott:tiger@localhost:1521/ORCLPDB
oracle+oracledb://hr:password@192.168.1.100:1521/XE
oracle+oracledb://appuser:secret@oracle.company.com:1521/PROD
```

### 2. 支持的连接方式

#### 标准连接
```
oracle+oracledb://username:password@hostname:port/service_name
```

#### 使用SID连接
```
oracle+oracledb://username:password@hostname:port/?service_name=SID
```

#### TNS连接（如果有tnsnames.ora）
```
oracle+oracledb://username:password@tns_alias
```

#### Oracle Autonomous Database连接
```python
# 如果使用钱包文件，需要在连接字符串中指定额外参数
# 这种情况可能需要自定义组件
oracle+oracledb://username:password@hostname:port/service_name
```

## 📝 SQL查询示例

### 基本查询
```sql
SELECT employee_id, first_name, last_name, salary 
FROM employees 
WHERE department_id = 10
ORDER BY salary DESC;
```

### Oracle特定功能
```sql
-- 使用Oracle的ROWNUM
SELECT * FROM (
    SELECT employee_id, first_name, last_name, salary,
           ROW_NUMBER() OVER (ORDER BY salary DESC) as rn
    FROM employees
) WHERE rn <= 10;

-- 使用Oracle日期函数
SELECT 
    employee_id,
    hire_date,
    MONTHS_BETWEEN(SYSDATE, hire_date) as months_employed
FROM employees
WHERE hire_date > DATE '2020-01-01';

-- 使用Oracle的CONNECT BY（层次查询）
SELECT employee_id, manager_id, first_name, last_name,
       LEVEL as hierarchy_level,
       SYS_CONNECT_BY_PATH(first_name, '/') as path
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY first_name;
```

### JSON查询（Oracle 12c+）
```sql
-- 查询JSON数据
SELECT 
    employee_id,
    JSON_VALUE(employee_data, '$.address.city') as city,
    JSON_VALUE(employee_data, '$.skills[0]') as primary_skill
FROM employee_profiles
WHERE JSON_EXISTS(employee_data, '$.certifications');
```

### 分析函数
```sql
-- 使用Oracle分析函数
SELECT 
    department_id,
    employee_id,
    salary,
    AVG(salary) OVER (PARTITION BY department_id) as dept_avg_salary,
    RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) as salary_rank
FROM employees;
```

## 🛠️ 使用步骤

### 1. 添加SQL Database组件
1. 在Langflow画布中搜索"SQL Database"
2. 拖拽到画布上

### 2. 配置连接
1. 在**Database URL**字段输入Oracle连接字符串
2. 在**SQL Query**字段输入您的查询语句
3. 配置其他选项：
   - **Include Columns**: 是否包含列名（推荐开启）
   - **Add Error**: 是否在出错时包含错误信息

### 3. 连接到其他组件
- **输入**: 可以从其他组件接收查询参数
- **输出**: 返回DataFrame格式的查询结果

## 📊 输出格式

SQL Database组件返回DataFrame格式的数据，包含：
- 查询结果的所有行和列
- 列名信息（如果启用）
- 数据类型自动转换

## ⚡ 性能优化

### 1. 查询优化
```sql
-- 使用索引提示
SELECT /*+ INDEX(e emp_name_idx) */ 
    employee_id, first_name, last_name
FROM employees e
WHERE last_name = 'Smith';

-- 使用绑定变量（在动态查询中）
SELECT * FROM employees 
WHERE salary > :min_salary
AND department_id = :dept_id;
```

### 2. 分页查询
```sql
-- Oracle 12c+ 分页
SELECT employee_id, first_name, last_name
FROM employees
ORDER BY employee_id
OFFSET 0 ROWS FETCH NEXT 50 ROWS ONLY;

-- 传统分页方式
SELECT * FROM (
    SELECT a.*, ROWNUM rnum FROM (
        SELECT employee_id, first_name, last_name
        FROM employees
        ORDER BY employee_id
    ) a WHERE ROWNUM <= 100
) WHERE rnum >= 51;
```

## 🚨 常见错误处理

### 1. 连接错误
```
错误: Cannot connect to Oracle database
解决: 检查数据库URL、用户名、密码和网络连接
```

### 2. SQL语法错误
```
错误: ORA-00942: table or view does not exist
解决: 检查表名和模式名，确保用户有访问权限
```

### 3. 权限错误
```
错误: ORA-00942: insufficient privileges
解决: 联系DBA授予必要的权限
```

## 🔐 安全建议

1. **不要在组件中硬编码密码**
   - 使用环境变量或安全配置
   - 考虑使用Oracle Wallet

2. **使用最小权限原则**
   - 为应用创建专用数据库用户
   - 只授予必要的权限

3. **启用网络加密**
   - 在生产环境中使用SSL/TLS

## 📈 监控和调试

### 1. 启用详细日志
在Langflow日志中查看详细的数据库连接和查询信息

### 2. 查询性能监控
```sql
-- 查看执行计划
EXPLAIN PLAN FOR
SELECT * FROM employees WHERE department_id = 10;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
```

### 3. 连接池监控
- 监控活动连接数
- 关注连接等待时间

## 🔗 相关资源

- [Oracle SQL参考文档](https://docs.oracle.com/en/database/oracle/oracle-database/19/sqlrf/)
- [python-oracledb文档](https://python-oracledb.readthedocs.io/)
- [SQLAlchemy Oracle方言](https://docs.sqlalchemy.org/en/14/dialects/oracle.html)

## 💡 高级技巧

### 1. 动态查询构建
您可以连接其他Langflow组件来动态构建查询：

```
Text Input → Python Code → SQL Database
```

### 2. 结果后处理
将SQL查询结果连接到其他组件进行进一步处理：

```
SQL Database → Python Code → Chart Display
```

### 3. 错误处理流程
设计错误处理流程来优雅地处理数据库连接问题。 