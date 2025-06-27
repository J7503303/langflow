"""
sitecustomize.py - Python启动时自动执行
用于在Python进程启动时立即初始化Oracle thick模式
专门解决Oracle 11.2兼容性问题
"""

import os
import sys

def init_oracle_for_11g():
    """在Python启动时初始化Oracle thick模式"""
    try:
        # 设置环境变量
        oracle_home = "/opt/oracle/instantclient_23_4"
        os.environ['ORACLE_HOME'] = oracle_home
        os.environ['LD_LIBRARY_PATH'] = oracle_home + ":" + os.environ.get('LD_LIBRARY_PATH', '')
        os.environ['TNS_ADMIN'] = oracle_home
        
        # 检查Oracle客户端库是否存在
        if os.path.exists(oracle_home):
            # 导入并初始化oracledb thick模式
            try:
                import oracledb
                
                # 检查是否已初始化
                if not hasattr(oracledb, '_langflow_thick_initialized'):
                    oracledb.init_oracle_client(lib_dir=oracle_home)
                    oracledb._langflow_thick_initialized = True
                    print(f"[Oracle] ✅ Thick模式已初始化，支持Oracle 11.2")
                    
            except ImportError:
                # oracledb未安装，忽略
                pass
            except Exception as e:
                # 可能已经初始化，忽略错误
                if "DPI-1047" in str(e):  # 已经初始化的错误
                    print(f"[Oracle] ✅ Thick模式已存在")
                else:
                    print(f"[Oracle] ⚠️ 初始化警告: {e}")
                    
    except Exception as e:
        # 忽略所有错误，不影响正常启动
        pass

# 自动执行初始化
init_oracle_for_11g() 