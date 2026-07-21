package com.sap.common.core.context;

import com.sap.common.core.domain.LoginUser;

/**
 * 权限认证 - 用户上下文
 */
public class SecurityContextHolder {

    private static final ThreadLocal<LoginUser> USER_HOLDER = new ThreadLocal<>();

    /**
     * 设置用户
     */
    public static void setLoginUser(LoginUser loginUser) {
        USER_HOLDER.set(loginUser);
    }

    /**
     * 获取用户
     */
    public static LoginUser getLoginUser() {
        return USER_HOLDER.get();
    }

    /**
     * 获取用户ID
     */
    public static Long getUserId() {
        LoginUser loginUser = getLoginUser();
        if (loginUser != null) {
            return loginUser.getUserId();
        }
        return null;
    }

    /**
     * 获取用户名
     */
    public static String getUsername() {
        LoginUser loginUser = getLoginUser();
        if (loginUser != null) {
            return loginUser.getUsername();
        }
        return null;
    }

    /**
     * 清除用户
     */
    public static void clear() {
        USER_HOLDER.remove();
    }
}
