package com.yinbo.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("comments")
public class Comment {
    
    @TableId(type = IdType.AUTO)
    private Long id;
    
    private Long userId;
    private Long trackId;
    private String content;
    private Long parentId;
    private Integer floor;
    private Integer likeCount;
    private Integer status;
    
    @TableLogic
    private Integer deleted;
    
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}