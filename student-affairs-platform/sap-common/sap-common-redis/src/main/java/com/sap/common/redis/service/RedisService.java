package com.sap.common.redis.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Component;

import java.util.Collection;
import java.util.concurrent.TimeUnit;

/**
 * Redis工具类
 */
@Component
public class RedisService {

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    /**
     * 缓存基本对象，Integer、String、实体类等
     */
    public <T> void setCacheObject(String key, T value) {
        redisTemplate.opsForValue().set(key, value);
    }

    /**
     * 缓存基本对象，Integer、String、实体类等
     */
    public <T> void setCacheObject(String key, T value, long timeout, TimeUnit timeUnit) {
        redisTemplate.opsForValue().set(key, value, timeout, timeUnit);
    }

    /**
     * 设置有效时间
     */
    public boolean expire(String key, long timeout) {
        return Boolean.TRUE.equals(redisTemplate.expire(key, timeout, TimeUnit.SECONDS));
    }

    /**
     * 设置有效时间
     */
    public boolean expire(String key, long timeout, TimeUnit unit) {
        return Boolean.TRUE.equals(redisTemplate.expire(key, timeout, unit));
    }

    /**
     * 获取有效时间
     */
    public long getExpire(String key) {
        return redisTemplate.getExpire(key);
    }

    /**
     * 判断key是否存在
     */
    public boolean hasKey(String key) {
        return Boolean.TRUE.equals(redisTemplate.hasKey(key));
    }

    /**
     * 获得缓存的基本对象
     */
    @SuppressWarnings("unchecked")
    public <T> T getCacheObject(String key) {
        ValueOperations<String, Object> operations = redisTemplate.opsForValue();
        return (T) operations.get(key);
    }

    /**
     * 删除单个对象
     */
    public boolean deleteObject(String key) {
        return Boolean.TRUE.equals(redisTemplate.delete(key));
    }

    /**
     * 删除集合对象
     */
    public long deleteObject(Collection<String> keys) {
        Long count = redisTemplate.delete(keys);
        return count != null ? count : 0;
    }

    /**
     * 增加（自增）
     */
    public long increment(String key) {
        Long value = redisTemplate.opsForValue().increment(key);
        return value != null ? value : 0;
    }

    /**
     * 增加（自增指定值）
     */
    public long increment(String key, long delta) {
        Long value = redisTemplate.opsForValue().increment(key, delta);
        return value != null ? value : 0;
    }

    /**
     * 获得缓存的基本对象列表
     */
    public Collection<String> keys(String pattern) {
        return redisTemplate.keys(pattern);
    }
}
