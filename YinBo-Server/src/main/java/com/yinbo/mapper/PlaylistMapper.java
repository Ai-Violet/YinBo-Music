package com.yinbo.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.yinbo.entity.Playlist;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface PlaylistMapper extends BaseMapper<Playlist> {

    /**
     * 显式执行逻辑删除，避免 deleteById 在某些情况下不生效
     */
    @Update("UPDATE playlists SET deleted = 1, updated_at = NOW() WHERE id = #{id} AND deleted = 0")
    int logicalDeleteById(@Param("id") Long id);
}
