-- =============================================
-- 学生综合事务中台 - 勤工助学数据库
-- =============================================

CREATE DATABASE IF NOT EXISTS `sap_workstudy` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `sap_workstudy`;

-- ----------------------------
-- 岗位表
-- ----------------------------
DROP TABLE IF EXISTS `ws_position`;
CREATE TABLE `ws_position` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '岗位ID',
    `title` VARCHAR(200) NOT NULL COMMENT '岗位名称',
    `department` VARCHAR(100) NOT NULL COMMENT '所属部门',
    `position_type` VARCHAR(50) DEFAULT '' COMMENT '岗位类型',
    `description` TEXT COMMENT '岗位描述',
    `requirements` TEXT COMMENT '岗位要求',
    `salary_per_hour` DECIMAL(8,2) NOT NULL COMMENT '时薪（元/小时）',
    `max_workers` INT DEFAULT 1 COMMENT '招聘人数',
    `current_workers` INT DEFAULT 0 COMMENT '当前在岗人数',
    `work_hours_per_week` INT DEFAULT 10 COMMENT '每周工作时长上限（小时）',
    `work_location` VARCHAR(200) DEFAULT '' COMMENT '工作地点',
    `contact_person` VARCHAR(50) DEFAULT '' COMMENT '联系人',
    `contact_phone` VARCHAR(20) DEFAULT '' COMMENT '联系电话',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0-关闭 1-开放 2-已满）',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`id`),
    KEY `idx_status` (`status`),
    KEY `idx_department` (`department`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='勤工助学岗位表';

-- ----------------------------
-- 应聘申请表
-- ----------------------------
DROP TABLE IF EXISTS `ws_application`;
CREATE TABLE `ws_application` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '申请ID',
    `position_id` BIGINT NOT NULL COMMENT '岗位ID',
    `user_id` BIGINT NOT NULL COMMENT '申请人ID',
    `real_name` VARCHAR(50) NOT NULL COMMENT '姓名',
    `student_no` VARCHAR(30) NOT NULL COMMENT '学号',
    `college` VARCHAR(100) DEFAULT '' COMMENT '学院',
    `major` VARCHAR(100) DEFAULT '' COMMENT '专业',
    `class_name` VARCHAR(50) DEFAULT '' COMMENT '班级',
    `phone` VARCHAR(20) DEFAULT '' COMMENT '联系电话',
    `apply_reason` TEXT COMMENT '申请理由',
    `related_experience` TEXT COMMENT '相关经历',
    `available_hours` INT DEFAULT 0 COMMENT '每周可工作时长',
    `status` TINYINT DEFAULT 0 COMMENT '状态（0-待审核 1-已通过 2-已驳回 3-已入职 4-已离职）',
    `reviewer_id` BIGINT DEFAULT NULL COMMENT '审核人ID',
    `reviewer_name` VARCHAR(50) DEFAULT '' COMMENT '审核人姓名',
    `review_time` DATETIME DEFAULT NULL COMMENT '审核时间',
    `review_remark` TEXT COMMENT '审核意见',
    `entry_time` DATETIME DEFAULT NULL COMMENT '入职时间',
    `leave_time` DATETIME DEFAULT NULL COMMENT '离职时间',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_position_id` (`position_id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='应聘申请表';

-- ----------------------------
-- 考勤记录表
-- ----------------------------
DROP TABLE IF EXISTS `ws_attendance`;
CREATE TABLE `ws_attendance` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '考勤ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `position_id` BIGINT NOT NULL COMMENT '岗位ID',
    `real_name` VARCHAR(50) DEFAULT '' COMMENT '姓名',
    `check_date` DATE NOT NULL COMMENT '考勤日期',
    `check_in_time` DATETIME DEFAULT NULL COMMENT '上班打卡时间',
    `check_out_time` DATETIME DEFAULT NULL COMMENT '下班打卡时间',
    `work_hours` DECIMAL(5,2) DEFAULT 0.00 COMMENT '工作时长（小时）',
    `check_in_type` VARCHAR(20) DEFAULT '' COMMENT '签到方式（manual-手动 auto-自动）',
    `check_out_type` VARCHAR(20) DEFAULT '' COMMENT '签退方式',
    `check_in_location` VARCHAR(200) DEFAULT '' COMMENT '签到地点',
    `check_out_location` VARCHAR(200) DEFAULT '' COMMENT '签退地点',
    `status` TINYINT DEFAULT 0 COMMENT '状态（0-正常 1-迟到 2-早退 3-缺勤 4-异常）',
    `remark` VARCHAR(500) DEFAULT '' COMMENT '备注',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_user_date` (`user_id`, `check_date`),
    KEY `idx_position_date` (`position_id`, `check_date`)
) ENGINE=InnoDB COMMENT='考勤记录表';

-- ----------------------------
-- 薪资记录表
-- ----------------------------
DROP TABLE IF EXISTS `ws_salary`;
CREATE TABLE `ws_salary` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '薪资ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `position_id` BIGINT NOT NULL COMMENT '岗位ID',
    `real_name` VARCHAR(50) DEFAULT '' COMMENT '姓名',
    `student_no` VARCHAR(30) DEFAULT '' COMMENT '学号',
    `salary_month` VARCHAR(10) NOT NULL COMMENT '薪资月份（yyyy-MM）',
    `total_hours` DECIMAL(8,2) DEFAULT 0.00 COMMENT '总工时（小时）`,
    `salary_per_hour` DECIMAL(8,2) DEFAULT 0.00 COMMENT '时薪',
    `base_salary` DECIMAL(10,2) DEFAULT 0.00 COMMENT '基本工资',
    `bonus` DECIMAL(10,2) DEFAULT 0.00 COMMENT '奖金',
    `deduction` DECIMAL(10,2) DEFAULT 0.00 COMMENT '扣除',
    `actual_salary` DECIMAL(10,2) DEFAULT 0.00 COMMENT '实发工资',
    `status` TINYINT DEFAULT 0 COMMENT '状态（0-待确认 1-已确认 2-已发放 3-已驳回）',
    `confirm_time` DATETIME DEFAULT NULL COMMENT '确认时间',
    `pay_time` DATETIME DEFAULT NULL COMMENT '发放时间',
    `reviewer_id` BIGINT DEFAULT NULL COMMENT '审核人ID',
    `review_time` DATETIME DEFAULT NULL COMMENT '审核时间',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_user_position_month` (`user_id`, `position_id`, `salary_month`),
    KEY `idx_salary_month` (`salary_month`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB COMMENT='薪资记录表';

-- ----------------------------
-- 班次配置表
-- ----------------------------
DROP TABLE IF EXISTS `ws_shift`;
CREATE TABLE `ws_shift` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '班次ID',
    `shift_name` VARCHAR(50) NOT NULL COMMENT '班次名称',
    `start_time` TIME NOT NULL COMMENT '开始时间',
    `end_time` TIME NOT NULL COMMENT '结束时间',
    `work_hours` DECIMAL(4,2) NOT NULL COMMENT '工作时长（小时）',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0-禁用 1-正常）',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB COMMENT='班次配置表';

-- ----------------------------
-- 初始化数据
-- ----------------------------

-- 初始化班次
INSERT INTO `ws_shift` VALUES (1, '上午班', '08:00:00', '12:00:00', 4.00, 1, NOW());
INSERT INTO `ws_shift` VALUES (2, '下午班', '14:00:00', '18:00:00', 4.00, 1, NOW());
INSERT INTO `ws_shift` VALUES (3, '晚班', '19:00:00', '21:00:00', 2.00, 1, NOW());
INSERT INTO `ws_shift` VALUES (4, '全天班', '08:00:00', '18:00:00', 8.00, 1, NOW());

-- 初始化岗位示例
INSERT INTO `ws_position` VALUES (1, '图书馆管理员', '图书馆', '管理类', '负责图书整理、借还书登记等工作', '工作认真负责，有责任心', 15.00, 5, 0, 10, '图书馆一楼', '王老师', '13800000001', 1, 'admin', NOW(), '', NULL, NULL);
INSERT INTO `ws_position` VALUES (2, '实验室助理', '计算机学院', '技术类', '协助老师管理实验室设备，指导学生实验', '熟悉计算机操作，有相关经验优先', 20.00, 3, 0, 8, '实验楼301', '李老师', '13800000002', 1, 'admin', NOW(), '', NULL, NULL);
INSERT INTO `ws_position` VALUES (3, '办公室文员', '学工处', '文职类', '协助处理日常文件整理、数据录入等工作', '熟练使用Office办公软件', 15.00, 2, 0, 10, '行政楼201', '张老师', '13800000003', 1, 'admin', NOW(), '', NULL, NULL);
