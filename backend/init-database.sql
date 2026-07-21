-- =============================================
-- 学生综合事务中台 - 完整数据库初始化脚本
-- =============================================

-- 创建数据库
CREATE DATABASE IF NOT EXISTS sap_service DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE sap_service;

-- ----------------------------
-- 用户表
-- ----------------------------
DROP TABLE IF EXISTS users;
CREATE TABLE users (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(200) NOT NULL,
    nickname VARCHAR(50) DEFAULT '',
    real_name VARCHAR(50) DEFAULT '',
    student_no VARCHAR(30) DEFAULT '',
    email VARCHAR(100) DEFAULT '',
    phone VARCHAR(20) DEFAULT '',
    sex TINYINT DEFAULT 0,
    avatar VARCHAR(500) DEFAULT '',
    college VARCHAR(100) DEFAULT '',
    major VARCHAR(100) DEFAULT '',
    class_name VARCHAR(50) DEFAULT '',
    status TINYINT DEFAULT 1,
    roles VARCHAR(200) DEFAULT 'student',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=100;

-- ----------------------------
-- 角色表
-- ----------------------------
DROP TABLE IF EXISTS roles;
CREATE TABLE roles (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL,
    role_key VARCHAR(100) NOT NULL UNIQUE,
    sort INT DEFAULT 0,
    status TINYINT DEFAULT 1,
    remark VARCHAR(500) DEFAULT '',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=100;

-- ----------------------------
-- 用户角色关联表
-- ----------------------------
DROP TABLE IF EXISTS user_roles;
CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id)
) ENGINE=InnoDB;

