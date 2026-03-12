package com.yinbo.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

import java.awt.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@Slf4j
@Component
public class StartupConfig implements ApplicationListener<ApplicationReadyEvent> {
    
    @Override
    public void onApplicationEvent(ApplicationReadyEvent event) {
        printBanner();
    }
    
    private void printBanner() {
        String banner = """
            
            
                                                     
                                Y i n B o - M u s i c   
                                
                                @ Ai XiangChao - 2026                                                              
            
            
            """;
        
        System.out.println(banner);
        System.out.println("    Author: AIXiangChao");
        System.out.println("    GitHub: https://github.com/YinBo-Music");
        System.out.println("    Time:   " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        System.out.println();
        System.out.println("    Server running at: http://localhost:8080/api");
        System.out.println("    Swagger API Doc:   http://localhost:8080/api/swagger-ui/index.html");
        System.out.println();
    }
}