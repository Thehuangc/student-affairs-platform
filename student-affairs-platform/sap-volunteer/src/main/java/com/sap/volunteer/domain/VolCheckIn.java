package com.sap.volunteer.domain;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 签到打卡实体类
 */
@Data
@TableName("vol_check_in")
public class VolCheckIn {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 活动ID
     */
    private Long activityId;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 姓名
     */
    private String realName;

    /**
     * 签到时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime checkInTime;

    /**
     * 签退时间
     */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime checkOutTime;

    /**
     * 签到地点
     */
    private String checkInLocation;

    /**
     * 签到纬度
     */
    private BigDecimal checkInLat;

    /**
     * 签到经度
     */
    private BigDecimal checkInLng;

    /**
     * 时长（小时）
     */
    private BigDecimal duration;

    /**
     * 状态（0-待核算 1-已核算 2-已驳回）
     */
    private Integer status;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}
