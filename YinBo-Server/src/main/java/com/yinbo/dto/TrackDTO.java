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
    /** 管理端排行：收藏人数（非库表字段，仅统计展示） */
    private Long favoriteUserCount;
    /** 管理端排行：评论条数（曲目下全部评论，含回复） */
    private Long totalCommentCount;
}