package com.yinbo.exception;

import com.yinbo.common.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.data.redis.RedisConnectionFailureException;
import org.springframework.data.redis.RedisSystemException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Map<String, String>> handleValidationExceptions(MethodArgumentNotValidException ex) {
        Map<String, String> errors = new HashMap<>();
        ex.getBindingResult().getAllErrors().forEach((error) -> {
            String fieldName = ((FieldError) error).getField();
            String errorMessage = error.getDefaultMessage();
            errors.put(fieldName, errorMessage);
        });
        // Return first error message for simplicity
        String firstError = errors.values().stream().findFirst().orElse("Validation failed");
        return Result.badRequest(firstError);
    }
    
    @ExceptionHandler(AuthenticationException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public Result<Void> handleAuthenticationException(AuthenticationException ex) {
        log.warn("Authentication failed: {}", ex.getMessage());
        return Result.unauthorized("Authentication failed: " + ex.getMessage());
    }
    
    @ExceptionHandler(AccessDeniedException.class)
    @ResponseStatus(HttpStatus.FORBIDDEN)
    public Result<Void> handleAccessDeniedException(AccessDeniedException ex) {
        log.warn("Access denied: {}", ex.getMessage());
        return Result.forbidden("Access denied");
    }
    
    @ExceptionHandler({RedisConnectionFailureException.class, RedisSystemException.class})
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleRedisDown(Exception ex) {
        log.error("Redis unavailable: {}", ex.getMessage());
        return Result.badRequest(
                "无法连接 Redis：请确认本机 Redis 已启动，且 application.yml 里 spring.data.redis.password "
                        + "与 Redis 是否设置密码一致（若 Redis 未设密码，请删除或留空 password 配置）");
    }

    /**
     * 业务异常：HTTP 400 + body.code=400（不再使用 Result.error 以免 body.code=500 与 HTTP 混淆）。
     */
    @ExceptionHandler(RuntimeException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public Result<Void> handleRuntimeException(RuntimeException ex) {
        String msg = ex.getMessage();
        if (msg == null || msg.isBlank()) {
            msg = ex.getClass().getSimpleName();
        }
        log.warn("Business exception: {}", msg);
        return Result.badRequest(msg);
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public Result<Void> handleException(Exception ex) {
        log.error("Unexpected exception", ex);
        Throwable root = ex;
        while (root.getCause() != null && root.getCause() != root) {
            root = root.getCause();
        }
        String detail = root.getMessage();
        if (detail == null || detail.isBlank()) {
            detail = root.getClass().getSimpleName();
        }
        return Result.error(500, "服务器异常（请查看控制台日志）: " + detail);
    }
}