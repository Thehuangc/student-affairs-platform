# ===========================================
# 学生综合事务中台 - PowerShell 部署脚本
# ===========================================

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  学生综合事务中台 - 构建部署包" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 设置控制台编码
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 检查Java
Write-Host "[1/6] 检查Java环境..." -ForegroundColor Green
try {
    $javaVersion = java -version 2>&1 | Select-String "version"
    Write-Host "✓ Java已安装: $javaVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ 错误: 未找到Java，请安装Java 17+" -ForegroundColor Red
    Read-Host "按Enter键退出"
    exit 1
}

# 检查Maven
Write-Host "[2/6] 检查Maven环境..." -ForegroundColor Green
try {
    $mvnVersion = mvn -version 2>&1 | Select-String "Maven"
    Write-Host "✓ Maven已安装: $mvnVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ 错误: 未找到Maven，请安装Maven" -ForegroundColor Red
    Read-Host "按Enter键退出"
    exit 1
}

# 检查Node.js
Write-Host "[3/6] 检查Node.js环境..." -ForegroundColor Green
try {
    $nodeVersion = node -v
    Write-Host "✓ Node.js已安装: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "✗ 错误: 未找到Node.js，请安装Node.js 18+" -ForegroundColor Red
    Read-Host "按Enter键退出"
    exit 1
}

# 构建后端
Write-Host "[4/6] 构建后端项目..." -ForegroundColor Green
Set-Location $PSScriptRoot
Write-Host "执行: mvn clean package -DskipTests" -ForegroundColor Yellow
mvn clean package -DskipTests
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ 后端构建失败" -ForegroundColor Red
    Read-Host "按Enter键退出"
    exit 1
}
Write-Host "✓ 后端构建完成" -ForegroundColor Green

# 构建前端
Write-Host "[5/6] 构建前端项目..." -ForegroundColor Green
Set-Location "$PSScriptRoot\sap-admin-ui"
Write-Host "执行: npm install" -ForegroundColor Yellow
npm install
Write-Host "执行: npm run build" -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "✗ 前端构建失败" -ForegroundColor Red
    Read-Host "按Enter键退出"
    exit 1
}
Write-Host "✓ 前端构建完成" -ForegroundColor Green

# 创建部署包
Write-Host "[6/6] 创建部署包..." -ForegroundColor Green
Set-Location $PSScriptRoot

# 创建目录结构
$deployDir = "$PSScriptRoot\deploy-package"
if (Test-Path $deployDir) {
    Remove-Item -Recurse -Force $deployDir
}
New-Item -ItemType Directory -Path $deployDir -Force | Out-Null
New-Item -ItemType Directory -Path "$deployDir\sap-gateway" -Force | Out-Null
New-Item -ItemType Directory -Path "$deployDir\frontend" -Force | Out-Null
New-Item -ItemType Directory -Path "$deployDir\config" -Force | Out-Null
New-Item -ItemType Directory -Path "$deployDir\sql" -Force | Out-Null

# 复制文件
Write-Host "复制后端JAR..." -ForegroundColor Yellow
Copy-Item "$PSScriptRoot\sap-gateway\target\sap-gateway.jar" "$deployDir\sap-gateway\" -Force

Write-Host "复制前端文件..." -ForegroundColor Yellow
Copy-Item "$PSScriptRoot\sap-admin-ui\dist\*" "$deployDir\frontend\" -Recurse -Force

Write-Host "复制配置文件..." -ForegroundColor Yellow
Copy-Item "$PSScriptRoot\deploy\nginx.conf" "$deployDir\config\" -Force
Copy-Item "$PSScriptRoot\deploy\sap-gateway.service" "$deployDir\config\" -Force
Copy-Item "$PSScriptRoot\docker\application-prod.yml" "$deployDir\config\" -Force

Write-Host "复制SQL文件..." -ForegroundColor Yellow
Copy-Item "$PSScriptRoot\sql\*.sql" "$deployDir\sql\" -Force

Write-Host "复制部署脚本..." -ForegroundColor Yellow
Copy-Item "$PSScriptRoot\deploy\server-deploy.sh" "$deployDir\" -Force

Write-Host "✓ 部署包创建完成" -ForegroundColor Green

# 显示完成信息
Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  ✅ 构建完成！" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "部署包位置:" -ForegroundColor White
Write-Host "  $deployDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "接下来的步骤:" -ForegroundColor White
Write-Host ""
Write-Host "  1. 将 deploy-package 文件夹上传到服务器的 /tmp/ 目录" -ForegroundColor Cyan
Write-Host "     可以使用 WinSCP、FileZilla 等工具" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. SSH登录服务器，执行以下命令:" -ForegroundColor Cyan
Write-Host "     cd /tmp/deploy-package" -ForegroundColor Yellow
Write-Host "     chmod +x server-deploy.sh" -ForegroundColor Yellow
Write-Host "     sudo ./server-deploy.sh" -ForegroundColor Yellow
Write-Host ""
Write-Host "  3. 等待脚本执行完成，访问 http://service.huangc.cn" -ForegroundColor Cyan
Write-Host ""
Read-Host "按Enter键退出"
