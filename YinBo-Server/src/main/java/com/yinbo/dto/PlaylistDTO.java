package com.yinbo.dto;

import lombok.Data;

@Data
public class PlaylistDTO {
    
    private Long id;
    private String name;
    private String description;
    private String coverUrl;
    private Long ownerId;
    private String ownerName;
    private Integer isPublic;
    private Long playCount;
    private Integer trackCount;
    private String createdAt;
}
