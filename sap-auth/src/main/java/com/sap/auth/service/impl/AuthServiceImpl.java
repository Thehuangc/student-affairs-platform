package com.sap.auth.service.impl;

import com.sap.auth.domain.SysUser;
import com.sap.auth.dto.LoginDTO;
import com.sap.auth.dto.RegisterDTO;
import com.sap.auth.mapper.SysUserMapper;
import com.sap.auth.service.AuthService;
import com.sap.auth.util.JwtUtil;
import com.sap.auth.vo.LoginVO;
import com.sap.common.core.constant.Constants;
import com.sap.common.core.exception.BusinessException;
import com.sap.common.redis.service.RedisService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Set;
import java.util.concurrent.TimeUnit;

/**
 * 认证服务实现类
 */
@Slf4j
@Service
public class AuthServiceImpl implements AuthService {

    @Autowired
    private SysUserMapper userMapper;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private RedisService redisService;

    private final BCryptPasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    @Override
    public LoginVO login(LoginDTO dto) {
        // 查询用户
        SysUser user = userMapper.selectByUsername(dto.getUsername());
        if (user == null) {
            throw new BusinessException("用户不存在");
        }

        // 验证密码
        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new BusinessException("密码错误");
        }

        // 验证状态
        if (user.getStatus() != 1) {
            throw new BusinessException("账号已被禁用");
        }

        // 生成Token
        String token = jwtUtil.createToken(user);

        // 获取角色和权限
        Set<String> roles = userMapper.selectRoleKeysByUserId(user.getId());
        Set<String> permissions = userMapper.selectPermsByUserId(user.getId());

        // 如果是管理员，拥有所有权限
        if (roles.contains(Constants.SUPER_ADMIN)) {
            permissions.add(Constants.ALL_PERMISSION);
        }

        // 将Token存入Redis
        String tokenKey = Constants.LOGIN_TOKEN + token;
        redisService.setCacheObject(tokenKey, user.getId(), jwtUtil.getExpiration(), TimeUnit.SECONDS);

        // 更新登录信息
        user.setLoginDate(LocalDateTime.now());
        userMapper.updateById(user);

        // 构建返回结果
        return LoginVO.builder()
                .token(token)
                .expiresIn(jwtUtil.getExpiration())
                .userId(user.getId())
                .username(user.getUsername())
                .nickname(user.getNickname())
                .avatar(user.getAvatar())
                .roles(roles)
                .permissions(permissions)
                .build();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void register(RegisterDTO dto) {
        // 验证密码是否一致
        if (!dto.getPassword().equals(dto.getConfirmPassword())) {
            throw new BusinessException("两次输入的密码不一致");
        }

        // 验证用户名是否已存在
        SysUser existUser = userMapper.selectByUsername(dto.getUsername());
        if (existUser != null) {
            throw new BusinessException("用户名已存在");
        }

        // 验证学号是否已存在
        if (dto.getStudentNo() != null && !dto.getStudentNo().isEmpty()) {
            existUser = userMapper.selectByStudentNo(dto.getStudentNo());
            if (existUser != null) {
                throw new BusinessException("学号已被注册");
            }
        }

        // 创建用户
        SysUser user = new SysUser();
        user.setUsername(dto.getUsername());
        user.setPassword(passwordEncoder.encode(dto.getPassword()));
        user.setRealName(dto.getRealName());
        user.setStudentNo(dto.getStudentNo());
        user.setPhone(dto.getPhone());
        user.setEmail(dto.getEmail());
        user.setNickname(dto.getRealName());
        user.setStatus(1);
        user.setDelFlag(0);

        userMapper.insert(user);

        log.info("用户注册成功: {}", dto.getUsername());
    }

    @Override
    public void logout(String token) {
        if (token != null && !token.isEmpty()) {
            String tokenKey = Constants.LOGIN_TOKEN + token;
            redisService.deleteObject(tokenKey);
            log.info("用户退出登录");
        }
    }

    @Override
    public LoginVO refreshToken(String token) {
        // 解析旧Token
        Long userId = jwtUtil.getUserId(token);
        SysUser user = userMapper.selectById(userId);

        if (user == null || user.getStatus() != 1) {
            throw new BusinessException("用户不存在或已被禁用");
        }

        // 删除旧Token
        String oldTokenKey = Constants.LOGIN_TOKEN + token;
        redisService.deleteObject(oldTokenKey);

        // 生成新Token
        String newToken = jwtUtil.createToken(user);

        // 获取角色和权限
        Set<String> roles = userMapper.selectRoleKeysByUserId(user.getId());
        Set<String> permissions = userMapper.selectPermsByUserId(user.getId());

        if (roles.contains(Constants.SUPER_ADMIN)) {
            permissions.add(Constants.ALL_PERMISSION);
        }

        // 将新Token存入Redis
        String tokenKey = Constants.LOGIN_TOKEN + newToken;
        redisService.setCacheObject(tokenKey, user.getId(), jwtUtil.getExpiration(), TimeUnit.SECONDS);

        return LoginVO.builder()
                .token(newToken)
                .expiresIn(jwtUtil.getExpiration())
                .userId(user.getId())
                .username(user.getUsername())
                .nickname(user.getNickname())
                .avatar(user.getAvatar())
                .roles(roles)
                .permissions(permissions)
                .build();
    }
}
