package com.yinbo.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.yinbo.config.JwtProperties;
import com.yinbo.entity.User;
import com.yinbo.mapper.UserMapper;
import com.yinbo.service.UserService;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserServiceImpl extends ServiceImpl<UserMapper, User> implements UserService {
    
    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtProperties jwtProperties;
    
    @Override
    public User getByUsername(String username) {
        return userMapper.selectOne(
                new LambdaQueryWrapper<User>()
                        .eq(User::getUsername, username)
                        .eq(User::getDeleted, 0)
        );
    }
    
    @Override
    public User getByEmail(String email) {
        return userMapper.selectOne(
                new LambdaQueryWrapper<User>()
                        .eq(User::getEmail, email)
                        .eq(User::getDeleted, 0)
        );
    }
    
    @Override
    @Transactional
    public User register(String username, String email, String password) {
        return register(username, email, password, false);
    }
    
    @Override
    @Transactional
    public User register(String username, String email, String password, boolean isAdmin) {
        if (getByUsername(username) != null) {
            throw new RuntimeException("Username already exists");
        }
        
        if (getByEmail(email) != null) {
            throw new RuntimeException("Email already registered");
        }
        
        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));
        user.setRole(isAdmin ? "ADMIN" : "USER");
        user.setNickname(username);
        user.setStatus(0);
        user.setDeleted(0);
        
        userMapper.insert(user);
        log.info("User registered: {} (role: {})", username, user.getRole());
        
        return user;
    }
    
    @Override
    public String login(String username, String password) {
        User user = getByUsername(username);
        
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        
        if (user.getStatus() != 0) {
            throw new RuntimeException("Account is disabled");
        }
        
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("Invalid password");
        }
        
        return generateToken(user);
    }
    
    @Override
    public String refreshToken(String token) {
        return null;
    }
    
    @Override
    @Transactional
    public User updateUserInfo(Long userId, User userInfo) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        
        if (userInfo.getNickname() != null) {
            user.setNickname(userInfo.getNickname());
        }
        if (userInfo.getSignature() != null) {
            user.setSignature(userInfo.getSignature());
        }
        if (userInfo.getAvatar() != null) {
            user.setAvatar(userInfo.getAvatar());
        }
        if (userInfo.getGender() != null) {
            user.setGender(userInfo.getGender());
        }
        if (userInfo.getBirthday() != null) {
            user.setBirthday(userInfo.getBirthday());
        }
        if (userInfo.getRegion() != null) {
            user.setRegion(userInfo.getRegion());
        }
        
        userMapper.updateById(user);
        return user;
    }
    
    @Override
    @Transactional
    public void changePassword(Long userId, String oldPassword, String newPassword) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        
        if (!passwordEncoder.matches(oldPassword, user.getPassword())) {
            throw new RuntimeException("Invalid old password");
        }
        
        user.setPassword(passwordEncoder.encode(newPassword));
        userMapper.updateById(user);
    }
    
    @Override
    public IPage<User> getUserList(int page, int size, String keyword) {
        LambdaQueryWrapper<User> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(User::getDeleted, 0);
        
        if (StringUtils.hasText(keyword)) {
            wrapper.and(w -> w
                    .like(User::getUsername, keyword)
                    .or()
                    .like(User::getEmail, keyword)
                    .or()
                    .like(User::getNickname, keyword)
            );
        }
        
        wrapper.orderByDesc(User::getCreatedAt);
        return userMapper.selectPage(new Page<>(page, size), wrapper);
    }
    
    @Override
    @Transactional
    public void updateStatus(Long userId, Integer status) {
        LambdaUpdateWrapper<User> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(User::getId, userId)
               .set(User::getStatus, status);
        userMapper.update(null, wrapper);
    }
    
    @Override
    @Transactional
    public User updateAvatar(Long userId, String avatarUrl) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            throw new RuntimeException("User not found");
        }
        user.setAvatar(avatarUrl);
        userMapper.updateById(user);
        log.info("User avatar updated: {}", userId);
        return user;
    }
    
    private String generateToken(User user) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("userId", user.getId());
        claims.put("role", user.getRole());
        
        SecretKey key = Keys.hmacShaKeyFor(jwtProperties.getSecret().getBytes(StandardCharsets.UTF_8));
        
        return Jwts.builder()
                .claims(claims)
                .subject(user.getUsername())
                .issuedAt(new Date())
                .expiration(new Date(System.currentTimeMillis() + jwtProperties.getExpiration()))
                .signWith(key)
                .compact();
    }
}