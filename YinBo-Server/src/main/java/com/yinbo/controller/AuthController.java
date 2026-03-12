package com.yinbo.controller;

import com.yinbo.common.Result;
import com.yinbo.dto.LoginRequest;
import com.yinbo.dto.RegisterRequest;
import com.yinbo.dto.UserDTO;
import com.yinbo.entity.User;
import com.yinbo.service.MinioService;
import com.yinbo.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

@Slf4j
@Tag(name = "Auth API", description = "User authentication endpoints")
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {
    
    private final UserService userService;
    private final MinioService minioService;
    
    @Operation(summary = "User registration")
    @PostMapping("/register")
    public Result<UserDTO> register(@Valid @RequestBody RegisterRequest request) {
        // Admin secret key for admin registration
        String adminSecretKey = "yinbo";
        boolean isAdmin = adminSecretKey.equals(request.getAdminKey());
        
        User user = userService.register(
            request.getUsername(), 
            request.getEmail(), 
            request.getPassword(),
            isAdmin
        );
        return Result.success("Registration successful", toDTO(user));
    }
    
    @Operation(summary = "User login")
    @PostMapping("/login")
    public Result<LoginResponse> login(@Valid @RequestBody LoginRequest request) {
        String token = userService.login(request.getUsername(), request.getPassword());
        User user = userService.getByUsername(request.getUsername());
        
        LoginResponse response = new LoginResponse();
        response.setToken(token);
        response.setUser(toDTO(user));
        
        return Result.success("Login successful", response);
    }
    
    @Operation(summary = "Check if username exists and get avatar (for login form preview)")
    @GetMapping("/check-username")
    public Result<UsernameCheckResponse> checkUsername(@RequestParam String username) {
        try {
            if (!StringUtils.hasText(username) || username.trim().length() < 2) {
                return Result.success(new UsernameCheckResponse(false, null));
            }
            User user = userService.getByUsername(username.trim());
            if (user == null) {
                return Result.success(new UsernameCheckResponse(false, null));
            }
            String avatarUrl = null;
            if (StringUtils.hasText(user.getAvatar())) {
                try {
                    avatarUrl = minioService.getAvatarUrl(user.getAvatar());
                } catch (Exception e) {
                    log.debug("check-username MinIO 获取头像失败: username={} avatar={}", username, user.getAvatar(), e);
                }
            }
            return Result.success(new UsernameCheckResponse(true, avatarUrl));
        } catch (Throwable e) {
            log.warn("check-username 异常: username={} error={}", username, e.getMessage(), e);
            return Result.success(new UsernameCheckResponse(false, null));
        }
    }
    
    @Operation(summary = "Refresh token")
    @PostMapping("/refresh")
    public Result<String> refreshToken(@RequestHeader("Authorization") String token) {
        String newToken = userService.refreshToken(token);
        return Result.success(newToken);
    }
    
    private UserDTO toDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setUsername(user.getUsername());
        dto.setEmail(user.getEmail());
        dto.setRole(user.getRole());
        dto.setNickname(user.getNickname());
        dto.setSignature(user.getSignature());
        if (user.getAvatar() != null && !user.getAvatar().isEmpty()) {
            dto.setAvatar(minioService.getAvatarUrl(user.getAvatar()));
        }
        return dto;
    }
    
    @Data
    public static class LoginResponse {
        private String token;
        private UserDTO user;
    }
    
    @Data
    public static class UsernameCheckResponse {
        private boolean exists;
        private String avatar;
        public UsernameCheckResponse(boolean exists, String avatar) {
            this.exists = exists;
            this.avatar = avatar;
        }
    }
}