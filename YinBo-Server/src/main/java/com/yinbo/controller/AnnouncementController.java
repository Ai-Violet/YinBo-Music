package com.yinbo.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.yinbo.common.Result;
import com.yinbo.entity.Announcement;
import com.yinbo.mapper.AnnouncementMapper;
import com.yinbo.security.CurrentUser;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Announcement API")
@RestController
@RequestMapping("/announcements")
@RequiredArgsConstructor
public class AnnouncementController {

    private final AnnouncementMapper announcementMapper;

    @Operation(summary = "Get active announcements (public)")
    @GetMapping("/active")
    public Result<List<Announcement>> getActive() {
        LambdaQueryWrapper<Announcement> w = new LambdaQueryWrapper<>();
        w.eq(Announcement::getStatus, 1).orderByDesc(Announcement::getCreatedAt).last("LIMIT 5");
        return Result.success(announcementMapper.selectList(w));
    }

    @Operation(summary = "Get all announcements (admin)")
    @GetMapping("/all")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<IPage<Announcement>> getAll(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        LambdaQueryWrapper<Announcement> w = new LambdaQueryWrapper<>();
        w.orderByDesc(Announcement::getCreatedAt);
        return Result.success(announcementMapper.selectPage(new Page<>(page, size), w));
    }

    @Operation(summary = "Create announcement (admin)")
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Announcement> create(
            @RequestBody AnnounceRequest req,
            @AuthenticationPrincipal CurrentUser user) {
        Announcement a = new Announcement();
        a.setTitle(req.getTitle());
        a.setContent(req.getContent());
        a.setStatus(1);
        a.setCreatedBy(user.getUserId());
        announcementMapper.insert(a);
        return Result.success(a);
    }

    @Operation(summary = "Toggle announcement status (admin)")
    @PutMapping("/{id}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> toggleStatus(@PathVariable Long id, @RequestParam int status) {
        Announcement a = announcementMapper.selectById(id);
        if (a == null) return Result.error("公告不存在");
        a.setStatus(status);
        announcementMapper.updateById(a);
        return Result.success();
    }

    @Operation(summary = "Delete announcement (admin)")
    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public Result<Void> delete(@PathVariable Long id) {
        announcementMapper.deleteById(id);
        return Result.success();
    }

    @Data
    public static class AnnounceRequest {
        private String title;
        private String content;
    }
}
