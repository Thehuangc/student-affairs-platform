package com.sap.auth.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 用户实体类
 */
@Data
@TableName("sys_user")
public class SysUser {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String username;

    private String password;

    private String nickname;

    private String realName;

    private String studentNo;

    private String email;

    private String phone;

    private Integer sex;

    private String avatar;

    private String college;

    private String major;

    private String className;

    private Integer status;

    @TableLogic
    private Integer delFlag;

    private String loginIp;

    private LocalDateTime loginDate;

    @TableField(fill = FieldFill.INSERT)
    private String createBy;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private String updateBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;

    private String remark;
}
