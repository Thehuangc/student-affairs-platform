-- =============================================
-- 学生综合事务中台 - 志愿服务数据库
-- =============================================

CREATE DATABASE IF NOT EXISTS `sap_volunteer` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `sap_volunteer`;

-- ----------------------------
-- 志愿者信息表
-- ----------------------------
DROP TABLE IF EXISTS `vol_volunteer`;
CREATE TABLE `vol_volunteer` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '志愿者ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `real_name` VARCHAR(50) NOT NULL COMMENT '姓名',
    `student_no` VARCHAR(30) NOT NULL COMMENT '学号',
    `college` VARCHAR(100) DEFAULT '' COMMENT '学院',
    `major` VARCHAR(100) DEFAULT '' COMMENT '专业',
    `class_name` VARCHAR(50) DEFAULT '' COMMENT '班级',
    `phone` VARCHAR(20) DEFAULT '' COMMENT '联系电话',
    `total_hours` DECIMAL(10,2) DEFAULT 0.00 COMMENT '累计志愿时长（小时）',
    `this_year_hours` DECIMAL(10,2) DEFAULT 0.00 COMMENT '本年度志愿时长',
    `level` VARCHAR(20) DEFAULT 'normal' COMMENT '志愿者等级',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0-禁用 1-正常）',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_user_id` (`user_id`),
    UNIQUE KEY `idx_student_no` (`student_no`),
    KEY `idx_total_hours` (`total_hours`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='志愿者信息表';

-- ----------------------------
-- 志愿团队表
-- ----------------------------
DROP TABLE IF EXISTS `vol_team`;
CREATE TABLE `vol_team` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '团队ID',
    `team_name` VARCHAR(100) NOT NULL COMMENT '团队名称',
    `team_code` VARCHAR(50) NOT NULL COMMENT '团队编码',
    `description` TEXT COMMENT '团队介绍',
    `leader_id` BIGINT NOT NULL COMMENT '负责人ID',
    `leader_name` VARCHAR(50) DEFAULT '' COMMENT '负责人姓名',
    `member_count` INT DEFAULT 0 COMMENT '成员数量',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0-已解散 1-正常）',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_team_code` (`team_code`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='志愿团队表';

-- ----------------------------
-- 团队成员表
-- ----------------------------
DROP TABLE IF EXISTS `vol_team_member`;
CREATE TABLE `vol_team_member` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT 'ID',
    `team_id` BIGINT NOT NULL COMMENT '团队ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `real_name` VARCHAR(50) DEFAULT '' COMMENT '姓名',
    `role` VARCHAR(20) DEFAULT 'member' COMMENT '角色（leader-负责人 vice_leader-副队长 member-成员）',
    `join_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '加入时间',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0-已退出 1-正常）',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_team_user` (`team_id`, `user_id`)
) ENGINE=InnoDB COMMENT='团队成员表';

-- ----------------------------
-- 换届记录表
-- ----------------------------
DROP TABLE IF EXISTS `vol_election`;
CREATE TABLE `vol_election` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '换届ID',
    `team_id` BIGINT NOT NULL COMMENT '团队ID',
    `old_leader_id` BIGINT DEFAULT NULL COMMENT '原负责人ID',
    `new_leader_id` BIGINT NOT NULL COMMENT '新负责人ID',
    `election_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '换届时间',
    `remark` TEXT COMMENT '备注',
    PRIMARY KEY (`id`),
    KEY `idx_team_id` (`team_id`)
) ENGINE=InnoDB COMMENT='换届记录表';

-- ----------------------------
-- 志愿活动表
-- ----------------------------
DROP TABLE IF EXISTS `vol_activity`;
CREATE TABLE `vol_activity` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '活动ID',
    `title` VARCHAR(200) NOT NULL COMMENT '活动标题',
    `content` TEXT COMMENT '活动内容',
    `activity_type` VARCHAR(50) DEFAULT '' COMMENT '活动类型',
    `location` VARCHAR(200) DEFAULT '' COMMENT '活动地点',
    `start_time` DATETIME NOT NULL COMMENT '开始时间',
    `end_time` DATETIME NOT NULL COMMENT '结束时间',
    `max_participants` INT DEFAULT 0 COMMENT '最大参与人数',
    `current_participants` INT DEFAULT 0 COMMENT '当前报名人数',
    `team_id` BIGINT DEFAULT NULL COMMENT '所属团队ID',
    `organizer` VARCHAR(100) DEFAULT '' COMMENT '组织单位',
    `contact_person` VARCHAR(50) DEFAULT '' COMMENT '联系人',
    `contact_phone` VARCHAR(20) DEFAULT '' COMMENT '联系电话',
    `check_in_code` VARCHAR(50) DEFAULT '' COMMENT '签到二维码',
    `status` TINYINT DEFAULT 0 COMMENT '状态（0-未开始 1-进行中 2-已结束 3-已取消）',
    `creator_id` BIGINT NOT NULL COMMENT '创建人ID',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`id`),
    KEY `idx_status` (`status`),
    KEY `idx_start_time` (`start_time`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='志愿活动表';

-- ----------------------------
-- 活动报名表
-- ----------------------------
DROP TABLE IF EXISTS `vol_activity_enroll`;
CREATE TABLE `vol_activity_enroll` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '报名ID',
    `activity_id` BIGINT NOT NULL COMMENT '活动ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `real_name` VARCHAR(50) DEFAULT '' COMMENT '姓名',
    `phone` VARCHAR(20) DEFAULT '' COMMENT '联系电话',
    `status` TINYINT DEFAULT 0 COMMENT '状态（0-已报名 1-已签到 2-已签退 3-已取消）',
    `enroll_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '报名时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_activity_user` (`activity_id`, `user_id`)
) ENGINE=InnoDB COMMENT='活动报名表';

