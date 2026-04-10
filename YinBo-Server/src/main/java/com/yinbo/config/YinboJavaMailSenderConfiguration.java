package com.yinbo.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.autoconfigure.mail.MailProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.mail.javamail.JavaMailSenderImpl;

import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Properties;

/**
 * QQ 邮箱在 465 隐式 SSL 下易出现 SSLHandshakeException。
 * 对 smtp.qq.com 强制 587 + STARTTLS，并覆盖可能被环境变量误设的端口。
 */
@Slf4j
@Configuration
@ConditionalOnProperty(name = "spring.mail.host")
@EnableConfigurationProperties(MailProperties.class)
public class YinboJavaMailSenderConfiguration {

    @Bean
    @Primary
    public JavaMailSenderImpl javaMailSender(MailProperties mailProperties) {
        JavaMailSenderImpl sender = new JavaMailSenderImpl();
        String host = mailProperties.getHost();
        sender.setHost(host);
        sender.setUsername(mailProperties.getUsername());
        sender.setPassword(mailProperties.getPassword());

        int port = mailProperties.getPort();
        if (host != null && "smtp.qq.com".equalsIgnoreCase(host.trim())) {
            port = 587;
        }
        if (port <= 0) {
            port = 587;
        }
        sender.setPort(port);

        if (mailProperties.getProtocol() != null && !"smtp".equalsIgnoreCase(mailProperties.getProtocol())) {
            sender.setProtocol(mailProperties.getProtocol());
        } else {
            sender.setProtocol("smtp");
        }
        var enc = mailProperties.getDefaultEncoding();
        sender.setDefaultEncoding(enc != null ? enc.name() : StandardCharsets.UTF_8.name());

        Properties p = new Properties();
        Map<String, String> extra = mailProperties.getProperties();
        if (extra != null) {
            extra.forEach(p::setProperty);
        }
        stripImplicitSslSocketFactoryProps(p);
        p.putIfAbsent("mail.transport.protocol", "smtp");
        p.put("mail.transport.protocol", "smtp");
        p.put("mail.smtp.port", String.valueOf(port));
        p.put("mail.smtp.auth", "true");
        p.put("mail.smtp.starttls.enable", "true");
        p.put("mail.smtp.starttls.required", "true");
        // 587：先明文连入再 STARTTLS；勿开整链路 SSL，否则会按 465 方式握手导致 SSLHandshakeException
        p.put("mail.smtp.ssl.enable", "false");
        p.put("mail.smtp.ssl.trust", host != null ? host : "smtp.qq.com");
        p.put("mail.smtp.ssl.protocols", "TLSv1.2");
        p.put("mail.smtp.connectiontimeout", "20000");
        p.put("mail.smtp.timeout", "20000");
        p.put("mail.smtp.writetimeout", "20000");
        sender.setJavaMailProperties(p);

        log.info("JavaMail 已配置: host={}, port={}, user={}", host, port,
                mailProperties.getUsername() != null ? mailProperties.getUsername() : "(未设置)");
        return sender;
    }

    /**
     * 去掉会从 587「升级」为隐式 SSL(465) 的常见属性；环境变量或旧示例常带这些项。
     */
    private static void stripImplicitSslSocketFactoryProps(Properties p) {
        p.remove("mail.smtp.socketFactory.port");
        p.remove("mail.smtp.socketFactory.class");
        p.remove("mail.smtp.socketFactory.fallback");
        p.remove("mail.smtps.host");
        p.remove("mail.smtps.port");
        p.remove("mail.smtps.auth");
        List<String> dropKeys = new ArrayList<>();
        for (String key : p.stringPropertyNames()) {
            String k = key.toLowerCase(Locale.ROOT);
            if (k.startsWith("mail.smtp.ssl.socketfactory") || k.contains("socketfactory")) {
                dropKeys.add(key);
            }
        }
        dropKeys.forEach(p::remove);
    }
}
