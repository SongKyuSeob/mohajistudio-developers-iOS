//
//  AuthRequest.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 12/27/24.
//

import Foundation

struct EmailVerificationRequest: Encodable {
    let email: String
}

struct EmailCodeVerificationRequest: Encodable {
    let email: String
    let code: String
}

struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

struct SetPasswordRequest: Encodable {
    let password: String
}

struct SetNicknameRequest: Encodable {
    let nickname: String
}

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct ResetPasswordRequest: Encodable {
    let password: String
}
