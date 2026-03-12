package com.yinbo.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.yinbo.entity.CommentLike;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface CommentLikeMapper extends BaseMapper<CommentLike> {
    
    /**
     * Check if user has liked a comment
     */
    @Select("SELECT COUNT(*) FROM comment_likes WHERE user_id = #{userId} AND comment_id = #{commentId}")
    int checkUserLiked(@Param("userId") Long userId, @Param("commentId") Long commentId);
}
