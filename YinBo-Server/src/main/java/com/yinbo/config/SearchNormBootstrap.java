package com.yinbo.config;

import com.yinbo.service.SingerService;
import com.yinbo.service.TrackService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * 可选：在增加 search_norm 列后启动时回填拼音检索字段。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class SearchNormBootstrap implements ApplicationRunner {

    @Value("${yinbo.search.backfill-on-startup:false}")
    private boolean backfillOnStartup;

    private final TrackService trackService;
    private final SingerService singerService;

    @Override
    public void run(ApplicationArguments args) {
        if (!backfillOnStartup) {
            return;
        }
        try {
            trackService.backfillTrackSearchNorm();
            singerService.backfillSearchNorm();
            log.info("yinbo.search.backfill-on-startup 已执行（当前实体未映射 search_norm 列，通常无需开启）");
        } catch (Exception e) {
            log.debug("search 回填: {}", e.getMessage());
        }
    }
}
