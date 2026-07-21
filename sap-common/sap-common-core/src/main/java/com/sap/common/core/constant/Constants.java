package com.sap.common.core.constant;

/**
 * 通用常量
 */
public class Constants {

    /**
     * UTF-8 字符集
     */
    public static final String UTF8 = "UTF-8";

    /**
     * 成功标记
     */
    public static final int SUCCESS = 200;

    /**
     * 失败标记
     */
    public static final int FAIL = 500;

    /**
     * 登录成功
     */
    public static final String LOGIN_SUCCESS = "Success";

    /**
     * 注销
     */
    public static final String LOGOUT = "Logout";

    /**
     * 注册
     */
    public static final String REGISTER = "Register";

    /**
     * 登录失败
     */
    public static final String LOGIN_FAIL = "Error";

    /**
     * 令牌
     */
    public static final String TOKEN = "token";

    /**
     * 令牌前缀
     */
    public static final String TOKEN_PREFIX = "Bearer ";

    /**
     * 令牌前缀
     */
    public static final String LOGIN_USER_KEY = "login_user_key";

    /**
     * 用户ID
     */
    public static final String JWT_USERID = "userid";

    /**
     * 用户名称
     */
    public static final String JWT_USERNAME = "sub";

    /**
     * 用户头像
     */
    public static final String JWT_AVATAR = "avatar";

    /**
     * 创建时间
     */
    public static final String JWT_CREATED = "created";

    /**
     * 用户权限
     */
    public static final String JWT_AUTHORITIES = "authorities";

    /**
     * 资源映射路径 前缀
     */
    public static final String RESOURCE_PREFIX = "/profile";

    /**
     * 自动识别json对象白名单配置（仅允许解析的包名）
     */
    public static final String[] JSON_WHITELIST_STR = {"org.apache.commons.lang3"};

    /**
     * 定时任务白名单配置（仅允许访问的包名）
     */
    public static final String[] JOB_WHITELIST_STR = {"com.sap"};

    /**
     * 定时任务违规的字符
     */
    public static final String[] JOB_ERROR_STR = {"java.net.URL", "javax.naming.InitialContext", "org.yaml.snakeyaml",
            "org.springframework", "org.apache", "com.sap.common.core.utils.file"};

    /**
     * 年-月-日 时:分:秒
     */
    public static final String YYYY_MM_DD_HH_MM_SS = "yyyy-MM-dd HH:mm:ss";

    /**
     * 年-月-日
     */
    public static final String YYYY_MM_DD = "yyyy-MM-dd";

    /**
     * 月-日
     */
    public static final String MM_DD = "MM-dd";

    /**
     * 时:分:秒
     */
    public static final String HH_MM_SS = "HH:mm:ss";

    /**
     * 所有权限标识
     */
    public static final String ALL_PERMISSION = "*:*:*";

    /**
     * 管理员角色权限
     */
    public static final String SUPER_ADMIN = "admin";

    /**
     * 角色权限字符串分隔符号
     */
    public static final String ROLE_DELIM = ",";

    /**
     * 登录用户
     */
    public static final String LOGIN_TOKEN = "login_tokens:";
}
