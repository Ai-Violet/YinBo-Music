package com.yinbo.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.yinbo.common.Result;
import com.yinbo.dto.TrackDTO;
import com.yinbo.security.CurrentUser;
import com.yinbo.service.FavoriteService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@Tag(name = "Favorite API")
@RestController
@RequestMapping("/favorites")
@RequiredArgsConstructor
public class FavoriteController {
    
    private final FavoriteService favoriteService;
    
    @Operation(summary = "Add favorite")
    @PostMapping("/{trackId}")
    public Result<Void> addFavorite(
            @PathVariable Long trackId,
            @AuthenticationPrincipal CurrentUser user) {
        favoriteService.addFavorite(user.getUserId(), trackId);
        return Result.success();
    }
    
    @Operation(summary = "Remove favorite")
    @DeleteMapping("/{trackId}")
    public Result<Void> removeFavorite(
            @PathVariable Long trackId,
            @AuthenticationPrincipal CurrentUser user) {
        favoriteService.removeFavorite(user.getUserId(), trackId);
        return Result.success();
    }
    
    @Operation(summary = "Check if favorited")
    @GetMapping("/check/{trackId}")
    public Result<Boolean> isFavorited(
            @PathVariable Long trackId,
            @AuthenticationPrincipal CurrentUser user) {
        Long userId = user != null ? user.getUserId() : null;
        return Result.success(favoriteService.isFavorited(userId, trackId));
    }
    
    @Operation(summary = "Get my favorites")
    @GetMapping("/list")
    public Result<IPage<TrackDTO>> getMyFavorites(
            @AuthenticationPrincipal CurrentUser user,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.success(favoriteService.getUserFavorites(user.getUserId(), page, size));
    }

    @Operation(summary = "Get user public favorites")
    @GetMapping("/user/{userId}")
    public Result<IPage<TrackDTO>> getUserFavorites(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        return Result.success(favoriteService.getUserFavorites(userId, page, size));
    }
}