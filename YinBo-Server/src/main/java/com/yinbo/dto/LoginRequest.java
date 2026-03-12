package com.yinbo.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;


@Data
public class LoginRequest {
    
    @NotBlank(message = "�û�������Ϊ��")
    private String username;
    
    @NotBlank(message = "���벻��Ϊ��")
    private String password;
}
