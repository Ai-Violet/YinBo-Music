package com.yinbo.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.yinbo.entity.User;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface UserMapper extends BaseMapper<User> {
}