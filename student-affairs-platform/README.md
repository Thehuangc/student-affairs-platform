# 学生综合事务中台

## 项目简介

学生综合事务中台（Student Affairs Platform）是一个基于微服务架构的学生综合事务管理系统，涵盖团员发展、社团活动、志愿服务、勤工助学等核心业务，并提供AI综合素质测评功能。

## 技术栈

### 后端技术
| 技术 | 说明 | 版本 |
|------|------|------|
| Spring Boot | 基础框架 | 3.2.0 |
| Spring Cloud | 微服务框架 | 2023.0.0 |
| Spring Cloud Alibaba | 阿里巴巴微服务组件 | 2023.0.0.0 |
| Nacos | 注册中心/配置中心 | 2.3.0 |
| Spring Cloud Gateway | API网关 | - |
| MyBatis-Plus | ORM框架 | 3.5.5 |
| MySQL | 关系型数据库 | 8.0 |
| Redis | 缓存 | 7.x |
| MinIO | 对象存储 | - |
| JWT | 令牌认证 | 0.12.3 |
| Knife4j | API文档 | 4.3.0 |

### 前端技术
| 技术 | 说明 |
|------|------|
| Vue 3 | 前端框架 |
| TypeScript | 类型系统 |
| Vite 5 | 构建工具 |
| Element Plus | UI组件库（管理端）|
| Vant 4 | UI组件库（学生端）|
| Pinia | 状态管理 |
| Vue Router | 路由管理 |
| Axios | HTTP客户端 |

## 项目结构

```
student-affairs-platform/
├── docs/                           # 项目文档
├── sql/                            # 数据库脚本
│   ├── sap_system.sql             # 系统管理库
│   ├── sap_league.sql             # 团员发展库
│   ├── sap_volunteer.sql          # 志愿服务库
│   └── sap_workstudy.sql          # 勤工助学库
├── sap-common/                     # 公共模块
│   ├── sap-common-core/           # 核心工具类
│   ├── sap-common-redis/          # Redis配置
│   ├── sap-common-mybatis/        # MyBatis配置
│   └── sap-common-log/            # 日志模块
├── sap-gateway/                    # 网关服务 (8080)
├── sap-auth/                       # 认证服务 (8081)
├── sap-system/                     # 系统管理服务 (8082)
├── sap-league/                     # 团员发展服务 (8083)
├── sap-club/                       # 社团活动服务 (8084)
├── sap-volunteer/                  # 志愿服务 (8085)
├── sap-workstudy/                  # 勤工助学服务 (8086)
├── sap-ai/                         # AI测评服务 (8087)
├── sap-notification/               # 消息推送服务 (8088)
├── sap-admin-ui/                   # 管理后台前端
├── sap-student-ui/                 # 学生端前端
├── docker/                         # Docker配置
│   └── docker-compose.yml
├── pom.xml                         # 父POM
└── README.md
```

## 快速开始

### 环境要求

- JDK 17+
- Maven 3.8+
- Docker & Docker Compose
- Node.js 18+ (前端开发)

### 1. 启动基础设施

```bash
cd docker
docker-compose up -d
```

这将启动：
- MySQL (端口: 3306)
- Redis (端口: 6379)
- Nacos (端口: 8848)
- MinIO (端口: 9000/9001)

### 2. 初始化数据库

数据库脚本位于 `sql/` 目录，会通过 Docker Compose 自动执行。

手动执行：
```bash
mysql -u root -proot < sql/sap_system.sql
mysql -u root -proot < sql/sap_league.sql
mysql -u root -proot < sql/sap_volunteer.sql
mysql -u root -proot < sql/sap_workstudy.sql
```

### 3. 启动后端服务

```bash
# 编译整个项目
mvn clean install -DskipTests

# 启动网关服务
cd sap-gateway
mvn spring-boot:run

# 启动认证服务
cd sap-auth
mvn spring-boot:run

# 启动其他服务...
```

### 4. 启动前端

```bash
# 进入管理后台目录
cd sap-admin-ui

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

访问 http://localhost:3000

### 默认账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |
| 学生 | student | admin123 |
| 教师 | teacher | admin123 |

## 服务端口

| 服务 | 端口 |
|------|------|
| API网关 | 8080 |
| 认证服务 | 8081 |
| 系统管理 | 8082 |
| 团员发展 | 8083 |
| 社团活动 | 8084 |
| 志愿服务 | 8085 |
| 勤工助学 | 8086 |
| AI测评 | 8087 |
| 消息推送 | 8088 |
| 管理后台前端 | 3000 |
| 学生端前端 | 3001 |

## API文档

启动服务后，访问 Knife4j 文档：
- 网关API文档: http://localhost:8080/doc.html
- 认证服务文档: http://localhost:8081/doc.html
- 志愿服务文档: http://localhost:8085/doc.html

## 核心功能

### 1. 统一认证
- JWT Token 认证
- 单点登录（SSO）
- 权限管理（RBAC）

### 2. 团员发展
- 入团申请流程
- 政审备案
- 电子档案生成
- 数据统计

### 3. 社团活动
- 活动申报
- 素材上传归档
- 活动统计

### 4. 志愿服务
- 志愿者注册
- 活动签到打卡
- 定时任务核算时长
- 时长排行榜

### 5. 勤工助学
- 岗位发布
- 应聘管理
- 智能考勤
- 薪资自动计算

### 6. AI综合素质测评
- 基于学生荣誉、志愿时长
- 自动生成综测评语
- 综合素质评分

## 开发计划

- [x] 项目架构搭建
- [x] 公共模块开发
- [x] 网关服务开发
- [x] 认证服务开发
- [x] 志愿服务开发
- [ ] 团员发展服务开发
- [ ] 社团活动服务开发
- [ ] 勤工助学服务开发
- [ ] 消息推送服务开发
- [ ] AI测评服务开发
- [ ] 管理后台前端开发
- [ ] 学生端前端开发

## 许可证

本项目仅供学习交流使用。
