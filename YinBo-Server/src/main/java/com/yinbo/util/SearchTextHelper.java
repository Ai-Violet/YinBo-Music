package com.yinbo.util;

import cn.hutool.extra.pinyin.PinyinUtil;
import org.springframework.util.StringUtils;

/**
 * 生成用于模糊检索的归一化文本：原文、小写、拼音全拼、拼音首字母等，空格分隔。
 */
public final class SearchTextHelper {

    private SearchTextHelper() {}

    public static String buildTrackSearchNorm(String title, String artist, String album) {
        StringBuilder sb = new StringBuilder();
        appendPart(sb, title);
        appendPart(sb, artist);
        appendPart(sb, album);
        return sb.toString().trim();
    }

    public static String buildSingerSearchNorm(String name) {
        StringBuilder sb = new StringBuilder();
        appendPart(sb, name);
        return sb.toString().trim();
    }

    private static void appendPart(StringBuilder sb, String part) {
        if (!StringUtils.hasText(part)) {
            return;
        }
        String t = part.trim();
        sb.append(t).append(' ');
        sb.append(t.toLowerCase()).append(' ');
        try {
            String spaced = PinyinUtil.getPinyin(t, " ");
            if (StringUtils.hasText(spaced)) {
                sb.append(spaced.toLowerCase()).append(' ');
                sb.append(spaced.toLowerCase().replace(" ", "")).append(' ');
            }
            String first = PinyinUtil.getFirstLetter(t, "");
            if (StringUtils.hasText(first)) {
                sb.append(first.toLowerCase()).append(' ');
            }
        } catch (Exception ignored) {
            // 非中文或拼音库未覆盖的字符跳过
        }
    }
}
