package com.forum;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@MapperScan("com.forum.mapper")
@EnableAsync
public class ForumApplication {

    public static void main(String[] args) {
        SpringApplication.run(ForumApplication.class, args);
        System.out.println("========================================");
        System.out.println("  社区论坛系统后端服务启动成功!");
        System.out.println("  http://localhost:8080");
        System.out.println("========================================");
    }
}
