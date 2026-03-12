package com.yinbo.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "minio")
public class MinioProperties {
    private String endpoint;
    private String accessKey;
    private String secretKey;
    private BucketName bucketName;
    
    public String getMainBucket() {
        if (bucketName != null && bucketName.getMain() != null) {
            return bucketName.getMain().toLowerCase();
        }
        return "yinbomusic";
    }
    
    @Data
    public static class BucketName {
        private String main;
        private String music;
        private String cover;
        private String avatar;
    }
}