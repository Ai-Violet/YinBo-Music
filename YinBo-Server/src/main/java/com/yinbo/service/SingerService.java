package com.yinbo.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.yinbo.dto.SingerDTO;
import com.yinbo.entity.Singer;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface SingerService extends IService<Singer> {
    
    Singer createSinger(String name, MultipartFile avatarFile, String description);
    
    Singer updateSinger(Long id, String name, MultipartFile avatarFile, String description);
    
    IPage<Singer> listSingers(int page, int size, String keyword);

    /** 前台搜索歌手（名称 + searchNorm），限制条数 */
    List<SingerDTO> searchPublicSingerDTOs(String keyword, int limit);

    /** 补齐 search_norm（启动回填或管理用） */
    int backfillSearchNorm();
}
