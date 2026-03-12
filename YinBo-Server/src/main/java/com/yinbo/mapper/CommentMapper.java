package com.yinbo.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.yinbo.entity.Comment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface CommentMapper extends BaseMapper<Comment> {

    @Update("UPDATE comments SET deleted = 1, updated_at = NOW() WHERE id = #{id} AND deleted = 0")
    int logicalDeleteById(@Param("id") Long id);
}
