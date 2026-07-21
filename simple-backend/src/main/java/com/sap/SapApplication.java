package com.sap;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class SapApplication {
    public static void main(String[] args) {
        SpringApplication.run(SapApplication.class, args);
        System.out.println("==========================================");
        System.out.println("       学生综合事务中台 - 网关服务启动成功！");
        System.out.println("==========================================");
    }
}
