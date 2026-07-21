package com.sap.common.mybatis.handler;

import com.baomidou.mybatisplus.core.handlers.MetaObjectHandler;
import com.sap.common.core.context.SecurityContextHolder;
import lombok.extern.slf4j.Slf4j;
import org.apache.ibatis.reflection.MetaObject;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;

/**
 * MyBatis Plus 自动填充处理器
 */
@Slf4j
@Component
public class AutoFillHandler implements MetaObjectHandler {

    @Override
    public void insertFill(MetaObject metaObject) {
        this.strictInsertFill(metaObject, "createTime", LocalDateTime.class, LocalDateTime.now());
        this.strictInsertFill(metaObject, "updateTime", LocalDateTime.class, LocalDateTime.now());
        String username = SecurityContextHolder.getUsername();
        this.strictInsertFill(metaObject, "createBy", String.class, username);
        this.strictInsertFill(metaObject, "updateBy", String.class, username);
    }

    @Override
    public void updateFill(MetaObject metaObject) {
        this.strictUpdateFill(metaObject, "updateTime", LocalDateTime.class, LocalDateTime.now());
        String username = SecurityContextHolder.getUsername();
        this.strictUpdateFill(metaObject, "updateBy", String.class, username);
    }
}
