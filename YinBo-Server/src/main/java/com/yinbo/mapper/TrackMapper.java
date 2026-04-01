package com.yinbo.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.yinbo.entity.Track;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

/**
 * Track Mapper
 */
@Mapper
public interface TrackMapper extends BaseMapper<Track> {
    
    /**
     * 获取热门搜索艺术家（按播放量）
     */
    @Select("SELECT artist FROM tracks WHERE status=1 AND deleted=0 AND artist IS NOT NULL AND artist != '' " +
            "GROUP BY artist ORDER BY SUM(play_count) DESC LIMIT 12")
    List<String> selectTopArtists();
    
    /**
     * ���Ӳ��Ŵ���
     */
    @Update("UPDATE tracks SET play_count = play_count + 1 WHERE id = #{trackId}")
    int incrementPlayCount(@Param("trackId") Long trackId);
    
    /**
     * �����ղش���
     */
    @Update("UPDATE tracks SET like_count = like_count + 1 WHERE id = #{trackId}")
    int incrementLikeCount(@Param("trackId") Long trackId);
    
    /**
     * 减少收藏次数
     */
    @Update("UPDATE tracks SET like_count = GREATEST(0, like_count - 1) WHERE id = #{trackId}")
    int decrementLikeCount(@Param("trackId") Long trackId);

    /**
     * 按评论数排序获取曲目ID列表（分页）
     */
    @Select("SELECT t.id FROM tracks t " +
            "LEFT JOIN (SELECT track_id, COUNT(*) AS cnt FROM comments WHERE deleted=0 GROUP BY track_id) c ON t.id = c.track_id " +
            "WHERE t.status=1 AND t.deleted=0 " +
            "ORDER BY COALESCE(c.cnt, 0) DESC " +
            "LIMIT #{size} OFFSET #{offset}")
    List<Long> selectTrackIdsByCommentCount(@Param("size") int size, @Param("offset") int offset);

    /**
     * 按播放次数排行：播放次数 = play_history 中所有用户的播放记录总和
     */
    @Select("SELECT t.id, t.title, t.artist, t.album, t.duration, t.bitrate, t.mime, t.minio_key, t.cover_key, t.cover_url, " +
            "t.file_size, t.lyrics, t.lyric_key, t.artist_id, COALESCE(ph.cnt, 0) AS play_count, t.like_count, t.status, " +
            "t.uploader_id, t.category_id, t.deleted, t.created_at, t.updated_at " +
            "FROM tracks t " +
            "LEFT JOIN (SELECT track_id, COUNT(*) AS cnt FROM play_history GROUP BY track_id) ph ON t.id = ph.track_id " +
            "WHERE t.status=1 AND t.deleted=0 " +
            "ORDER BY COALESCE(ph.cnt, 0) DESC, t.id ASC " +
            "LIMIT #{size} OFFSET #{offset}")
    List<Track> selectTracksOrderByPlayHistoryCount(@Param("size") int size, @Param("offset") int offset);

    /**
     * 按收藏人数取曲目 ID（已上架、未删除），人数降序
     */
    @Select("SELECT f.track_id FROM favorites f " +
            "INNER JOIN tracks t ON t.id = f.track_id AND t.status = 1 AND t.deleted = 0 " +
            "GROUP BY f.track_id ORDER BY COUNT(*) DESC, f.track_id ASC LIMIT #{limit}")
    List<Long> selectTopTrackIdsByFavoriteCount(@Param("limit") int limit);
}
