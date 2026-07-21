package com.sap.volunteer.controller;

import com.sap.common.core.domain.PageResult;
import com.sap.common.core.domain.R;
import com.sap.volunteer.domain.VolActivity;
import com.sap.volunteer.dto.ActivityQueryDTO;
import com.sap.volunteer.dto.CheckInDTO;
import com.sap.volunteer.service.VolActivityService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 志愿活动控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/volunteer/activity")
@Tag(name = "志愿活动管理", description = "志愿活动的增删改查、报名、签到等接口")
public class VolActivityController {

    @Autowired
    private VolActivityService activityService;

    /**
     * 分页查询活动列表
     */
    @GetMapping("/page")
    @Operation(summary = "分页查询活动列表")
    public R<PageResult<VolActivity>> getActivityPage(ActivityQueryDTO query) {
        PageResult<VolActivity> result = activityService.getActivityPage(query);
        return R.ok(result);
    }

    /**
     * 获取活动详情
     */
    @GetMapping("/{id}")
    @Operation(summary = "获取活动详情")
    public R<VolActivity> getActivityDetail(@PathVariable Long id) {
        VolActivity activity = activityService.getActivityDetail(id);
        return R.ok(activity);
    }

    /**
     * 创建活动
     */
    @PostMapping
    @Operation(summary = "创建活动")
    public R<Void> createActivity(@Valid @RequestBody VolActivity activity) {
        activityService.createActivity(activity);
        return R.ok("创建成功");
    }

    /**
     * 更新活动
     */
    @PutMapping
    @Operation(summary = "更新活动")
    public R<Void> updateActivity(@Valid @RequestBody VolActivity activity) {
        activityService.updateActivity(activity);
        return R.ok("更新成功");
    }

    /**
     * 取消活动
     */
    @DeleteMapping("/{id}")
    @Operation(summary = "取消活动")
    public R<Void> cancelActivity(@PathVariable Long id) {
        activityService.cancelActivity(id);
        return R.ok("取消成功");
    }

    /**
     * 报名活动
     */
    @PostMapping("/{activityId}/enroll")
    @Operation(summary = "报名活动")
    public R<Void> enrollActivity(@PathVariable Long activityId, @RequestParam Long userId) {
        activityService.enrollActivity(activityId, userId);
        return R.ok("报名成功");
    }

    /**
     * 取消报名
     */
    @DeleteMapping("/{activityId}/enroll")
    @Operation(summary = "取消报名")
    public R<Void> cancelEnroll(@PathVariable Long activityId, @RequestParam Long userId) {
        activityService.cancelEnroll(activityId, userId);
        return R.ok("取消报名成功");
    }

    /**
     * 签到
     */
    @PostMapping("/check-in")
    @Operation(summary = "签到")
    public R<Void> checkIn(@Valid @RequestBody CheckInDTO dto) {
        activityService.checkIn(dto);
        return R.ok("签到成功");
    }

    /**
     * 签退
     */
    @PostMapping("/{activityId}/check-out")
    @Operation(summary = "签退")
    public R<Void> checkOut(@PathVariable Long activityId, @RequestParam Long userId) {
        activityService.checkOut(activityId, userId);
        return R.ok("签退成功");
    }

    /**
     * 获取用户参与的活动
     */
    @GetMapping("/user/{userId}")
    @Operation(summary = "获取用户参与的活动")
    public R<List<VolActivity>> getUserActivities(@PathVariable Long userId) {
        List<VolActivity> activities = activityService.getUserActivities(userId);
        return R.ok(activities);
    }

    /**
     * 测试接口
     */
    @GetMapping("/test")
    @Operation(summary = "测试接口")
    public R<String> test() {
        return R.ok("志愿服务正常运行");
    }
}
