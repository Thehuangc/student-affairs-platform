package com.sap.auth.service;

import com.sap.auth.dto.LoginDTO;
import com.sap.auth.dto.RegisterDTO;
import com.sap.auth.vo.LoginVO;

/**
 * 认证服务接口
 */
public interface AuthService {

    /**
     * 用户登录
     */
    LoginVO login(LoginDTO dto);

    /**
     * 用户注册
     */
    void register(RegisterDTO dto);

    /**
     * 退出登录
     */
    void logout(String token);

    /**
     * 刷新Token
     */
    LoginVO refreshToken(String token);
}
