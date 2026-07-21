#!/bin/bash

# ===========================================
# 学生综合事务中台 - 服务器端一键部署脚本
# ===========================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置变量
DOMAIN="service.huangc.cn"
DEPLOY_DIR="/var/www/$DOMAIN"
APP_DIR="/opt/sap-service"
NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
NGINX_LINK="/etc/nginx/sites-enabled/$DOMAIN"
SERVICE_NAME="sap-gateway"
DB_NAME="sap_system"
DB_USER="sap"
DB_PASS="SAP@2024_secure"

# 打印函数
print_msg() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_step() { echo -e "${CYAN}[→]${NC} $1"; }
print_header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# 检查root权限
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用sudo运行此脚本"
        echo "用法: sudo ./server-deploy.sh"
        exit 1
    fi
}

# 检查并安装依赖
install_dependencies() {
    print_header "检查并安装依赖"

    # 检测包管理器
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt-get"
        PKG_UPDATE="apt-get update"
        PKG_INSTALL="apt-get install -y"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        PKG_UPDATE="yum makecache"
        PKG_INSTALL="yum install -y"
    else
        print_error "不支持的包管理器"
        exit 1
    fi

    # 更新包列表
    print_step "更新软件包列表..."
    $PKG_UPDATE > /dev/null 2>&1

    # 安装Java 17
    if ! command -v java &> /dev/null; then
        print_step "安装Java 17..."
        if [ "$PKG_MANAGER" = "apt-get" ]; then
            $PKG_INSTALL openjdk-17-jre > /dev/null 2>&1
        else
            $PKG_INSTALL java-17-openjdk > /dev/null 2>&1
        fi
        print_msg "Java 17 已安装"
    else
        print_msg "Java 已安装: $(java -version 2>&1 | head -n 1)"
    fi

    # 安装Nginx
    if ! command -v nginx &> /dev/null; then
        print_step "安装Nginx..."
        $PKG_INSTALL nginx > /dev/null 2>&1
        systemctl enable nginx
        systemctl start nginx
        print_msg "Nginx 已安装并启动"
    else
        print_msg "Nginx 已安装"
    fi

    # 安装MySQL
    if ! command -v mysql &> /dev/null; then
        print_step "安装MySQL..."
        if [ "$PKG_MANAGER" = "apt-get" ]; then
            # 设置非交互模式
            export DEBIAN_FRONTEND=noninteractive
            $PKG_INSTALL mysql-server > /dev/null 2>&1
        else
            $PKG_INSTALL mysql-server > /dev/null 2>&1
        fi
        systemctl enable mysql
        systemctl start mysql
        print_msg "MySQL 已安装并启动"
    else
        print_msg "MySQL 已安装"
    fi

    # 安装Redis
    if ! command -v redis-server &> /dev/null && ! command -v redis &> /dev/null; then
        print_step "安装Redis..."
        $PKG_INSTALL redis-server > /dev/null 2>&1 || $PKG_INSTALL redis > /dev/null 2>&1
        systemctl enable redis-server 2>/dev/null || systemctl enable redis 2>/dev/null
        systemctl start redis-server 2>/dev/null || systemctl start redis 2>/dev/null
        print_msg "Redis 已安装并启动"
    else
        print_msg "Redis 已安装"
    fi
}

# 配置MySQL数据库
setup_database() {
    print_header "配置MySQL数据库"

    # 检查MySQL是否运行
    if ! systemctl is-active --quiet mysql && ! systemctl is-active --quiet mysqld; then
        print_step "启动MySQL..."
        systemctl start mysql 2>/dev/null || systemctl start mysqld 2>/dev/null
        sleep 3
    fi

    # 创建数据库和用户
    print_step "创建数据库和用户..."
    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE DATABASE IF NOT EXISTS sap_volunteer CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE DATABASE IF NOT EXISTS sap_workstudy CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON sap_*.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

    if [ $? -eq 0 ]; then
        print_msg "数据库创建成功"
    else
        print_warn "数据库可能已存在，继续..."
    fi

    # 导入SQL文件
    print_step "导入数据库结构..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [ -f "$SCRIPT_DIR/sql/sap_system.sql" ]; then
        mysql -u root $DB_NAME < "$SCRIPT_DIR/sql/sap_system.sql" 2>/dev/null || true
        print_msg "系统数据库已导入"
    fi

    if [ -f "$SCRIPT_DIR/sql/sap_volunteer.sql" ]; then
        mysql -u root sap_volunteer < "$SCRIPT_DIR/sql/sap_volunteer.sql" 2>/dev/null || true
        print_msg "志愿服务数据库已导入"
    fi

    if [ -f "$SCRIPT_DIR/sql/sap_workstudy.sql" ]; then
        mysql -u root sap_workstudy < "$SCRIPT_DIR/sql/sap_workstudy.sql" 2>/dev/null || true
        print_msg "勤工助学数据库已导入"
    fi
}

