@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo ==========================================
echo   学生综合事务中台 - 本地构建脚本
echo ==========================================
echo.

REM 设置颜色
set "GREEN=[92m"
set "YELLOW=[93m"
set "RED=[91m"
set "NC=[0m"

REM 检查Java
echo %GREEN%[1/6] 检查Java环境...%NC%
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%错误: 未找到Java，请安装Java 17+%NC%
    pause
    exit /b 1
)
echo %GREEN%✓ Java环境正常%NC%

REM 检查Maven
echo %GREEN%[2/6] 检查Maven环境...%NC%
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%错误: 未找到Maven，请安装Maven%NC%
    pause
    exit /b 1
)
echo %GREEN%✓ Maven环境正常%NC%

REM 检查Node.js
echo %GREEN%[3/6] 检查Node.js环境...%NC%
node -v >nul 2>&1
if %errorlevel% neq 0 (
    echo %RED%错误: 未找到Node.js，请安装Node.js 18+%NC%
    pause
    exit /b 1
)
echo %GREEN%✓ Node.js环境正常%NC%

REM 构建后端
echo %GREEN%[4/6] 构建后端项目...%NC%
cd /d "%~dp0"
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo %RED%后端构建失败%NC%
    pause
    exit /b 1
)
echo %GREEN%✓ 后端构建完成%NC%

REM 构建前端
echo %GREEN%[5/6] 构建前端项目...%NC%
cd /d "%~dp0sap-admin-ui"
call npm install
call npm run build
if %errorlevel% neq 0 (
    echo %RED%前端构建失败%NC%
    pause
    exit /b 1
)
echo %GREEN%✓ 前端构建完成%NC%

REM 创建部署包
echo %GREEN%[6/6] 创建部署包...%NC%
cd /d "%~dp0"
if not exist "deploy-package" mkdir deploy-package
if not exist "deploy-package\sap-gateway" mkdir deploy-package\sap-gateway
if not exist "deploy-package\frontend" mkdir deploy-package\frontend
if not exist "deploy-package\config" mkdir deploy-package\config
if not exist "deploy-package\sql" mkdir deploy-package\sql

REM 复制后端JAR
copy /Y sap-gateway\target\sap-gateway.jar deploy-package\sap-gateway\ >nul

REM 复制前端文件
xcopy /E /I /Y sap-admin-ui\dist\* deploy-package\frontend\ >nul

REM 复制配置文件
copy /Y deploy\nginx.conf deploy-package\config\ >nul
copy /Y deploy\sap-gateway.service deploy-package\config\ >nul
copy /Y docker\application-prod.yml deploy-package\config\ >nul

REM 复制SQL文件
copy /Y sql\*.sql deploy-package\sql\ >nul

REM 复制部署脚本
copy /Y deploy\server-deploy.sh deploy-package\ >nul

echo %GREEN%✓ 部署包创建完成%NC%

echo.
echo ==========================================
echo %GREEN%构建完成！%NC%
echo ==========================================
echo.
echo 部署包位置: %~dp0deploy-package
echo.
echo 接下来的步骤:
echo   1. 将 deploy-package 文件夹上传到服务器的 /tmp/ 目录
echo   2. 在服务器上执行: cd /tmp/deploy-package ^&^& chmod +x server-deploy.sh ^&^& sudo ./server-deploy.sh
echo.
pause
