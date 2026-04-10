package com.yinbo.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "yinbo.mail")
public class YinboMailDisplayProperties {

    /** 邮件「发件人」显示名 */
    private String fromName = "音波音乐";
}
