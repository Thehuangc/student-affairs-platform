package com.sap.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * 网关服务启动类
 */
@EnableDiscoveryClient
@SpringBootApplication
public class SapGatewayApplication {

    public static void main(String[] args) {
        SpringApplication.run(SapGatewayApplication.class, args);
        System.out.println("==========================================");
        System.out.println("       API网关服务启动成功！");
        System.out.println("==========================================");
    }
}
