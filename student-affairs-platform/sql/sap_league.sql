-- =============================================
-- 学生综合事务中台 - 团员发展数据库
-- =============================================

CREATE DATABASE IF NOT EXISTS `sap_league` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `sap_league`;

-- ----------------------------
-- 入团申请表
-- ----------------------------
DROP TABLE IF EXISTS `league_application`;
CREATE TABLE `league_application` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '申请ID',
    `user_id` BIGINT NOT NULL COMMENT '申请人ID',
    `real_name` VARCHAR(50) NOT NULL COMMENT '姓名',
    `student_no` VARCHAR(30) NOT NULL COMMENT '学号',
    `college` VARCHAR(100) DEFAULT '' COMMENT '学院',
    `major` VARCHAR(100) DEFAULT '' COMMENT '专业',
    `class_name` VARCHAR(50) DEFAULT '' COMMENT '班级',
    `phone` VARCHAR(20) DEFAULT '' COMMENT '联系电话',
    `apply_reason` TEXT COMMENT '入团申请理由',
    `current_node` VARCHAR(50) DEFAULT 'apply' COMMENT '当前流程节点',
    `status` TINYINT DEFAULT 0 COMMENT '状态（0-待提交 1-待审核 2-审核中 3-已通过 4-已驳回）',
    `reviewer_id` BIGINT DEFAULT NULL COMMENT '审核人ID',
    `reviewer_name` VARCHAR(50) DEFAULT '' COMMENT '审核人姓名',
    `review_time` DATETIME DEFAULT NULL COMMENT '审核时间',
    `review_remark` TEXT COMMENT '审核意见',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='入团申请表';

-- ----------------------------
-- 培养流程节点表
-- ----------------------------
DROP TABLE IF EXISTS `league_process_node`;
CREATE TABLE `league_process_node` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '节点ID',
    `application_id` BIGINT NOT NULL COMMENT '申请ID',
    `node_name` VARCHAR(50) NOT NULL COMMENT '节点名称',
    `node_code` VARCHAR(50) NOT NULL COMMENT '节点编码',
    `sort` INT DEFAULT 0 COMMENT '排序',
    `status` TINYINT DEFAULT 0 COMMENT '状态（0-未开始 1-进行中 2-已完成 3-已驳回）',
    `handler_id` BIGINT DEFAULT NULL COMMENT '处理人ID',
    `handler_name` VARCHAR(50) DEFAULT '' COMMENT '处理人姓名',
    `handle_time` DATETIME DEFAULT NULL COMMENT '处理时间',
    `handle_remark` TEXT COMMENT '处理意见',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    KEY `idx_application_id` (`application_id`)
) ENGINE=InnoDB COMMENT='培养流程节点表';

-- ----------------------------
-- 政审备案表
-- ----------------------------
DROP TABLE IF EXISTS `league_political_review`;
CREATE TABLE `league_political_review` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '政审ID',
    `application_id` BIGINT NOT NULL COMMENT '申请ID',
    `user_id` BIGINT NOT NULL COMMENT '申请人ID',
    `review_type` VARCHAR(50) DEFAULT '' COMMENT '政审类型',
    `review_content` TEXT COMMENT '政审内容',
    `review_result` TINYINT DEFAULT 0 COMMENT '政审结果（0-待审核 1-通过 2-不通过）',
    `reviewer_id` BIGINT DEFAULT NULL COMMENT '政审人ID',
    `reviewer_name` VARCHAR(50) DEFAULT '' COMMENT '政审人姓名',
    `review_time` DATETIME DEFAULT NULL COMMENT '政审时间',
    `attachment` VARCHAR(500) DEFAULT '' COMMENT '附件材料',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`id`),
    KEY `idx_application_id` (`application_id`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB COMMENT='政审备案表';

-- ----------------------------
-- 电子档案表
-- ----------------------------
DROP TABLE IF EXISTS `league_archive`;
CREATE TABLE `league_archive` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '档案ID',
    `application_id` BIGINT NOT NULL COMMENT '申请ID',
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `archive_no` VARCHAR(50) NOT NULL COMMENT '档案编号',
    `archive_name` VARCHAR(200) NOT NULL COMMENT '档案名称',
    `file_path` VARCHAR(500) DEFAULT '' COMMENT '文件路径',
    `file_size` BIGINT DEFAULT 0 COMMENT '文件大小（字节）',
    `file_type` VARCHAR(50) DEFAULT '' COMMENT '文件类型',
    `status` TINYINT DEFAULT 0 COMMENT '状态（0-未生成 1-已生成 2-已归档）',
    `generate_time` DATETIME DEFAULT NULL COMMENT '生成时间',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_archive_no` (`archive_no`),
    KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB COMMENT='电子档案表';

-- ----------------------------
-- 培养数据统计表
-- ----------------------------
DROP TABLE IF EXISTS `league_statistics`;
CREATE TABLE `league_statistics` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '统计ID',
    `stat_date` DATE NOT NULL COMMENT '统计日期',
    `college` VARCHAR(100) DEFAULT '' COMMENT '学院',
    `total_apply` INT DEFAULT 0 COMMENT '申请总数',
    `pending_review` INT DEFAULT 0 COMMENT '待审核数',
    `approved` INT DEFAULT 0 COMMENT '已通过数',
    `rejected` INT DEFAULT 0 COMMENT '已驳回数',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_stat_date_college` (`stat_date`, `college`)
) ENGINE=InnoDB COMMENT='培养数据统计表';
