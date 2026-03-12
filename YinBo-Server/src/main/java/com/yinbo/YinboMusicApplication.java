package com.yinbo;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
@MapperScan("com.yinbo.mapper")
public class YinboMusicApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(YinboMusicApplication.class, args);
    }
}