-- ----------------------------
-- 志愿活动表
-- ----------------------------
DROP TABLE IF EXISTS activities;
CREATE TABLE activities (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    activity_type VARCHAR(50) DEFAULT '',
    location VARCHAR(200) DEFAULT '',
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    max_participants INT DEFAULT 0,
    current_participants INT DEFAULT 0,
    team_id BIGINT DEFAULT NULL,
    organizer VARCHAR(100) DEFAULT '',
    contact_person VARCHAR(50) DEFAULT '',
    contact_phone VARCHAR(20) DEFAULT '',
    check_in_code VARCHAR(50) DEFAULT '',
    status TINYINT DEFAULT 0,
    creator_id BIGINT NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=100;

-- ----------------------------
-- 活动报名表
-- ----------------------------
DROP TABLE IF EXISTS activity_enrolls;
CREATE TABLE activity_enrolls (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    activity_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    real_name VARCHAR(50) DEFAULT '',
    phone VARCHAR(20) DEFAULT '',
    status TINYINT DEFAULT 0,
    enroll_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY idx_activity_user (activity_id, user_id)
) ENGINE=InnoDB;

-- ----------------------------
-- 签到打卡表
-- ----------------------------
DROP TABLE IF EXISTS check_ins;
CREATE TABLE check_ins (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    activity_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    real_name VARCHAR(50) DEFAULT '',
    check_in_time DATETIME DEFAULT NULL,
    check_out_time DATETIME DEFAULT NULL,
    check_in_location VARCHAR(200) DEFAULT '',
    check_in_lat DECIMAL(10,7) DEFAULT NULL,
    check_in_lng DECIMAL(10,7) DEFAULT NULL,
    duration DECIMAL(5,2) DEFAULT 0.00,
    status TINYINT DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_activity_user (activity_id, user_id),
    KEY idx_user_id (user_id)
) ENGINE=InnoDB;

-- ----------------------------
-- 志愿者信息表
-- ----------------------------
DROP TABLE IF EXISTS volunteers;
CREATE TABLE volunteers (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    real_name VARCHAR(50) NOT NULL,
    student_no VARCHAR(30) NOT NULL,
    college VARCHAR(100) DEFAULT '',
    major VARCHAR(100) DEFAULT '',
    class_name VARCHAR(50) DEFAULT '',
    phone VARCHAR(20) DEFAULT '',
    total_hours DECIMAL(10,2) DEFAULT 0.00,
    this_year_hours DECIMAL(10,2) DEFAULT 0.00,
    level VARCHAR(20) DEFAULT 'normal',
    status TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=100;

-- ----------------------------
-- 志愿时长记录表
-- ----------------------------
DROP TABLE IF EXISTS hours_records;
CREATE TABLE hours_records (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    real_name VARCHAR(50) DEFAULT '',
    activity_id BIGINT NOT NULL,
    activity_title VARCHAR(200) DEFAULT '',
    hours DECIMAL(5,2) NOT NULL,
    record_type VARCHAR(20) DEFAULT 'auto',
    stat_month VARCHAR(10) DEFAULT '',
    status TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    KEY idx_user_id (user_id),
    KEY idx_stat_month (stat_month)
) ENGINE=InnoDB;

-- ----------------------------
-- 入团申请表
-- ----------------------------
DROP TABLE IF EXISTS league_applications;
CREATE TABLE league_applications (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    real_name VARCHAR(50) NOT NULL,
    student_no VARCHAR(30) NOT NULL,
    college VARCHAR(100) DEFAULT '',
    major VARCHAR(100) DEFAULT '',
    class_name VARCHAR(50) DEFAULT '',
    phone VARCHAR(20) DEFAULT '',
    apply_reason TEXT,
    current_node VARCHAR(50) DEFAULT 'apply',
    status TINYINT DEFAULT 0,
    reviewer_id BIGINT DEFAULT NULL,
    reviewer_name VARCHAR(50) DEFAULT '',
    review_time DATETIME DEFAULT NULL,
    review_remark TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_user_id (user_id),
    KEY idx_status (status)
) ENGINE=InnoDB AUTO_INCREMENT=100;

-- ----------------------------
-- 政审备案表
-- ----------------------------
DROP TABLE IF EXISTS political_reviews;
CREATE TABLE political_reviews (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    application_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    review_type VARCHAR(50) DEFAULT '',
    review_content TEXT,
    review_result TINYINT DEFAULT 0,
    reviewer_id BIGINT DEFAULT NULL,
    reviewer_name VARCHAR(50) DEFAULT '',
    review_time DATETIME DEFAULT NULL,
    attachment VARCHAR(500) DEFAULT '',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_application_id (application_id),
    KEY idx_user_id (user_id)
) ENGINE=InnoDB;

-- ----------------------------
-- 电子档案表
-- ----------------------------
DROP TABLE IF EXISTS league_archives;
CREATE TABLE league_archives (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    application_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    archive_no VARCHAR(50) NOT NULL UNIQUE,
    archive_name VARCHAR(200) NOT NULL,
    file_path VARCHAR(500) DEFAULT '',
    file_size BIGINT DEFAULT 0,
    file_type VARCHAR(50) DEFAULT '',
    status TINYINT DEFAULT 0,
    generate_time DATETIME DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_user_id (user_id)
) ENGINE=InnoDB;

-- ----------------------------
-- 勤工助学岗位表
-- ----------------------------
DROP TABLE IF EXISTS ws_positions;
CREATE TABLE ws_positions (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    department VARCHAR(100) NOT NULL,
    position_type VARCHAR(50) DEFAULT '',
    description TEXT,
    requirements TEXT,
    salary_per_hour DECIMAL(8,2) NOT NULL,
    max_workers INT DEFAULT 1,
    current_workers INT DEFAULT 0,
    work_hours_per_week INT DEFAULT 10,
    work_location VARCHAR(200) DEFAULT '',
    contact_person VARCHAR(50) DEFAULT '',
    contact_phone VARCHAR(20) DEFAULT '',
    status TINYINT DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=100;

-- ----------------------------
-- 应聘申请表
-- ----------------------------
DROP TABLE IF EXISTS ws_applications;
CREATE TABLE ws_applications (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    position_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    real_name VARCHAR(50) NOT NULL,
    student_no VARCHAR(30) NOT NULL,
    college VARCHAR(100) DEFAULT '',
    major VARCHAR(100) DEFAULT '',
    class_name VARCHAR(50) DEFAULT '',
    phone VARCHAR(20) DEFAULT '',
    apply_reason TEXT,
    related_experience TEXT,
    available_hours INT DEFAULT 0,
    status TINYINT DEFAULT 0,
    reviewer_id BIGINT DEFAULT NULL,
    reviewer_name VARCHAR(50) DEFAULT '',
    review_time DATETIME DEFAULT NULL,
    review_remark TEXT,
    entry_time DATETIME DEFAULT NULL,
    leave_time DATETIME DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_position_id (position_id),
    KEY idx_user_id (user_id)
) ENGINE=InnoDB AUTO_INCREMENT=100;

-- ----------------------------
-- 考勤记录表
-- ----------------------------
DROP TABLE IF EXISTS ws_attendance;
CREATE TABLE ws_attendance (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    position_id BIGINT NOT NULL,
    real_name VARCHAR(50) DEFAULT '',
    check_date DATE NOT NULL,
    check_in_time DATETIME DEFAULT NULL,
    check_out_time DATETIME DEFAULT NULL,
    work_hours DECIMAL(5,2) DEFAULT 0.00,
    check_in_type VARCHAR(20) DEFAULT '',
    check_out_type VARCHAR(20) DEFAULT '',
    check_in_location VARCHAR(200) DEFAULT '',
    check_out_location VARCHAR(200) DEFAULT '',
    status TINYINT DEFAULT 0,
    remark VARCHAR(500) DEFAULT '',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_user_date (user_id, check_date),
    KEY idx_position_date (position_id, check_date)
) ENGINE=InnoDB;

-- ----------------------------
-- 薪资记录表
-- ----------------------------
DROP TABLE IF EXISTS ws_salary;
CREATE TABLE ws_salary (
    id BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    position_id BIGINT NOT NULL,
    real_name VARCHAR(50) DEFAULT '',
    student_no VARCHAR(30) DEFAULT '',
    salary_month VARCHAR(10) NOT NULL,
    total_hours DECIMAL(8,2) DEFAULT 0.00,
    salary_per_hour DECIMAL(8,2) DEFAULT 0.00,
    base_salary DECIMAL(10,2) DEFAULT 0.00,
    bonus DECIMAL(10,2) DEFAULT 0.00,
    deduction DECIMAL(10,2) DEFAULT 0.00,
    actual_salary DECIMAL(10,2) DEFAULT 0.00,
    status TINYINT DEFAULT 0,
    confirm_time DATETIME DEFAULT NULL,
    pay_time DATETIME DEFAULT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY idx_user_position_month (user_id, position_id, salary_month),
    KEY idx_salary_month (salary_month)
) ENGINE=InnoDB;

-- ----------------------------
-- 初始化数据
-- ----------------------------

-- 初始化角色
INSERT INTO roles VALUES (1, '超级管理员', 'admin', 1, 1, '超级管理员', NOW(), NOW());
INSERT INTO roles VALUES (2, '普通用户', 'user', 2, 1, '普通用户', NOW(), NOW());
INSERT INTO roles VALUES (3, '教师', 'teacher', 3, 1, '教师角色', NOW(), NOW());
INSERT INTO roles VALUES (4, '学生', 'student', 4, 1, '学生角色', NOW(), NOW());

-- 初始化用户 (密码: admin123)
INSERT INTO users VALUES (1, 'admin', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '管理员', '管理员', '', 'admin@sap.com', '13800138000', 1, '', '', '', '', 1, 'admin', NOW(), NOW());
INSERT INTO users VALUES (2, 'student', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张三', '张三', '2024001', 'zhangsan@sap.com', '13800138001', 1, '', '计算机学院', '软件工程', '软件2401', 1, 'student', NOW(), NOW());
INSERT INTO users VALUES (3, 'teacher', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李老师', '李明', '', 'teacher@sap.com', '13800138002', 1, '', '计算机学院', '', '', 1, 'teacher', NOW(), NOW());

-- 用户角色关联
INSERT INTO user_roles VALUES (1, 1);
INSERT INTO user_roles VALUES (2, 4);
INSERT INTO user_roles VALUES (3, 3);

-- 初始化志愿活动
INSERT INTO activities VALUES (1, '校园清洁志愿活动', '组织志愿者清理校园环境', '环保公益', '校园主干道', '2026-07-20 09:00:00', '2026-07-20 12:00:00', 50, 15, NULL, '校团委', '王老师', '13800000001', 'abc123', 2, 1, NOW(), NOW());
INSERT INTO activities VALUES (2, '社区敬老服务', '为社区老人提供陪伴和帮助', '社区服务', '阳光社区', '2026-07-25 14:00:00', '2026-07-25 17:00:00', 30, 8, NULL, '青年志愿者协会', '李同学', '13800000002', 'def456', 0, 1, NOW(), NOW());
INSERT INTO activities VALUES (3, '图书馆整理志愿服务', '协助图书馆整理书籍', '教育支教', '图书馆一楼', '2026-07-22 08:30:00', '2026-07-22 11:30:00', 20, 20, NULL, '图书馆', '张老师', '13800000003', 'ghi789', 1, 1, NOW(), NOW());

-- 初始化志愿者
INSERT INTO volunteers VALUES (1, 2, '张三', '2024001', '计算机学院', '软件工程', '软件2401', '13800138001', 48.50, 24.00, 'silver', 1, NOW(), NOW());

-- 初始化签到记录
INSERT INTO check_ins VALUES (1, 1, 2, '张三', '2026-07-20 09:05:00', '2026-07-20 11:55:00', '校园主干道', 39.9042, 116.4074, 2.83, 1, NOW(), NOW());

-- 初始化时长记录
INSERT INTO hours_records VALUES (1, 2, '张三', 1, '校园清洁志愿活动', 2.83, 'auto', '2026-07', 1, NOW());

-- 初始化勤工助学岗位
INSERT INTO ws_positions VALUES (1, '图书馆管理员', '图书馆', '管理类', '负责图书整理、借还书登记等工作', '工作认真负责，有责任心', 15.00, 5, 0, 10, '图书馆一楼', '王老师', '13800000001', 1, NOW(), NOW());
INSERT INTO ws_positions VALUES (2, '实验室助理', '计算机学院', '技术类', '协助老师管理实验室设备，指导学生实验', '熟悉计算机操作，有相关经验优先', 20.00, 3, 0, 8, '实验楼301', '李老师', '13800000002', 1, NOW(), NOW());
INSERT INTO ws_positions VALUES (3, '办公室文员', '学工处', '文职类', '协助处理日常文件整理、数据录入等工作', '熟练使用Office办公软件', 15.00, 2, 0, 10, '行政楼201', '张老师', '13800000003', 1, NOW(), NOW());

-- 初始化入团申请
INSERT INTO league_applications VALUES (1, 2, '张三', '2024001', '计算机学院', '软件工程', '软件2401', '13800138001', '我志愿加入中国共产主义青年团，愿意为共产主义事业奋斗终身。', 'apply', 0, NULL, '', NULL, NULL, NOW(), NOW());
