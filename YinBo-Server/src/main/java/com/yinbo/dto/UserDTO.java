package com.yinbo.dto;

import lombok.Data;

@Data
public class UserDTO {
    private Long id;
    private String username;
    private String email;
    private String avatar;
    private String nickname;
    private String signature;
    private String role;
    private Integer status;
    private String createdAt;
    
    private String gender;
    private String birthday;
    private String region;
}