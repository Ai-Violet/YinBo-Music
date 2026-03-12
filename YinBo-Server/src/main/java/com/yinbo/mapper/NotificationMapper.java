package com.yinbo.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.yinbo.entity.Notification;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface NotificationMapper extends BaseMapper<Notification> {

    @Update("UPDATE notifications SET `read` = 1 WHERE user_id = #{userId} AND `read` = 0")
    int markAllReadByUserId(@Param("userId") Long userId);
}
