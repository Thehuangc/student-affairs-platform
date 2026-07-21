package com.sap.volunteer.dto;

import lombok.Data;

/**
 * 活动查询DTO
 */
@Data
public class ActivityQueryDTO {

    /**
     * 活动标题
     */
    private String title;

    /**
     * 活动类型
     */
    private String activityType;

    /**
     * 状态
     */
    private Integer status;

    /**
     * 页码
     */
    private Integer pageNum = 1;

    /**
     * 每页数量
     */
    private Integer pageSize = 10;
}
