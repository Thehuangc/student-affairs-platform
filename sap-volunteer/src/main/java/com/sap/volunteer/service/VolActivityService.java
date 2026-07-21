package com.sap.volunteer.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.sap.common.core.domain.PageResult;
import com.sap.volunteer.domain.VolActivity;
import com.sap.volunteer.dto.ActivityQueryDTO;
import com.sap.volunteer.dto.CheckInDTO;

import java.util.List;

/**
 * 志愿活动服务接口
 */
public interface VolActivityService extends IService<VolActivity> {

    /**
     * 分页查询活动列表
     */
    PageResult<VolActivity> getActivityPage(ActivityQueryDTO query);

    /**
     * 获取活动详情
     */
    VolActivity getActivityDetail(Long id);

    /**
     * 创建活动
     */
    void createActivity(VolActivity activity);

    /**
     * 更新活动
     */
    void updateActivity(VolActivity activity);

    /**
     * 取消活动
     */
    void cancelActivity(Long id);

    /**
     * 报名活动
     */
    void enrollActivity(Long activityId, Long userId);

    /**
     * 取消报名
     */
    void cancelEnroll(Long activityId, Long userId);

    /**
     * 签到
     */
    void checkIn(CheckInDTO dto);

    /**
     * 签退
     */
    void checkOut(Long activityId, Long userId);

    /**
     * 获取用户参与的活动列表
     */
    List<VolActivity> getUserActivities(Long userId);
}
