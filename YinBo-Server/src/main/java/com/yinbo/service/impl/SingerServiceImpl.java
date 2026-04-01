package com.yinbo.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.yinbo.dto.SingerDTO;
import com.yinbo.entity.Singer;
import com.yinbo.mapper.SingerMapper;
import com.yinbo.service.MinioService;
import com.yinbo.service.SingerService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class SingerServiceImpl extends ServiceImpl<SingerMapper, Singer> implements SingerService {
    
    private final MinioService minioService;
    
    @Override
    public Singer createSinger(String name, MultipartFile avatarFile, String description) {
        Singer singer = new Singer();
        singer.setName(name);
        singer.setDescription(description);
        if (avatarFile != null && !avatarFile.isEmpty()) {
            String avatarKey = minioService.uploadSingerAvatar(avatarFile);
            singer.setAvatarKey(avatarKey);
        }
        save(singer);
        log.info("Created singer: {}", name);
        return singer;
    }
    
    @Override
    public Singer updateSinger(Long id, String name, MultipartFile avatarFile, String description) {
        Singer singer = getById(id);
        if (singer == null) {
            throw new RuntimeException("Singer not found");
        }
        if (StringUtils.hasText(name)) {
            singer.setName(name);
        }
        if (description != null) {
            singer.setDescription(description);
        }
        if (avatarFile != null && !avatarFile.isEmpty()) {
            String avatarKey = minioService.uploadSingerAvatar(avatarFile);
            singer.setAvatarKey(avatarKey);
        }
        updateById(singer);
        return singer;
    }
    
    @Override
    public IPage<Singer> listSingers(int page, int size, String keyword) {
        Page<Singer> p = new Page<>(page, size);
        LambdaQueryWrapper<Singer> wrapper = new LambdaQueryWrapper<>();
        if (StringUtils.hasText(keyword)) {
            wrapper.like(Singer::getName, keyword.trim());
        }
        wrapper.orderByDesc(Singer::getId);
        return page(p, wrapper);
    }

    @Override
    public List<SingerDTO> searchPublicSingerDTOs(String keyword, int limit) {
        if (!StringUtils.hasText(keyword) || limit <= 0) {
            return List.of();
        }
        String kw = keyword.trim();
        LambdaQueryWrapper<Singer> w = new LambdaQueryWrapper<>();
        w.eq(Singer::getDeleted, 0).like(Singer::getName, kw)
                .orderByAsc(Singer::getId)
                .last("LIMIT " + limit);
        return list(w).stream().map(this::toPublicDto).collect(Collectors.toList());
    }

    @Override
    public int backfillSearchNorm() {
        return 0;
    }

    private SingerDTO toPublicDto(Singer singer) {
        SingerDTO dto = new SingerDTO();
        dto.setId(singer.getId());
        dto.setName(singer.getName());
        dto.setDescription(singer.getDescription());
        if (StringUtils.hasText(singer.getAvatarKey())) {
            dto.setAvatarUrl(minioService.getSingerAvatarUrl(singer.getAvatarKey()));
        }
        return dto;
    }
}
