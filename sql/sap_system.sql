-- =============================================
-- 学生综合事务中台 - 系统管理数据库
-- =============================================

CREATE DATABASE IF NOT EXISTS `sap_system` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

USE `sap_system`;

-- ----------------------------
-- 用户表
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '用户ID',
    `username` VARCHAR(50) NOT NULL COMMENT '用户名',
    `password` VARCHAR(200) NOT NULL COMMENT '密码',
    `nickname` VARCHAR(50) DEFAULT '' COMMENT '昵称',
    `real_name` VARCHAR(50) DEFAULT '' COMMENT '真实姓名',
    `student_no` VARCHAR(30) DEFAULT '' COMMENT '学号',
    `email` VARCHAR(100) DEFAULT '' COMMENT '邮箱',
    `phone` VARCHAR(20) DEFAULT '' COMMENT '手机号',
    `sex` TINYINT DEFAULT 0 COMMENT '性别（0-未知 1-男 2-女）',
    `avatar` VARCHAR(500) DEFAULT '' COMMENT '头像',
    `college` VARCHAR(100) DEFAULT '' COMMENT '学院',
    `major` VARCHAR(100) DEFAULT '' COMMENT '专业',
    `class_name` VARCHAR(50) DEFAULT '' COMMENT '班级',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0-禁用 1-正常）',
    `del_flag` TINYINT DEFAULT 0 COMMENT '删除标志（0-存在 1-删除）',
    `login_ip` VARCHAR(128) DEFAULT '' COMMENT '最后登录IP',
    `login_date` DATETIME DEFAULT NULL COMMENT '最后登录时间',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`id`),
    UNIQUE KEY `idx_username` (`username`),
    UNIQUE KEY `idx_student_no` (`student_no`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='用户表';

-- ----------------------------
-- 角色表
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '角色ID',
    `role_name` VARCHAR(50) NOT NULL COMMENT '角色名称',
    `role_key` VARCHAR(100) NOT NULL COMMENT '角色权限字符串',
    `sort` INT DEFAULT 0 COMMENT '显示顺序',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0-禁用 1-正常）',
    `del_flag` TINYINT DEFAULT 0 COMMENT '删除标志（0-存在 1-删除）',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='角色表';

-- ----------------------------
-- 菜单表
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '菜单ID',
    `menu_name` VARCHAR(50) NOT NULL COMMENT '菜单名称',
    `parent_id` BIGINT DEFAULT 0 COMMENT '父菜单ID',
    `order_num` INT DEFAULT 0 COMMENT '显示顺序',
    `path` VARCHAR(200) DEFAULT '' COMMENT '路由地址',
    `component` VARCHAR(255) DEFAULT '' COMMENT '组件路径',
    `query` VARCHAR(255) DEFAULT '' COMMENT '路由参数',
    `is_frame` TINYINT DEFAULT 1 COMMENT '是否为外链（0-是 1-否）',
    `is_cache` TINYINT DEFAULT 0 COMMENT '是否缓存（0-缓存 1-不缓存）',
    `menu_type` CHAR(1) DEFAULT '' COMMENT '菜单类型（M-目录 C-菜单 F-按钮）',
    `visible` TINYINT DEFAULT 0 COMMENT '是否显示（0-显示 1-隐藏）',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0-禁用 1-正常）',
    `perms` VARCHAR(100) DEFAULT '' COMMENT '权限标识',
    `icon` VARCHAR(100) DEFAULT '#' COMMENT '菜单图标',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT '' COMMENT '备注',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2000 COMMENT='菜单权限表';

-- ----------------------------
-- 用户角色关联表
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
    `user_id` BIGINT NOT NULL COMMENT '用户ID',
    `role_id` BIGINT NOT NULL COMMENT '角色ID',
    PRIMARY KEY (`user_id`, `role_id`)
) ENGINE=InnoDB COMMENT='用户和角色关联表';

