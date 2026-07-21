# 学生综合事务中台 - 部署指南

## 📋 部署前准备

### 服务器要求
- Linux (Ubuntu 20.04+ / CentOS 7+)
- Java 17+
- MySQL 8.0+
- Redis 7.x
- Nginx

### 域名配置
- 主域名: huangc.cn
- 子域名: service.huangc.cn (已解析到服务器IP)

---

## 🚀 快速部署

### 1. 本地构建

在您的开发机上执行：

```bash
# 进入项目目录
cd C:/Users/Huangc/Vibe-code-project/student-affairs-platform

# 构建后端（需要Java 17+和Maven）
mvn clean package -DskipTests

# 构建前端
cd sap-admin-ui
npm install
npm run build
cd ..
```

### 2. 上传文件到服务器

使用SCP或SFTP上传整个项目目录：

```bash
# 使用scp上传（在本地执行）
scp -r student-affairs-platform user@your-server-ip:/tmp/

# 或者只上传必要文件
scp sap-gateway/target/sap-gateway.jar user@your-server-ip:/tmp/
scp -r sap-admin-ui/dist user@your-server-ip:/tmp/
```

### 3. 在服务器上执行部署

```bash
# 登录服务器
ssh user@your-server-ip

# 进入上传目录
cd /tmp/student-affairs-platform

# 给部署脚本执行权限
chmod +x deploy/deploy.sh

# 执行部署（需要sudo权限）
sudo ./deploy/deploy.sh
```

---

## 🔧 手动部署（如果自动脚本有问题）

### 步骤1: 安装依赖

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install -y nginx openjdk-17-jre mysql-server redis-server

# CentOS/RHEL
sudo yum install -y nginx java-17-openjdk mysql-server redis
```

### 步骤2: 配置MySQL

```bash
# 登录MySQL
sudo mysql -u root

# 创建数据库和用户
CREATE DATABASE sap_system CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE DATABASE sap_volunteer CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER 'sap'@'localhost' IDENTIFIED BY 'your_strong_password';
GRANT ALL PRIVILEGES ON sap_*.* TO 'sap'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# 导入数据库
mysql -u sap -p sap_system < sql/sap_system.sql
mysql -u sap -p sap_volunteer < sql/sap_volunteer.sql
```

### 步骤3: 配置Redis

```bash
# 编辑Redis配置
sudo nano /etc/redis/redis.conf

# 确保以下配置：
# bind 127.0.0.1
# requirepass 留空（本地访问不需要密码）

# 重启Redis
sudo systemctl restart redis
```

### 步骤4: 部署后端

```bash
# 创建目录
sudo mkdir -p /opt/sap-service/logs
sudo chown -R www-data:www-data /opt/sap-service

# 复制JAR文件
sudo cp sap-gateway/target/sap-gateway.jar /opt/sap-service/

# 复制生产环境配置
sudo cp docker/application-prod.yml /opt/sap-service/

# 配置systemd服务
sudo cp deploy/sap-gateway.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable sap-gateway
sudo systemctl start sap-gateway
```

### 步骤5: 部署前端

```bash
# 创建目录
sudo mkdir -p /var/www/service.huangc.cn/dist
sudo chown -R www-data:www-data /var/www/service.huangc.cn

# 复制前端文件
sudo cp -r sap-admin-ui/dist/* /var/www/service.huangc.cn/dist/
```

### 步骤6: 配置Nginx

```bash
# 复制Nginx配置
sudo cp deploy/nginx.conf /etc/nginx/sites-available/service.huangc.cn

# 创建软链接
sudo ln -s /etc/nginx/sites-available/service.huangc.cn /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重载Nginx
sudo systemctl reload nginx
```

---

## 🔍 验证部署

### 检查服务状态

```bash
# 检查后端服务
sudo systemctl status sap-gateway

# 检查Nginx
sudo systemctl status nginx

# 检查端口监听
sudo ss -tln | grep -E ':(80|8080) '
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

### 访问测试

1. 打开浏览器访问: http://service.huangc.cn
2. 使用默认账号登录:
   - 管理员: admin / admin123
   - 学生: student / admin123

---

## 🛠️ 常见问题

### 1. 端口被占用

```bash
# 查找占用端口的进程
sudo lsof -i :8080

# 停止进程
sudo kill -9 <PID>
```

### 2. 权限问题

```bash
# 修复目录权限
sudo chown -R www-data:www-data /var/www/service.huangc.cn
sudo chown -R www-data:www-data /opt/sap-service
```

### 3. Java版本问题

```bash
# 检查Java版本
java -version

# 如果不是17，安装Java 17
sudo apt install openjdk-17-jre
```

### 4. Nginx 502错误

```bash
# 检查后端是否运行
sudo systemctl status sap-gateway

# 检查端口是否监听
sudo ss -tln | grep :8080

# 查看Nginx错误日志
sudo tail -f /var/log/nginx/service.huangc.cn.error.log
```

### 5. 数据库连接失败

```bash
# 检查MySQL是否运行
sudo systemctl status mysql

# 测试数据库连接
mysql -u sap -p -h localhost
```

---

## 📝 更新部署

当需要更新代码时：

```bash
# 1. 在本地重新构建
mvn clean package -DskipTests
cd sap-admin-ui && npm run build && cd ..

# 2. 上传新文件到服务器
scp sap-gateway/target/sap-gateway.jar user@server:/tmp/
scp -r sap-admin-ui/dist user@server:/tmp/

# 3. 在服务器上更新
sudo systemctl stop sap-gateway
sudo cp /tmp/sap-gateway.jar /opt/sap-service/
sudo cp -r /tmp/dist/* /var/www/service.huangc.cn/dist/
sudo systemctl start sap-gateway
sudo systemctl reload nginx
```

---

## 🔒 安全建议

1. **修改默认密码**: 部署后立即修改管理员密码
2. **配置HTTPS**: 使用Let's Encrypt配置SSL证书
3. **限制端口**: 使用防火墙只开放80和443端口
4. **定期备份**: 定期备份数据库和上传文件
5. **日志监控**: 定期检查日志文件

---

## 📞 技术支持

如遇到问题，请检查：
1. 本文档的常见问题部分
2. 服务器日志文件
3. 项目GitHub Issues
