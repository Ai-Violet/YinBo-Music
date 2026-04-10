package com.yinbo.dto;

import com.baomidou.mybatisplus.core.metadata.IPage;
import lombok.Data;

import java.util.List;

@Data
public class PortalSearchResult {
    private IPage<TrackDTO> tracks;
    private List<SingerDTO> singers;
}
