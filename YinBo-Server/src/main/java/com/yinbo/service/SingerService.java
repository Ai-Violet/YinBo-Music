package com.yinbo.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.yinbo.entity.Singer;
import org.springframework.web.multipart.MultipartFile;

public interface SingerService extends IService<Singer> {
    
    Singer createSinger(String name, MultipartFile avatarFile, String description);
    
    Singer updateSinger(Long id, String name, MultipartFile avatarFile, String description);
    
    IPage<Singer> listSingers(int page, int size, String keyword);
}
