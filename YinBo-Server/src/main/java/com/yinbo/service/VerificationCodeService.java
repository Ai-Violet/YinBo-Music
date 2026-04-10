package com.yinbo.service;

public interface VerificationCodeService {

    void sendEmailCode(String email);

    void verifyAndConsumeEmail(String email, String code);
}
