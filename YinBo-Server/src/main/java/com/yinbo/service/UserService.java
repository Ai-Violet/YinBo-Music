package com.yinbo.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.yinbo.entity.User;

public interface UserService extends IService<User> {
    
    User getByUsername(String username);
    
    User getByEmail(String email);
    
    User register(String username, String email, String password);
        
        User register(String username, String email, String password, boolean isAdmin);
    
    String login(String username, String password);
    
    String refreshToken(String token);
    
    User updateUserInfo(Long userId, User userInfo);
    
    void changePassword(Long userId, String oldPassword, String newPassword);
    
    IPage<User> getUserList(int page, int size, String keyword);
    
    void updateStatus(Long userId, Integer status);
    
    User updateAvatar(Long userId, String avatarUrl);
}