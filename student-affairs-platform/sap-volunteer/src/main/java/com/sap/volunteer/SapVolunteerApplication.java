package com.sap.volunteer;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * 志愿服务启动类
 */
@EnableScheduling
@EnableFeignClients
@EnableDiscoveryClient
@MapperScan("com.sap.volunteer.mapper")
@ComponentScan(basePackages = {"com.sap.volunteer", "com.sap.common"})
@SpringBootApplication
public class SapVolunteerApplication {

    public static void main(String[] args) {
        SpringApplication.run(SapVolunteerApplication.class, args);
        System.out.println("==========================================");
        System.out.println("       志愿服务启动成功！");
        System.out.println("==========================================");
    }
}
