#!/bin/bash

# ===========================================
# 学生综合事务中台 - 部署脚本
# ===========================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 配置变量
DEPLOY_DIR="/var/www/service.huangc.cn"
APP_DIR="/opt/sap-service"
NGINX_CONF="/etc/nginx/sites-available/service.huangc.cn"
NGINX_LINK="/etc/nginx/sites-enabled/service.huangc.cn"
SERVICE_NAME="sap-gateway"

# 打印带颜色的消息
print_msg() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "请使用sudo运行此脚本"
        exit 1
    fi
}

# 步骤1: 创建目录
create_directories() {
    print_msg "创建部署目录..."
    mkdir -p $DEPLOY_DIR/dist
    mkdir -p $APP_DIR
    mkdir -p $APP_DIR/logs
    chown -R www-data:www-data $DEPLOY_DIR
    chown -R www-data:www-data $APP_DIR
    print_msg "目录创建完成"
}

# 步骤2: 部署前端
deploy_frontend() {
    print_msg "部署前端文件..."

    # 检查前端构建文件是否存在
    if [ ! -d "./sap-admin-ui/dist" ]; then
        print_error "前端构建文件不存在，请先在本地执行 npm run build"
        exit 1
    fi

    # 备份旧文件
    if [ -d "$DEPLOY_DIR/dist" ]; then
        cp -r $DEPLOY_DIR/dist $DEPLOY_DIR/dist_backup_$(date +%Y%m%d_%H%M%S)
    fi

    # 复制新文件
    cp -r ./sap-admin-ui/dist/* $DEPLOY_DIR/dist/
    chown -R www-data:www-data $DEPLOY_DIR/dist
    print_msg "前端部署完成"
}

# 步骤3: 部署后端
deploy_backend() {
    print_msg "部署后端服务..."

    # 检查JAR文件是否存在
    if [ ! -f "./sap-gateway/target/sap-gateway.jar" ]; then
        print_error "后端JAR文件不存在，请先执行 mvn clean package"
        exit 1
    fi

    # 停止现有服务
    if systemctl is-active --quiet $SERVICE_NAME; then
        print_msg "停止现有服务..."
        systemctl stop $SERVICE_NAME
    fi

    # 备份旧JAR
    if [ -f "$APP_DIR/sap-gateway.jar" ]; then
        cp $APP_DIR/sap-gateway.jar $APP_DIR/sap-gateway.jar.bak_$(date +%Y%m%d_%H%M%S)
    fi

    # 复制新JAR
    cp ./sap-gateway/target/sap-gateway.jar $APP_DIR/
    chown www-data:www-data $APP_DIR/sap-gateway.jar

    print_msg "后端部署完成"
}

# 步骤4: 配置Nginx
setup_nginx() {
    print_msg "配置Nginx..."

    # 复制Nginx配置
    cp ./deploy/nginx.conf $NGINX_CONF

    # 创建软链接（如果不存在）
    if [ ! -L "$NGINX_LINK" ]; then
        ln -s $NGINX_CONF $NGINX_LINK
    fi

    # 测试Nginx配置
    if nginx -t; then
        print_msg "Nginx配置测试通过"
        systemctl reload nginx
        print_msg "Nginx已重载"
    else
        print_error "Nginx配置测试失败"
        exit 1
    fi
}

# 步骤5: 配置systemd服务
setup_service() {
    print_msg "配置systemd服务..."

    # 复制service文件
    cp ./deploy/sap-gateway.service /etc/systemd/system/

    # 重新加载systemd
    systemctl daemon-reload

    # 启用服务
    systemctl enable $SERVICE_NAME

    print_msg "服务配置完成"
}

# 步骤6: 启动服务
start_service() {
    print_msg "启动后端服务..."

    systemctl start $SERVICE_NAME

    # 等待服务启动
    sleep 5

    # 检查服务状态
    if systemctl is-active --quiet $SERVICE_NAME; then
        print_msg "服务启动成功！"
    else
        print_error "服务启动失败，请检查日志: journalctl -u $SERVICE_NAME -f"
        exit 1
    fi
}

# 步骤7: 验证部署
verify_deployment() {
    print_msg "验证部署..."

    # 检查Nginx
    if systemctl is-active --quiet nginx; then
        print_msg "✓ Nginx运行正常"
    else
        print_error "✗ Nginx未运行"
    fi

    # 检查后端服务
    if systemctl is-active --quiet $SERVICE_NAME; then
        print_msg "✓ 后端服务运行正常"
    else
        print_error "✗ 后端服务未运行"
    fi

    # 检查端口
    if ss -tln | grep -q ":80 "; then
        print_msg "✓ 端口80已监听"
    else
        print_warn "✗ 端口80未监听"
    fi

    if ss -tln | grep -q ":8080 "; then
        print_msg "✓ 端口8080已监听"
    else
        print_warn "✗ 端口8080未监听"
    fi

    echo ""
    print_msg "=========================================="
    print_msg "部署完成！"
    print_msg "访问地址: http://service.huangc.cn"
    print_msg "=========================================="
    print_msg ""
    print_msg "常用命令:"
    print_msg "  查看后端日志: journalctl -u $SERVICE_NAME -f"
    print_msg "  查看Nginx日志: tail -f /var/log/nginx/service.huangc.cn.access.log"
    print_msg "  重启后端: sudo systemctl restart $SERVICE_NAME"
    print_msg "  重载Nginx: sudo systemctl reload nginx"
}

# 主流程
main() {
    echo ""
    print_msg "=========================================="
    print_msg "学生综合事务中台 - 自动部署脚本"
    print_msg "=========================================="
    echo ""

    check_root
    create_directories
    deploy_frontend
    deploy_backend
    setup_nginx
    setup_service
    start_service
    verify_deployment
}

# 执行主流程
main "$@"