# 部署后端
deploy_backend() {
    print_header "部署后端服务"

    # 创建目录
    mkdir -p $APP_DIR
    mkdir -p $APP_DIR/logs

    # 停止现有服务
    if systemctl is-active --quiet $SERVICE_NAME 2>/dev/null; then
        print_step "停止现有服务..."
        systemctl stop $SERVICE_NAME
    fi

    # 复制JAR文件
    print_step "复制后端文件..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cp "$SCRIPT_DIR/sap-gateway/sap-gateway.jar" $APP_DIR/

    # 设置权限
    chown -R www-data:www-data $APP_DIR

    print_msg "后端文件部署完成"
}

# 部署前端
deploy_frontend() {
    print_header "部署前端文件"

    # 创建目录
    mkdir -p $DEPLOY_DIR
    mkdir -p $DEPLOY_DIR/dist

    # 复制前端文件
    print_step "复制前端文件..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cp -r "$SCRIPT_DIR/frontend/"* $DEPLOY_DIR/dist/

    # 设置权限
    chown -R www-data:www-data $DEPLOY_DIR

    print_msg "前端文件部署完成"
}

# 配置Nginx
setup_nginx() {
    print_header "配置Nginx"

    # 复制配置文件
    print_step "配置Nginx..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cp "$SCRIPT_DIR/config/nginx.conf" $NGINX_CONF

    # 修改配置文件中的路径
    sed -i "s|/var/www/service.huangc.cn|$DEPLOY_DIR|g" $NGINX_CONF

    # 创建软链接
    if [ ! -L "$NGINX_LINK" ]; then
        ln -s $NGINX_CONF $NGINX_LINK
    fi

    # 删除默认配置（如果存在）
    rm -f /etc/nginx/sites-enabled/default

    # 测试配置
    print_step "测试Nginx配置..."
    if nginx -t 2>&1; then
        print_msg "Nginx配置测试通过"
        systemctl reload nginx
        print_msg "Nginx已重载"
    else
        print_error "Nginx配置测试失败"
        nginx -t
        exit 1
    fi
}

# 配置systemd服务
setup_service() {
    print_header "配置systemd服务"

    # 复制service文件
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cp "$SCRIPT_DIR/config/sap-gateway.service" /etc/systemd/system/

    # 修改service文件中的路径
    sed -i "s|/opt/sap-service|$APP_DIR|g" /etc/systemd/system/sap-gateway.service

    # 重新加载systemd
    systemctl daemon-reload

    # 启用服务
    systemctl enable $SERVICE_NAME

    print_msg "服务配置完成"
}

# 启动服务
start_services() {
    print_header "启动服务"

    # 启动后端
    print_step "启动后端服务..."
    systemctl start $SERVICE_NAME
    sleep 5

    # 检查服务状态
    if systemctl is-active --quiet $SERVICE_NAME; then
        print_msg "后端服务启动成功"
    else
        print_error "后端服务启动失败"
        print_step "查看日志: journalctl -u $SERVICE_NAME -n 50"
        journalctl -u $SERVICE_NAME -n 20 --no-pager
        exit 1
    fi

    # 确保Nginx运行
    if ! systemctl is-active --quiet nginx; then
        systemctl start nginx
    fi
    print_msg "Nginx运行正常"
}

# 验证部署
verify_deployment() {
    print_header "验证部署"

    local all_ok=true

    # 检查Nginx
    if systemctl is-active --quiet nginx; then
        print_msg "Nginx: 运行中"
    else
        print_error "Nginx: 未运行"
        all_ok=false
    fi

    # 检查后端
    if systemctl is-active --quiet $SERVICE_NAME; then
        print_msg "后端服务: 运行中"
    else
        print_error "后端服务: 未运行"
        all_ok=false
    fi

    # 检查端口
    if ss -tln | grep -q ":80 "; then
        print_msg "端口80: 已监听"
    else
        print_warn "端口80: 未监听"
    fi

    if ss -tln | grep -q ":8080 "; then
        print_msg "端口8080: 已监听"
    else
        print_warn "端口8080: 未监听"
    fi

    # 测试HTTP访问
    print_step "测试HTTP访问..."
    if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "200"; then
        print_msg "HTTP访问: 正常"
    else
        print_warn "HTTP访问: 可能需要等待几秒"
    fi

    echo ""
    if [ "$all_ok" = true ]; then
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}  ✅ 部署成功！${NC}"
        echo -e "${GREEN}========================================${NC}"
    else
        echo -e "${YELLOW}========================================${NC}"
        echo -e "${YELLOW}  ⚠️  部署完成，但有警告${NC}"
        echo -e "${YELLOW}========================================${NC}"
    fi

    echo ""
    echo "访问地址: http://$DOMAIN"
    echo ""
    echo "默认账号:"
    echo "  管理员: admin / admin123"
    echo "  学生: student / admin123"
    echo ""
    echo "常用命令:"
    echo "  查看后端日志: journalctl -u $SERVICE_NAME -f"
    echo "  重启后端: sudo systemctl restart $SERVICE_NAME"
    echo "  重载Nginx: sudo systemctl reload nginx"
    echo "  查看Nginx日志: tail -f /var/log/nginx/${DOMAIN}.access.log"
    echo ""
}

# 主流程
main() {
    print_header "学生综合事务中台 - 一键部署脚本"

    check_root
    install_dependencies
    setup_database
    deploy_backend
    deploy_frontend
    setup_nginx
    setup_service
    start_services
    verify_deployment
}

# 执行
main "$@"
