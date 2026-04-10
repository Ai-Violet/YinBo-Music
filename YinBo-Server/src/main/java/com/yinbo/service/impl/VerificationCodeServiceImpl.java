package com.yinbo.service.impl;

import com.yinbo.config.YinboMailDisplayProperties;
import com.yinbo.service.VerificationCodeService;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.time.Duration;
import java.util.concurrent.TimeUnit;
import javax.net.ssl.SSLException;

@Slf4j
@Service
@RequiredArgsConstructor
public class VerificationCodeServiceImpl implements VerificationCodeService {

    private static final String PREFIX_EMAIL = "yinbo:vc:email:";
    private static final String PREFIX_COOLDOWN_EMAIL = "yinbo:vc:cd:email:";
    private static final int CODE_TTL_MINUTES = 10;
    private static final int COOLDOWN_SECONDS = 60;

    private final StringRedisTemplate stringRedisTemplate;
    private final ObjectProvider<JavaMailSender> javaMailSenderProvider;
    private final YinboMailDisplayProperties mailDisplayProperties;

    private final SecureRandom random = new SecureRandom();

    @Override
    public void sendEmailCode(String email) {
        String key = normalizedEmailKey(email);
        try {
            assertCooldown(PREFIX_COOLDOWN_EMAIL + key);
            JavaMailSender sender = javaMailSenderProvider.getIfAvailable();
            if (sender == null) {
                throw new RuntimeException("邮件服务未配置：请在 application.yml 中配置 spring.mail.host、username、password 等");
            }
            String code = randomCode();
            stringRedisTemplate.opsForValue().set(PREFIX_EMAIL + key, code, Duration.ofMinutes(CODE_TTL_MINUTES));
            setCooldown(PREFIX_COOLDOWN_EMAIL + key);

            try {
                MimeMessage message = sender.createMimeMessage();
                MimeMessageHelper helper = new MimeMessageHelper(message, true, StandardCharsets.UTF_8.name());
                helper.setTo(email);
                helper.setSubject("【音波音乐】注册验证码");
                helper.setText("您的验证码是：" + code + "，" + CODE_TTL_MINUTES + " 分钟内有效。如非本人操作请忽略。", false);
                String fromName = mailDisplayProperties.getFromName();
                org.springframework.mail.javamail.JavaMailSenderImpl impl =
                        sender instanceof org.springframework.mail.javamail.JavaMailSenderImpl j
                        ? j : null;
                String fromAddr = impl != null && impl.getUsername() != null ? impl.getUsername() : null;
                if (!StringUtils.hasText(fromAddr)) {
                    throw new RuntimeException("spring.mail.username 未配置，无法发送邮件");
                }
                helper.setFrom(fromAddr, StringUtils.hasText(fromName) ? fromName : "音波音乐");
                sender.send(message);
            } catch (RuntimeException e) {
                stringRedisTemplate.delete(PREFIX_EMAIL + key);
                throw e;
            } catch (Exception e) {
                stringRedisTemplate.delete(PREFIX_EMAIL + key);
                log.warn("发送邮件失败", e);
                String msg = e.getMessage() != null ? e.getMessage() : e.toString();
                String low = msg.toLowerCase();
                if (isSslOrHandshakeFailure(e)) {
                    throw new RuntimeException(
                            "邮件服务器 SSL/TLS 异常：请使用 smtp.qq.com、端口 587、STARTTLS（不要再用 465）。"
                                    + " 重启后端后查看启动日志中的 JavaMail 端口；确认本机可访问 587，"
                                    + " spring.mail.password 为 QQ「授权码」或通过环境变量 SPRING_MAIL_PASSWORD 设置。");
                }
                if (low.contains("535") || low.contains("authentication failed") || low.contains("auth")
                        || low.contains("invalid credentials") || msg.contains("认证")
                        || isSmtpAuthFailureCause(e)) {
                    throw new RuntimeException(
                            "SMTP 认证失败：请确认 QQ 邮箱已开启 SMTP，且授权码正确（可用环境变量 SPRING_MAIL_PASSWORD 覆盖 yml）");
                }
                throw new RuntimeException("发送邮件失败，请检查网络与 SMTP 配置: " + msg);
            }
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            log.error("sendEmailCode 未预料的受检异常", e);
            throw new RuntimeException("发送验证码失败: " + e.getClass().getSimpleName() + ": " + e.getMessage(), e);
        }
    }

    @Override
    public void verifyAndConsumeEmail(String email, String code) {
        if (!StringUtils.hasText(code)) {
            throw new RuntimeException("请填写邮箱验证码");
        }
        String redisKey = PREFIX_EMAIL + normalizedEmailKey(email);
        String expect = stringRedisTemplate.opsForValue().get(redisKey);
        if (expect == null || !expect.equals(code.trim())) {
            throw new RuntimeException("邮箱验证码错误或已过期");
        }
        stringRedisTemplate.delete(redisKey);
    }

    private void assertCooldown(String cdKey) {
        Boolean exists = stringRedisTemplate.hasKey(cdKey);
        if (Boolean.TRUE.equals(exists)) {
            throw new RuntimeException("发送过于频繁，请 " + COOLDOWN_SECONDS + " 秒后再试");
        }
    }

    private void setCooldown(String cdKey) {
        stringRedisTemplate.opsForValue().set(cdKey, "1", COOLDOWN_SECONDS, TimeUnit.SECONDS);
    }

    private String normalizedEmailKey(String email) {
        return email.trim().toLowerCase();
    }

    private String randomCode() {
        int n = random.nextInt(1_000_000);
        return String.format("%06d", n);
    }

    private static boolean isSslOrHandshakeFailure(Throwable e) {
        for (Throwable t = e; t != null; t = t.getCause()) {
            if (t instanceof SSLException) {
                return true;
            }
            String m = t.getMessage();
            if (m != null) {
                String l = m.toLowerCase();
                if (l.contains("sslhandshake") || l.contains("handshake") && l.contains("ssl")
                        || l.contains("remote host terminated")) {
                    return true;
                }
            }
        }
        return false;
    }

    private static boolean isSmtpAuthFailureCause(Throwable e) {
        for (Throwable t = e; t != null; t = t.getCause()) {
            String m = t.getMessage();
            if (m != null) {
                String l = m.toLowerCase();
                if (l.contains("535") || l.contains("authentication failed")) {
                    return true;
                }
            }
        }
        return false;
    }
}
