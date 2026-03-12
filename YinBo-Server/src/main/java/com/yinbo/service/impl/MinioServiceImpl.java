package com.yinbo.service.impl;

import com.yinbo.config.MinioProperties;
import com.yinbo.service.MinioService;
import io.minio.*;
import io.minio.http.Method;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
@RequiredArgsConstructor
public class MinioServiceImpl implements MinioService {
    
    private final MinioClient minioClient;
    private final MinioProperties minioProperties;
    
    @Override
    public void createBucket(String bucketName) {
        try {
            boolean exists = minioClient.bucketExists(BucketExistsArgs.builder()
                    .bucket(bucketName)
                    .build());
            
            if (!exists) {
                minioClient.makeBucket(MakeBucketArgs.builder()
                        .bucket(bucketName)
                        .build());
                log.info("Created bucket: {}", bucketName);
            }
        } catch (Exception e) {
            log.error("Failed to create bucket: {}", bucketName, e);
            throw new RuntimeException("Failed to create bucket: " + e.getMessage());
        }
    }
    
    @Override
    public String uploadMusic(MultipartFile file) {
        return uploadFile(getMainBucket(), file, "music/");
    }
    
    @Override
    public String uploadCover(MultipartFile file) {
        return uploadFile(getMainBucket(), file, "cover/");
    }
    
    @Override
    public String uploadAvatar(MultipartFile file) {
        return uploadFile(getMainBucket(), file, "avatar/");
    }
    
    @Override
    public String uploadLyrics(MultipartFile file) {
        return uploadFile(getMainBucket(), file, "lyrics/");
    }
    
    @Override
    public String uploadSingerAvatar(MultipartFile file) {
        return uploadFile(getMainBucket(), file, "singer/");
    }
    
    @Override
    public String getLyricsUrl(String objectName) {
        return getPresignedUrl(getMainBucket(), objectName, 24);
    }
    
    @Override
    public String getSingerAvatarUrl(String objectName) {
        return getPresignedUrl(getMainBucket(), objectName, 24);
    }
    
    @Override
    public String getPresignedUrl(String bucketName, String objectName, int expiryHours) {
        try {
            return minioClient.getPresignedObjectUrl(GetPresignedObjectUrlArgs.builder()
                    .method(Method.GET)
                    .bucket(bucketName)
                    .object(objectName)
                    .expiry(expiryHours, TimeUnit.HOURS)
                    .build());
        } catch (Exception e) {
            log.error("Failed to get presigned URL for {}/{}", bucketName, objectName, e);
            throw new RuntimeException("Failed to get file URL: " + e.getMessage());
        }
    }
    
    @Override
    public String getMusicUrl(String objectName) {
        return getPresignedUrl(getMainBucket(), objectName, 24);
    }
    
    @Override
    public String getCoverUrl(String objectName) {
        return getPresignedUrl(getMainBucket(), objectName, 24);
    }
    
    @Override
    public String getAvatarUrl(String objectName) {
        return getPresignedUrl(getMainBucket(), objectName, 24);
    }
    
    @Override
    public void deleteFile(String bucketName, String objectName) {
        try {
            minioClient.removeObject(RemoveObjectArgs.builder()
                    .bucket(bucketName)
                    .object(objectName)
                    .build());
            log.info("Deleted file: {}/{}", bucketName, objectName);
        } catch (Exception e) {
            log.error("Failed to delete file: {}/{}", bucketName, objectName, e);
            throw new RuntimeException("Failed to delete file: " + e.getMessage());
        }
    }
    
    @Override
    public boolean fileExists(String bucketName, String objectName) {
        try {
            minioClient.statObject(StatObjectArgs.builder()
                    .bucket(bucketName)
                    .object(objectName)
                    .build());
            return true;
        } catch (Exception e) {
            return false;
        }
    }
    
    @Override
    public String getMainBucket() {
        return minioProperties.getMainBucket();
    }
    
    private String uploadFile(String bucketName, MultipartFile file, String folder) {
        createBucket(bucketName);
        
        String originalFilename = file.getOriginalFilename();
        String extension = originalFilename != null && originalFilename.contains(".")
                ? originalFilename.substring(originalFilename.lastIndexOf("."))
                : "";
        String objectName = folder + UUID.randomUUID() + extension;
        
        try (InputStream inputStream = file.getInputStream()) {
            minioClient.putObject(PutObjectArgs.builder()
                    .bucket(bucketName)
                    .object(objectName)
                    .stream(inputStream, file.getSize(), -1)
                    .contentType(file.getContentType())
                    .build());
            
            log.info("Uploaded file: {}/{}", bucketName, objectName);
            return objectName;
        } catch (Exception e) {
            log.error("Failed to upload file to {}/{}", bucketName, objectName, e);
            throw new RuntimeException("Failed to upload file: " + e.getMessage());
        }
    }
    
    @Override
    public InputStream getFileStream(String bucketName, String objectName) {
        try {
            return minioClient.getObject(
                GetObjectArgs.builder()
                    .bucket(bucketName)
                    .object(objectName)
                    .build()
            );
        } catch (Exception e) {
            log.error("Failed to get file stream from {}/{}", bucketName, objectName, e);
            throw new RuntimeException("Failed to get file: " + e.getMessage());
        }
    }
}