package com.yinbo.controller;

import com.yinbo.common.Result;
import com.yinbo.dto.SingerDTO;
import com.yinbo.entity.Singer;
import com.yinbo.service.MinioService;
import com.yinbo.service.SingerService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Singer API", description = "Public singer endpoints")
@RestController
@RequestMapping("/singers")
@RequiredArgsConstructor
public class SingerController {

    private final SingerService singerService;
    private final MinioService minioService;

    @Operation(summary = "Get singer public detail")
    @GetMapping("/public/{id}")
    public Result<SingerDTO> getSingerDetail(@PathVariable Long id) {
        Singer singer = singerService.getById(id);
        if (singer == null) {
            throw new RuntimeException("歌手不存在");
        }
        SingerDTO dto = toDTO(singer);
        return Result.success(dto);
    }

    private SingerDTO toDTO(Singer singer) {
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
