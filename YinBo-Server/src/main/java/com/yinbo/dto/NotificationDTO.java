package com.yinbo.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class NotificationDTO {
    private Long id;
    private Long userId;
    private Long fromUserId;
    private String fromUserNickname;
    private String fromUserAvatar;
    private String type;
    private Long refId;
    private String refType;
    private String extra;
    private Integer read;
    private String createdAt;
}
