package com.sap.volunteer.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sap.volunteer.domain.VolVolunteer;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * 志愿者Mapper接口
 */
@Mapper
public interface VolVolunteerMapper extends BaseMapper<VolVolunteer> {

    /**
     * 根据用户ID查询志愿者
     */
    @Select("SELECT * FROM vol_volunteer WHERE user_id = #{userId} AND status = 1")
    VolVolunteer selectByUserId(@Param("userId") Long userId);

    /**
     * 查询志愿时长排行榜
     */
    @Select("SELECT * FROM vol_volunteer WHERE status = 1 ORDER BY total_hours DESC LIMIT #{limit}")
    List<VolVolunteer> selectTopByHours(@Param("limit") Integer limit);
}
