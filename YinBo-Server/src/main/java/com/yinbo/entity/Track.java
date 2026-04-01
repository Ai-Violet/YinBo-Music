package com.yinbo.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("tracks")
public class Track {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String title;
    private String artist;
    private String album;
    private Integer duration;
    private Integer bitrate;
    private String mime;
    private String minioKey;
    private String coverKey;
    private String coverUrl;
    private Long fileSize;
    private String lyrics;
    private String lyricKey;
    private Long artistId;
    private Long playCount;
    private Long likeCount;
    private Integer status;
    private Long uploaderId;
    private Long categoryId;
    /**
     * 拼音检索辅助字段；需执行 <code>ALTER TABLE tracks ADD search_norm...</code> 后改为 exist=true 并去掉本注解。
     */
    @TableField(exist = false)
    private String searchNorm;

    @TableLogic
    private Integer deleted;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}