-- ----------------------------
-- 角色菜单关联表
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu` (
    `role_id` BIGINT NOT NULL COMMENT '角色ID',
    `menu_id` BIGINT NOT NULL COMMENT '菜单ID',
    PRIMARY KEY (`role_id`, `menu_id`)
) ENGINE=InnoDB COMMENT='角色和菜单关联表';

-- ----------------------------
-- 数据字典类型表
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '字典主键',
    `dict_name` VARCHAR(100) DEFAULT '' COMMENT '字典名称',
    `dict_type` VARCHAR(100) DEFAULT '' UNIQUE COMMENT '字典类型',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0-禁用 1-正常）',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='字典类型表';

-- ----------------------------
-- 数据字典数据表
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '字典编码',
    `sort` INT DEFAULT 0 COMMENT '字典排序',
    `dict_label` VARCHAR(100) DEFAULT '' COMMENT '字典标签',
    `dict_value` VARCHAR(100) DEFAULT '' COMMENT '字典键值',
    `dict_type` VARCHAR(100) DEFAULT '' COMMENT '字典类型',
    `css_class` VARCHAR(100) DEFAULT '' COMMENT '样式属性',
    `list_class` VARCHAR(100) DEFAULT '' COMMENT '表格回显样式',
    `is_default` CHAR(1) DEFAULT 'N' COMMENT '是否默认（Y-是 N-否）',
    `status` TINYINT DEFAULT 1 COMMENT '状态（0-禁用 1-正常）',
    `create_by` VARCHAR(64) DEFAULT '' COMMENT '创建者',
    `create_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `update_by` VARCHAR(64) DEFAULT '' COMMENT '更新者',
    `update_time` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `remark` VARCHAR(500) DEFAULT NULL COMMENT '备注',
    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='字典数据表';

-- ----------------------------
-- 操作日志表
-- ----------------------------
DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log` (
    `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '日志主键',
    `title` VARCHAR(50) DEFAULT '' COMMENT '模块标题',
    `business_type` TINYINT DEFAULT 0 COMMENT '业务类型（0-其他 1-新增 2-修改 3-删除）',
    `method` VARCHAR(200) DEFAULT '' COMMENT '方法名称',
    `request_method` VARCHAR(10) DEFAULT '' COMMENT '请求方式',
    `oper_name` VARCHAR(50) DEFAULT '' COMMENT '操作人员',
    `oper_url` VARCHAR(500) DEFAULT '' COMMENT '请求URL',
    `oper_ip` VARCHAR(128) DEFAULT '' COMMENT '主机地址',
    `oper_param` VARCHAR(2000) DEFAULT '' COMMENT '请求参数',
    `json_result` VARCHAR(2000) DEFAULT '' COMMENT '返回参数',
    `status` TINYINT DEFAULT 1 COMMENT '操作状态（0-异常 1-正常）',
    `error_msg` VARCHAR(2000) DEFAULT '' COMMENT '错误消息',
    `oper_time` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
    `cost_time` BIGINT DEFAULT 0 COMMENT '消耗时间',
    PRIMARY KEY (`id`),
    KEY `idx_oper_time` (`oper_time`)
) ENGINE=InnoDB AUTO_INCREMENT=100 COMMENT='操作日志记录';

-- ----------------------------
-- 初始化数据
-- ----------------------------

-- 初始化角色
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'admin', 1, 1, 0, 'admin', NOW(), '', NULL, '超级管理员');
INSERT INTO `sys_role` VALUES (2, '普通用户', 'user', 2, 1, 0, 'admin', NOW(), '', NULL, '普通用户');
INSERT INTO `sys_role` VALUES (3, '教师', 'teacher', 3, 1, 0, 'admin', NOW(), '', NULL, '教师角色');
INSERT INTO `sys_role` VALUES (4, '学生', 'student', 4, 1, 0, 'admin', NOW(), '', NULL, '学生角色');

-- 初始化用户（密码：admin123，BCrypt加密）
INSERT INTO `sys_user` VALUES (1, 'admin', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '管理员', '管理员', '', 'admin@sap.com', '13800138000', 1, '', '', '', '', 1, 0, '', NULL, 'admin', NOW(), '', NULL, '管理员');
INSERT INTO `sys_user` VALUES (2, 'student', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '张三', '张三', '2024001', 'zhangsan@sap.com', '13800138001', 1, '', '计算机学院', '软件工程', '软件2401', 1, 0, '', NULL, 'admin', NOW(), '', NULL, '学生');
INSERT INTO `sys_user` VALUES (3, 'teacher', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '李老师', '李明', '', 'teacher@sap.com', '13800138002', 1, '', '计算机学院', '', '', 1, 0, '', NULL, 'admin', NOW(), '', NULL, '教师');

