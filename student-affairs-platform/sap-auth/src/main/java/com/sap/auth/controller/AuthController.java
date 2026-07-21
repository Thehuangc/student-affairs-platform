package com.sap.auth.controller;

import com.sap.auth.dto.LoginDTO;
import com.sap.auth.dto.RegisterDTO;
import com.sap.auth.service.AuthService;
import com.sap.auth.vo.LoginVO;
import com.sap.common.core.domain.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 认证控制器
 */
@Slf4j
@RestController
@RequestMapping("/api/auth")
@Tag(name = "认证管理", description = "登录、注册、退出等接口")
public class AuthController {

    @Autowired
    private AuthService authService;

    /**
     * 用户登录
     */
    @PostMapping("/login")
    @Operation(summary = "用户登录", description = "用户名密码登录")
    public R<LoginVO> login(@Valid @RequestBody LoginDTO dto) {
        LoginVO loginVO = authService.login(dto);
        return R.ok(loginVO, "登录成功");
    }

    /**
     * 用户注册
     */
    @PostMapping("/register")
    @Operation(summary = "用户注册", description = "新用户注册")
    public R<Void> register(@Valid @RequestBody RegisterDTO dto) {
        authService.register(dto);
        return R.ok("注册成功");
    }

    /**
     * 退出登录
     */
    @PostMapping("/logout")
    @Operation(summary = "退出登录", description = "用户退出登录")
    public R<Void> logout(@RequestHeader(value = "Authorization", required = false) String authorization) {
        if (authorization != null && authorization.startsWith("Bearer ")) {
            String token = authorization.substring(7);
            authService.logout(token);
        }
        return R.ok("退出成功");
    }

    /**
     * 刷新Token
     */
    @PostMapping("/refresh")
    @Operation(summary = "刷新Token", description = "刷新用户Token")
    public R<LoginVO> refresh(@RequestHeader("Authorization") String authorization) {
        String token = authorization.substring(7);
        LoginVO loginVO = authService.refreshToken(token);
        return R.ok(loginVO, "刷新成功");
    }

    /**
     * 测试接口
     */
    @GetMapping("/test")
    @Operation(summary = "测试接口", description = "用于测试服务是否正常")
    public R<String> test() {
        return R.ok("认证服务正常运行");
    }
}
