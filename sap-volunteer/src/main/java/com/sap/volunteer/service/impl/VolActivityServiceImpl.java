package com.sap.volunteer.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sap.common.core.domain.PageResult;
import com.sap.common.core.exception.BusinessException;
import com.sap.volunteer.domain.VolActivity;
import com.sap.volunteer.domain.VolCheckIn;
import com.sap.volunteer.dto.ActivityQueryDTO;
import com.sap.volunteer.dto.CheckInDTO;
import com.sap.volunteer.mapper.VolActivityMapper;
import com.sap.volunteer.mapper.VolCheckInMapper;
import com.sap.volunteer.service.VolActivityService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

/**
 * 志愿活动服务实现类
 */
@Slf4j
@Service
public class VolActivityServiceImpl extends ServiceImpl<VolActivityMapper, VolActivity> implements VolActivityService {

    @Autowired
    private VolCheckInMapper checkInMapper;

    @Override
    public PageResult<VolActivity> getActivityPage(ActivityQueryDTO query) {
        LambdaQueryWrapper<VolActivity> wrapper = new LambdaQueryWrapper<>();

        if (query.getTitle() != null && !query.getTitle().isEmpty()) {
            wrapper.like(VolActivity::getTitle, query.getTitle());
        }
        if (query.getStatus() != null) {
            wrapper.eq(VolActivity::getStatus, query.getStatus());
        }
        if (query.getActivityType() != null && !query.getActivityType().isEmpty()) {
            wrapper.eq(VolActivity::getActivityType, query.getActivityType());
        }

        wrapper.orderByDesc(VolActivity::getCreateTime);

        Page<VolActivity> page = new Page<>(query.getPageNum(), query.getPageSize());
        Page<VolActivity> result = baseMapper.selectPage(page, wrapper);

        return new PageResult<>(result.getTotal(), result.getRecords(), result.getCurrent(), result.getSize());
    }

    @Override
    public VolActivity getActivityDetail(Long id) {
        VolActivity activity = baseMapper.selectById(id);
        if (activity == null) {
            throw new BusinessException("活动不存在");
        }
        return activity;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createActivity(VolActivity activity) {
        // 生成签到二维码
        activity.setCheckInCode(UUID.randomUUID().toString().replace("-", ""));
        activity.setCurrentParticipants(0);
        activity.setStatus(0); // 未开始
        baseMapper.insert(activity);
        log.info("创建志愿活动: {}", activity.getTitle());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateActivity(VolActivity activity) {
        VolActivity existing = baseMapper.selectById(activity.getId());
        if (existing == null) {
            throw new BusinessException("活动不存在");
        }
        if (existing.getStatus() >= 1) {
            throw new BusinessException("活动已开始，不能修改");
        }
        baseMapper.updateById(activity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancelActivity(Long id) {
        VolActivity activity = baseMapper.selectById(id);
        if (activity == null) {
            throw new BusinessException("活动不存在");
        }
        if (activity.getStatus() == 2) {
            throw new BusinessException("活动已结束，不能取消");
        }
        activity.setStatus(3); // 已取消
        baseMapper.updateById(activity);
        log.info("取消志愿活动: {}", activity.getTitle());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void enrollActivity(Long activityId, Long userId) {
        VolActivity activity = baseMapper.selectById(activityId);
        if (activity == null) {
            throw new BusinessException("活动不存在");
        }
        if (activity.getStatus() != 0) {
            throw new BusinessException("活动不在报名阶段");
        }
        if (activity.getCurrentParticipants() >= activity.getMaxParticipants()) {
            throw new BusinessException("报名人数已满");
        }

        // 检查是否已报名（这里简化处理，实际应该查询报名表）
        activity.setCurrentParticipants(activity.getCurrentParticipants() + 1);
        baseMapper.updateById(activity);

        log.info("用户{}报名活动{}", userId, activityId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cancelEnroll(Long activityId, Long userId) {
        VolActivity activity = baseMapper.selectById(activityId);
        if (activity == null) {
            throw new BusinessException("活动不存在");
        }
        if (activity.getStatus() != 0) {
            throw new BusinessException("活动不在报名阶段，不能取消");
        }

        activity.setCurrentParticipants(Math.max(0, activity.getCurrentParticipants() - 1));
        baseMapper.updateById(activity);

        log.info("用户{}取消报名活动{}", userId, activityId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void checkIn(CheckInDTO dto) {
        VolActivity activity = baseMapper.selectById(dto.getActivityId());
        if (activity == null) {
            throw new BusinessException("活动不存在");
        }
        if (activity.getStatus() != 1) {
            throw new BusinessException("活动未开始或已结束");
        }

        // 验证签到码
        if (!activity.getCheckInCode().equals(dto.getCheckInCode())) {
            throw new BusinessException("签到码错误");
        }

        // 检查是否已签到
        VolCheckIn existing = checkInMapper.selectByActivityAndUser(dto.getActivityId(), dto.getUserId());
        if (existing != null && existing.getCheckInTime() != null) {
            throw new BusinessException("已签到，请勿重复签到");
        }

        // 创建签到记录
        VolCheckIn checkIn = new VolCheckIn();
        checkIn.setActivityId(dto.getActivityId());
        checkIn.setUserId(dto.getUserId());
        checkIn.setRealName(dto.getRealName());
        checkIn.setCheckInTime(LocalDateTime.now());
        checkIn.setCheckInLocation(dto.getLocation());
        checkIn.setCheckInLat(dto.getLat());
        checkIn.setCheckInLng(dto.getLng());
        checkIn.setStatus(0); // 待核算

        checkInMapper.insert(checkIn);
        log.info("用户{}签到活动{}", dto.getUserId(), dto.getActivityId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void checkOut(Long activityId, Long userId) {
        VolCheckIn checkIn = checkInMapper.selectByActivityAndUser(activityId, userId);
        if (checkIn == null || checkIn.getCheckInTime() == null) {
            throw new BusinessException("未签到，不能签退");
        }
        if (checkIn.getCheckOutTime() != null) {
            throw new BusinessException("已签退，请勿重复操作");
        }

        LocalDateTime checkOutTime = LocalDateTime.now();
        checkIn.setCheckOutTime(checkOutTime);

        // 计算时长
        Duration duration = Duration.between(checkIn.getCheckInTime(), checkOutTime);
        BigDecimal hours = BigDecimal.valueOf(duration.toMinutes()).divide(BigDecimal.valueOf(60), 2, BigDecimal.ROUND_HALF_UP);
        checkIn.setDuration(hours);

        checkInMapper.updateById(checkIn);
        log.info("用户{}签退活动{}，时长{}小时", userId, activityId, hours);
    }

    @Override
    public List<VolActivity> getUserActivities(Long userId) {
        // 简化实现，实际应该通过报名表关联查询
        LambdaQueryWrapper<VolActivity> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(VolActivity::getStatus, 2) // 已结束
                .orderByDesc(VolActivity::getEndTime);
        return baseMapper.selectList(wrapper);
    }
}
