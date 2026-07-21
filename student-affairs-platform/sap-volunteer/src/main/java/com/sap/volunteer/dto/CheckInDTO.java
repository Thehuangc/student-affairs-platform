package com.sap.volunteer.dto;

import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

/**
 * 签到请求DTO
 */
@Data
public class CheckInDTO {

    @NotNull(message = "活动ID不能为空")
    private Long activityId;

    @NotNull(message = "用户ID不能为空")
    private Long userId;

    /**
     * 姓名
     */
    private String realName;

    /**
     * 签到码
     */
    private String checkInCode;

    /**
     * 签到地点
     */
    private String location;

    /**
     * 纬度
     */
    private BigDecimal lat;

    /**
     * 经度
     */
    private BigDecimal lng;
}
