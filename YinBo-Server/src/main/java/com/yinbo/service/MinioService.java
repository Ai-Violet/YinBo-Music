package com.yinbo.service;

import java.io.InputStream;
import org.springframework.web.multipart.MultipartFile;

public interface MinioService {
    
    void createBucket(String bucketName);
    
    String uploadMusic(MultipartFile file);
    
    String uploadCover(MultipartFile file);
    
    String uploadAvatar(MultipartFile file);
    
    String uploadLyrics(MultipartFile file);
    
    String uploadSingerAvatar(MultipartFile file);
    
    String getLyricsUrl(String objectName);
    
    String getSingerAvatarUrl(String objectName);
    
    String getPresignedUrl(String bucketName, String objectName, int expiryHours);
    
    String getMusicUrl(String objectName);
    
    String getCoverUrl(String objectName);
    
    String getAvatarUrl(String objectName);
    
    void deleteFile(String bucketName, String objectName);
    
    boolean fileExists(String bucketName, String objectName);
    
    String getMainBucket();
    
    /**
     * Get file stream from MinIO
     */
    InputStream getFileStream(String bucketName, String objectName);
}