-- ----------------------------
-- 签到打卡表
-- ----------------------------
DROP TABLE IF EXISTS `vol_check_in`;
CREATE TABLE `vol_check_in` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '签到ID',
    `activity_id` BIGINT NOT NULL COMMENT '活动ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `real_name` VARCHAR(50) DEFAULT '' COMMENT '姓名',
    `check_in_time` DATETIME DEFAULT NULL COMMENT '签到时间',
    `check_out_time` DATETIME DEFAULT NULL COMMENT '签退时间',
    `check_in_location` VARCHAR(200) DEFAULT '' COMMENT '签到地点',
    `check_in_lat` DECIMAL(10,7) DEFAULT NULL COMMENT '签到纬度',
    `check_in_lng` DECIMAL(10,7) DEFAULT NULL COMMENT '签到经度',
    `duration` DECIMAL(5,2) DEFAULT 0.00 COMMENT '时长（小时）',
    `status` TINYINT DEFAULT 0 COMMENT '状态（0-待核算 1-已核算 2-已驳回）',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_activity_user` (`activity_id`, `user_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB COMMENT='签到打卡表';

-- ----------------------------
-- 志愿时长记录表
-- ----------------------------
DROP TABLE IF EXISTS `vol_hours_record`;
CREATE TABLE `vol_hours_record` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '记录ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `real_name` VARCHAR(50) DEFAULT '' COMMENT '姓名',
    `activity_id` BIGINT NOT NULL COMMENT '活动ID',
    `activity_title` VARCHAR(200) DEFAULT '' COMMENT '活动标题',
    `hours` DECIMAL(5,2) NOT NULL COMMENT '志愿时长（小时）`,
    `record_type` VARCHAR(20) DEFAULT 'auto' COMMENT '记录类型（auto-自动核算 manual-手动录入）',
    `stat_month` VARCHAR(10) DEFAULT '' COMMENT '统计月份（yyyy-MM）',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0-待审核 1-已确认 2-已驳回）',
    `reviewer_id` BIGINT DEFAULT NULL COMMENT '审核人ID',
    `review_time` DATETIME DEFAULT NULL COMMENT '审核时间',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_activity_id` (`activity_id`),
    KEY `idx_stat_month` (`stat_month`)
) ENGINE=InnoDB COMMENT='志愿时长记录表';

-- ----------------------------
-- 时长核算定时任务记录表
-- ----------------------------
DROP TABLE IF EXISTS `vol_cron_job_log`;
CREATE TABLE `vol_cron_job_log` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志ID',
    `job_name` VARCHAR(100) NOT NULL COMMENT '任务名称',
    `job_group` VARCHAR(50) DEFAULT '' COMMENT '任务组名',
    `start_time` DATETIME DEFAULT NULL COMMENT '开始时间',
    `end_time` DATETIME DEFAULT NULL COMMENT '结束时间',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0-失败 1-成功）',
    `process_count` INT DEFAULT 0 COMMENT '处理记录数',
    `error_msg` TEXT COMMENT '错误信息',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    KEY `idx_job_name` (`job_name`)
) ENGINE=InnoDB COMMENT='定时任务日志表';
