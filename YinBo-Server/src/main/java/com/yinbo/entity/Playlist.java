package com.yinbo.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("playlists")
public class Playlist {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private String name;
    private String description;
    private String coverUrl;
    private String coverKey;
    private Long ownerId;
    private Integer isPublic;
    private Long playCount;
    private Integer trackCount;
    
    @TableLogic
    private Integer deleted;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}