-- 用户角色关联
INSERT INTO `sys_user_role` VALUES (1, 1);
INSERT INTO `sys_user_role` VALUES (2, 4);
INSERT INTO `sys_user_role` VALUES (3, 3);

-- 初始化菜单
INSERT INTO `sys_menu` VALUES (1, '系统管理', 0, 1, 'system', '', '', 1, 0, 'M', 0, 1, '', 'system', 'admin', NOW(), '', NULL, '系统管理目录');
INSERT INTO `sys_menu` VALUES (100, '用户管理', 1, 1, 'user', 'system/user/index', '', 1, 0, 'C', 0, 1, 'system:user:list', 'user', 'admin', NOW(), '', NULL, '用户管理菜单');
INSERT INTO `sys_menu` VALUES (101, '角色管理', 1, 2, 'role', 'system/role/index', '', 1, 0, 'C', 0, 1, 'system:role:list', 'peoples', 'admin', NOW(), '', NULL, '角色管理菜单');
INSERT INTO `sys_menu` VALUES (102, '菜单管理', 1, 3, 'menu', 'system/menu/index', '', 1, 0, 'C', 0, 1, 'system:menu:list', 'tree-table', 'admin', NOW(), '', NULL, '菜单管理菜单');
INSERT INTO `sys_menu` VALUES (103, '字典管理', 1, 4, 'dict', 'system/dict/index', '', 1, 0, 'C', 0, 1, 'system:dict:list', 'dict', 'admin', NOW(), '', NULL, '字典管理菜单');
INSERT INTO `sys_menu` VALUES (1000, '用户查询', 100, 1, '', '', '', 1, 0, 'F', 0, 1, 'system:user:query', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (1001, '用户新增', 100, 2, '', '', '', 1, 0, 'F', 0, 1, 'system:user:add', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (1002, '用户修改', 100, 3, '', '', '', 1, 0, 'F', 0, 1, 'system:user:edit', '#', 'admin', NOW(), '', NULL, '');
INSERT INTO `sys_menu` VALUES (1003, '用户删除', 100, 4, '', '', '', 1, 0, 'F', 0, 1, 'system:user:remove', '#', 'admin', NOW(), '', NULL, '');

-- 角色菜单关联（管理员拥有所有菜单）
INSERT INTO `sys_role_menu` SELECT 1, id FROM `sys_menu`;

-- 初始化字典类型
INSERT INTO `sys_dict_type` VALUES (1, '用户性别', 'sys_user_sex', 1, 'admin', NOW(), '', NULL, '用户性别列表');
INSERT INTO `sys_dict_type` VALUES (2, '系统状态', 'sys_normal_disable', 1, 'admin', NOW(), '', NULL, '系统状态列表');
INSERT INTO `sys_dict_type` VALUES (3, '业务状态', 'sys_business_type', 1, 'admin', NOW(), '', NULL, '业务状态列表');

-- 初始化字典数据
INSERT INTO `sys_dict_data` VALUES (1, 1, '男', '0', 'sys_user_sex', '', '', 'Y', 1, 'admin', NOW(), '', NULL, '性别男');
INSERT INTO `sys_dict_data` VALUES (2, 2, '女', '1', 'sys_user_sex', '', '', 'N', 1, 'admin', NOW(), '', NULL, '性别女');
INSERT INTO `sys_dict_data` VALUES (3, 1, '正常', '0', 'sys_normal_disable', '', '', 'Y', 1, 'admin', NOW(), '', NULL, '正常状态');
INSERT INTO `sys_dict_data` VALUES (4, 2, '禁用', '1', 'sys_normal_disable', '', '', 'N', 1, 'admin', NOW(), '', NULL, '禁用状态');
