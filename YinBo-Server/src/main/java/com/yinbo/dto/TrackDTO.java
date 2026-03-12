package com.yinbo.dto;

import lombok.Data;

@Data
public class TrackDTO {
    
    private Long id;
    private String title;
    private String artist;
    private String album;
    private Integer duration;
    private String coverUrl;
    private String playUrl;
    private String lyrics;
    private Long playCount;
    private Long likeCount;
    private Integer status;
    private Long categoryId;
    private String categoryName;
    private Long artistId;
    private Boolean isFavorited;
    private String uploaderName;
    private String createdAt;
}