package com.yinbo.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("playlist_items")
public class PlaylistItem {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long playlistId;
    private Long trackId;
    private Integer position;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
}