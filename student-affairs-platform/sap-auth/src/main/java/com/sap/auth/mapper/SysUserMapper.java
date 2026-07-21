package com.sap.auth.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sap.auth.domain.SysUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Set;

/**
 * 用户Mapper接口
 */
@Mapper
public interface SysUserMapper extends BaseMapper<SysUser> {

    /**
     * 根据用户名查询用户
     */
    @Select("SELECT * FROM sys_user WHERE username = #{username} AND del_flag = 0")
    SysUser selectByUsername(@Param("username") String username);

    /**
     * 根据学号查询用户
     */
    @Select("SELECT * FROM sys_user WHERE student_no = #{studentNo} AND del_flag = 0")
    SysUser selectByStudentNo(@Param("studentNo") String studentNo);

    /**
     * 查询用户角色Key集合
     */
    @Select("SELECT r.role_key FROM sys_role r " +
            "LEFT JOIN sys_user_role ur ON r.id = ur.role_id " +
            "WHERE ur.user_id = #{userId} AND r.status = 1")
    Set<String> selectRoleKeysByUserId(@Param("userId") Long userId);

    /**
     * 查询用户权限集合
     */
    @Select("SELECT DISTINCT m.perms FROM sys_menu m " +
            "LEFT JOIN sys_role_menu rm ON m.id = rm.menu_id " +
            "LEFT JOIN sys_user_role ur ON rm.role_id = ur.role_id " +
            "WHERE ur.user_id = #{userId} AND m.status = 1 AND m.perms != ''")
    Set<String> selectPermsByUserId(@Param("userId") Long userId);
}
