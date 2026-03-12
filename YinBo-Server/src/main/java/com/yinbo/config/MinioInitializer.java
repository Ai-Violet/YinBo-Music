package com.yinbo.config;

import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.SetBucketPolicyArgs;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.io.ByteArrayInputStream;

@Slf4j
@Component
@RequiredArgsConstructor
public class MinioInitializer implements CommandLineRunner {
    
    private final MinioClient minioClient;
    private final MinioProperties minioProperties;
    
    @Override
    public void run(String... args) {
        String bucketName = minioProperties.getMainBucket();
        
        try {
            // Check if bucket exists
            boolean exists = minioClient.bucketExists(
                    io.minio.BucketExistsArgs.builder()
                            .bucket(bucketName)
                            .build()
            );
            
            if (!exists) {
                // Create bucket
                minioClient.makeBucket(
                        MakeBucketArgs.builder()
                                .bucket(bucketName)
                                .build()
                );
                log.info("Created MinIO bucket: {}", bucketName);
            } else {
                log.info("MinIO bucket already exists: {}", bucketName);
            }
            
            // Always set public read access policy (in case bucket exists but policy not set)
            String policy = """
                {
                    "Version": "2012-10-17",
                    "Statement": [
                        {
                            "Effect": "Allow",
                            "Principal": {"AWS": "*"},
                            "Action": ["s3:GetObject"],
                            "Resource": ["arn:aws:s3:::%s/*"]
                        }
                    ]
                }
                """.formatted(bucketName);
            
            minioClient.setBucketPolicy(
                    SetBucketPolicyArgs.builder()
                            .bucket(bucketName)
                            .config(policy)
                            .build()
            );
            log.info("Set MinIO bucket policy for public read access");
            
            // Create directory structure
            createDirectoryStructure(bucketName);
            
            log.info("MinIO initialization completed successfully!");
            log.info("MinIO Console: http://localhost:9005");
            log.info("MinIO API: http://localhost:9000");
            log.info("Bucket: {}", bucketName);
            
        } catch (Exception e) {
            log.error("MinIO initialization failed: {}", e.getMessage());
            log.info("Please ensure MinIO is running:");
            log.info("   1. Start MinIO: docker-compose up -d minio");
            log.info("   2. Or manually start MinIO server");
            log.info("   3. Access MinIO Console at: http://localhost:9005");
            log.info("   4. Login with: minio / 12345678");
        }
    }
    
    private void createDirectoryStructure(String bucketName) {
        String[] directories = {"music/", "cover/", "avatar/"};
        
        for (String dir : directories) {
            try {
                // Create empty file as directory marker
                minioClient.putObject(
                    PutObjectArgs.builder()
                        .bucket(bucketName)
                        .object(dir + ".gitkeep")
                        .stream(new ByteArrayInputStream(new byte[0]), 0, -1)
                        .build()
                );
                log.info("Created directory: {}", dir);
            } catch (Exception e) {
                log.debug("Directory may already exist: {} - {}", dir, e.getMessage());
            }
        }
    }
}