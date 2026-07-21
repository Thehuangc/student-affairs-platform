package com.sap.controller;

import com.sap.model.LoginRequest;
import com.sap.model.LoginResponse;
import com.sap.model.Result;
import com.sap.util.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private JwtUtil jwtUtil;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    // 简单的内存用户存储（生产环境应使用数据库）
    private static final Map<String, User> USERS = new ConcurrentHashMap<>();

    static {
        // 初始化默认用户
        USERS.put("admin", new User(1L, "admin", "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi", "管理员", "admin"));
        USERS.put("student", new User(2L, "student", "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi", "张三", "student"));
        USERS.put("teacher", new User(3L, "teacher", "$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBOsl7iKTVKIUi", "李老师", "teacher"));
    }

    @PostMapping("/login")
    public Result<LoginResponse> login(@RequestBody LoginRequest request) {
        User user = USERS.get(request.getUsername());

        if (user == null) {
            return Result.fail("用户不存在");
        }

        // 验证密码（默认密码：admin123）
        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            return Result.fail("密码错误");
        }

        // 生成Token
        String token = jwtUtil.createToken(user.getId(), user.getUsername(), user.getNickname());

        // 构建响应
        LoginResponse response = LoginResponse.builder()
                .token(token)
                .expiresIn(jwtUtil.getExpiration())
                .userId(user.getId())
                .username(user.getUsername())
                .nickname(user.getNickname())
                .avatar("")
                .roles(new HashSet<>(Arrays.asList(user.getRole())))
                .permissions(new HashSet<>(Arrays.asList("*:*:*")))
                .build();

        return Result.ok(response, "登录成功");
    }

    @PostMapping("/register")
    public Result<Void> register(@RequestBody LoginRequest request) {
        if (USERS.containsKey(request.getUsername())) {
            return Result.fail("用户名已存在");
        }

        Long newId = USERS.size() + 1L;
        String encodedPassword = passwordEncoder.encode(request.getPassword());
        User newUser = new User(newId, request.getUsername(), encodedPassword, request.getUsername(), "user");

        USERS.put(request.getUsername(), newUser);

        return Result.ok(null, "注册成功");
    }

    @PostMapping("/logout")
    public Result<Void> logout(@RequestHeader(value = "Authorization", required = false) String authorization) {
        return Result.ok(null, "退出成功");
    }

    @GetMapping("/test")
    public Result<String> test() {
        return Result.ok("认证服务正常运行");
    }

    // 内部用户类
    private static class User {
        private Long id;
        private String username;
        private String password;
        private String nickname;
        private String role;

        public User(Long id, String username, String password, String nickname, String role) {
            this.id = id;
            this.username = username;
            this.password = password;
            this.nickname = nickname;
            this.role = role;
        }

        public Long getId() { return id; }
        public String getUsername() { return username; }
        public String getPassword() { return password; }
        public String getNickname() { return nickname; }
        public String getRole() { return role; }
    }
}
