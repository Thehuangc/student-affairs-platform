package com.sap.volunteer.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 志愿者信息实体类
 */
@Data
@TableName("vol_volunteer")
public class VolVolunteer {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 姓名
     */
    private String realName;

    /**
     * 学号
     */
    private String studentNo;

    /**
     * 学院
     */
    private String college;

    /**
     * 专业
     */
    private String major;

    /**
     * 班级
     */
    private String className;

    /**
     * 联系电话
     */
    private String phone;

    /**
     * 累计志愿时长（小时）
     */
    private BigDecimal totalHours;

    /**
     * 本年度志愿时长
     */
    private BigDecimal thisYearHours;

    /**
     * 志愿者等级
     */
    private String level;

    /**
     * 状态（0-禁用 1-正常）
     */
    private Integer status;

    @TableField(fill = FieldFill.INSERT)
    private String createBy;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private String updateBy;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
