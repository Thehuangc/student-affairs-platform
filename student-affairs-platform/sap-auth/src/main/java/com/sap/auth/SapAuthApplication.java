package com.sap.auth;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.ComponentScan;

/**
 * 认证服务启动类
 */
@EnableFeignClients
@EnableDiscoveryClient
@MapperScan("com.sap.auth.mapper")
@ComponentScan(basePackages = {"com.sap.auth", "com.sap.common"})
@SpringBootApplication
public class SapAuthApplication {

    public static void main(String[] args) {
        SpringApplication.run(SapAuthApplication.class, args);
        System.out.println("==========================================");
        System.out.println("       认证授权服务启动成功！");
        System.out.println("==========================================");
    }
}
