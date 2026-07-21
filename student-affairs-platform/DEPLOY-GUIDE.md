# 🚀 部署指南 - 三步完成

## 准备工作

确保您的电脑已安装：
- Java 17+
- Maven 3.8+
- Node.js 18+

---

## 第一步：本地构建

### Windows用户（推荐）

**方法A：使用PowerShell（推荐）**
```powershell
# 右键点击 PowerShell 脚本，选择"使用 PowerShell 运行"
# 或者在终端中执行：
.\deploy.ps1
```

**方法B：使用批处理**
```cmd
# 双击运行 deploy-locally.bat
# 或者在CMD中执行：
deploy-locally.bat
```

### Mac/Linux用户

```bash
# 在项目目录执行
chmod +x deploy-locally.sh
./deploy-locally.sh
```

构建完成后，会生成 `deploy-package` 文件夹。

---

## 第二步：上传到服务器

使用以下任一工具上传 `deploy-package` 文件夹到服务器的 `/tmp/` 目录：

### 推荐工具

1. **WinSCP**（Windows）
   - 下载：https://winscp.net/
   - 连接到服务器
   - 将 `deploy-package` 拖拽到 `/tmp/` 目录

2. **FileZilla**（跨平台）
   - 下载：https://filezilla-project.org/
   - 连接到服务器
   - 上传 `deploy-package` 到 `/tmp/`

3. **SCP命令**（命令行）
   ```bash
   scp -r deploy-package user@your-server-ip:/tmp/
   ```

4. **宝塔面板**（如果有）
   - 登录宝塔面板
   - 使用文件管理器上传

---

## 第三步：在服务器上执行部署

### 1. SSH登录服务器

```bash
ssh user@your-server-ip
```

### 2. 进入部署目录

```bash
cd /tmp/deploy-package
```

### 3. 执行部署脚本

```bash
# 给脚本执行权限
chmod +x server-deploy.sh

# 执行部署（需要sudo权限）
sudo ./server-deploy.sh
```

### 4. 等待完成

脚本会自动：
- ✅ 安装依赖（Java、Nginx、MySQL、Redis）
- ✅ 配置数据库
- ✅ 部署后端服务
- ✅ 部署前端文件
- ✅ 配置Nginx
- ✅ 启动所有服务

---

## 部署完成

### 访问地址

🌐 **http://service.huangc.cn**

### 默认账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |
| 学生 | student | admin123 |
| 教师 | teacher | admin123 |

---

## 常用命令

### 查看服务状态

```bash
# 查看后端服务状态
sudo systemctl status sap-gateway

# 查看Nginx状态
sudo systemctl status nginx
```

### 查看日志

```bash
# 后端服务日志
sudo journalctl -u sap-gateway -f

# Nginx访问日志
sudo tail -f /var/log/nginx/service.huangc.cn.access.log

# Nginx错误日志
sudo tail -f /var/log/nginx/service.huangc.cn.error.log
```

### 重启服务

```bash
# 重启后端
sudo systemctl restart sap-gateway

# 重载Nginx配置
sudo systemctl reload nginx
```

---

## 常见问题

### 1. 端口被占用

```bash
# 查找占用8080端口的进程
sudo lsof -i :8080

# 停止进程
sudo kill -9 <进程ID>
```

### 2. 数据库连接失败

```bash
# 检查MySQL是否运行
sudo systemctl status mysql

# 重启MySQL
sudo systemctl restart mysql
```

### 3. Nginx 502错误

```bash
# 检查后端是否运行
sudo systemctl status sap-gateway

# 查看后端日志
sudo journalctl -u sap-gateway -n 50
```

### 4. 权限问题

```bash
# 修复目录权限
sudo chown -R www-data:www-data /var/www/service.huangc.cn
sudo chown -R www-data:www-data /opt/sap-service
```

---

## 更新部署

当需要更新代码时：

```bash
# 1. 本地重新构建（执行第一步）
# 2. 上传新的 deploy-package 到服务器（覆盖旧的）
# 3. 在服务器上执行：
cd /tmp/deploy-package
sudo ./server-deploy.sh
```

---

## 安全建议

1. **修改默认密码**：部署后立即修改管理员密码
2. **配置HTTPS**：使用Let's Encrypt配置SSL证书
3. **限制端口**：使用防火墙只开放80和443端口
4. **定期备份**：定期备份数据库

---

## 需要帮助？

如果遇到问题，请提供：
1. 错误信息截图
2. 执行的命令
3. 日志内容

---

**祝部署顺利！** 🎉
