package com.sap.volunteer.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sap.volunteer.domain.VolCheckIn;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;
import java.util.List;

/**
 * 签到记录Mapper接口
 */
@Mapper
public interface VolCheckInMapper extends BaseMapper<VolCheckIn> {

    /**
     * 查询用户在指定活动的签到记录
     */
    @Select("SELECT * FROM vol_check_in WHERE activity_id = #{activityId} AND user_id = #{userId}")
    VolCheckIn selectByActivityAndUser(@Param("activityId") Long activityId, @Param("userId") Long userId);

    /**
     * 查询用户待核算的签到记录
     */
    @Select("SELECT * FROM vol_check_in WHERE user_id = #{userId} AND status = 0")
    List<VolCheckIn> selectPendingByUserId(@Param("userId") Long userId);

    /**
     * 统计用户某月的总志愿时长
     */
    @Select("SELECT COALESCE(SUM(duration), 0) FROM vol_check_in " +
            "WHERE user_id = #{userId} AND status = 1 " +
            "AND DATE_FORMAT(check_in_time, '%Y-%m') = #{month}")
    BigDecimal sumDurationByUserAndMonth(@Param("userId") Long userId, @Param("month") String month);
}
