package com.yinbo.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.yinbo.dto.LoginResult;
import com.yinbo.dto.RegisterRequest;
import com.yinbo.entity.User;

public interface UserService extends IService<User> {

    User getByUsername(String username);

    User getByEmail(String email);

    User registerWithVerification(RegisterRequest request);

    LoginResult loginWithUser(String account, String password);

    String refreshToken(String token);

    User updateUserInfo(Long userId, User userInfo);

    void changePassword(Long userId, String oldPassword, String newPassword);

    IPage<User> getUserList(int page, int size, String keyword);

    void updateStatus(Long userId, Integer status);

    User updateAvatar(Long userId, String avatarUrl);
}
