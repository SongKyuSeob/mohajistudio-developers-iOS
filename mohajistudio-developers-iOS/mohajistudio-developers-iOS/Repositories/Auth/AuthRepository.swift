//
//  AuthRepository.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 12/26/24.
//

import Foundation
import Alamofire

protocol AuthRepositoryProtocol {
    func checkSignUpStatus(email: String) async throws
    func requestEmailVerification(email: String) async throws -> RequestEmailCodeResponse
    func verifyEmailCode(email: String, code: String) async throws -> AuthTokenResponse
    func setPassword(password: String) async throws
    func setNickname(nickname: String) async throws
    func login(email: String, password: String) async throws -> AuthTokenResponse
    func requestEmailVerificationWhenPwdReset(email: String) async throws -> RequestEmailCodeResponse
    func resetPassword(password: String) async throws
}

final class AuthRepository: AuthRepositoryProtocol {
    
    func checkSignUpStatus(email: String) async throws {
        
        let response = try await AF.request(AuthRouter.checkSignUpStatus(email)).serializingResponse(using: .data)
            .response
        
        print("🚀 Check signup status response:", response)  // 응답 전체 확인
        print("Status code:", response.response?.statusCode ?? "nil")  // 상태 코드 확인
        if let data = response.data {
            print("Response data:", String(data: data, encoding: .utf8) ?? "nil")  // 응답 데이터 확인
        }
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        switch statusCode {
        case 200:
            return
        default:
            if let data = response.data {
                throw try handleError(data)
            } else {
                throw NetworkError.invalidResponse
            }
        }
    }
    
    func requestEmailVerification(email: String) async throws -> RequestEmailCodeResponse {
        let request = EmailVerificationRequest(email: email)
        
        let response = try await AF.request(AuthRouter.requestEmailVerification(request))
            .serializingResponse(using: .data)
            .response
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        switch statusCode {
        case 200:
            guard let data = response.data else { throw NetworkError.invalidResponse }
            let decoder = JSONDecoder()
            return try decoder.decode(RequestEmailCodeResponse.self, from: data)
        default:
            if let data = response.data {
                throw try handleError(data)
            } else {
                throw NetworkError.invalidResponse
            }
        }
    }
    
    func verifyEmailCode(email: String, code: String) async throws -> AuthTokenResponse {
        let request = EmailCodeVerificationRequest(email: email, code: code)
        
        let response = try await AF.request(AuthRouter.verifyEmailCode(request))
            .serializingResponse(using: .data)
            .response
        
        print("request: \(request)")
        debugPrint(response)
        
        if response.response?.statusCode == 200 {
            guard let data = response.data else {
                throw NetworkError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            
            return try decoder.decode(AuthTokenResponse.self, from: data)
        }
        
        guard let data = response.data else {
            throw NetworkError.invalidResponse
        }
        
        throw try handleError(data)
    }
    
    func setPassword(password: String) async throws {
        
        let request = SetPasswordRequest(password: password)
        
        let response = try await AF.request(AuthRouter.setPassword(request), interceptor: AuthInterceptor())
            .serializingResponse(using: .data)
            .response
        
        debugPrint(response)
        
        if response.response?.statusCode == 200 {
            return
        }
        
        guard let data = response.data else {
            throw NetworkError.invalidResponse
        }
        
        throw try handleError(data)
        
    }
    
    func setNickname(nickname: String) async throws {
        
        let request = SetNicknameRequest(nickname: nickname)
        
        let response = try await AF.request(AuthRouter.setNickname(request), interceptor: AuthInterceptor())
            .serializingResponse(using: .data)
            .response
        
        print("\(response)")
        
        if response.response?.statusCode == 200 {
            return
        }
        
        guard let data = response.data else {
            throw NetworkError.invalidResponse
        }
        
        throw try handleError(data)
        
    }
    
    func login(email: String, password: String) async throws -> AuthTokenResponse {
        let request = LoginRequest(email: email, password: password)
        
        let response = try await AF.request(AuthRouter.login(request))
            .serializingResponse(using: .data)
            .response
        
        print("\(response)")
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        switch statusCode {
        case 200:
            guard let data = response.data else { throw NetworkError.invalidResponse }
            let decoder = JSONDecoder()
            return try decoder.decode(AuthTokenResponse.self, from: data)
        default:
            if let data = response.data {
                throw try handleError(data)
            } else {
                throw NetworkError.invalidResponse
            }
        }
    }
    
    func requestEmailVerificationWhenPwdReset(email: String) async throws -> RequestEmailCodeResponse {
        
        let request = EmailVerificationRequest(email: email)
        
        let response = try await AF.request(AuthRouter.requestEmailVerificationWhenPwdReset(request), interceptor: AuthInterceptor())
            .validate()
            .serializingResponse(using: .data)
            .response
        
        print("\(response)")
        
        guard let statusCode = response.response?.statusCode else {
            throw NetworkError.invalidResponse
        }
        
        switch statusCode {
        case 200:
            guard let data = response.data else { throw NetworkError.invalidResponse }
            let decoder = JSONDecoder()
            return try decoder.decode(RequestEmailCodeResponse.self, from: data)
        default:
            if let data = response.data {
                throw try handleError(data)
            } else {
                throw NetworkError.invalidResponse
            }
        }
        
    }
    
    func verifyEmailCodeWhenResetPwd(email: String, code: String) async throws -> AuthTokenResponse {
        let request = EmailCodeVerificationRequest(email: email, code: code)
        
        let response = try await AF.request(AuthRouter.verifyEmailCodeWhenPwdReset(request))
            .serializingResponse(using: .data)
            .response
        
        print("request: \(request)")
        debugPrint(response)
        
        if response.response?.statusCode == 200 {
            guard let data = response.data else {
                throw NetworkError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            
            return try decoder.decode(AuthTokenResponse.self, from: data)
        }
        
        guard let data = response.data else {
            throw NetworkError.invalidResponse
        }
        
        throw try handleError(data)
    }
    
    func resetPassword(password: String) async throws {
        let request = ResetPasswordRequest(password: password)
        
        let response = try await AF.request(AuthRouter.resetPassword(request), interceptor: AuthInterceptor())
            .validate()
            .serializingResponse(using: .data)
            .response
        
        if response.response?.statusCode == 200 {
            return
        }
        
        guard let data = response.data else {
            throw NetworkError.invalidResponse
        }
        
        throw try handleError(data)
    }
    
    
    // MARK: - auth 관련 에러 handle
    private func handleError(_ data: Data) throws -> NetworkError {
        print("Error response data:", String(data: data, encoding: .utf8) ?? "")
        
        struct ErrorResponse: Decodable {
            let code: String
            let message: String
        }
        
        let decoder = JSONDecoder()
        guard let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) else {
            return .unknown("unknown error ocurred")
        }
        
        switch errorResponse.code {
        case "R0001":
            return .alreadyRegistered
        case "R0002":
            return .passwordAlreadyExists
        case "EV004":
            return .tooManyRequestCode
        case "EV0001":
            return .failedToSendEmail
        case "EV0002":
            return .notValidCode
        case "EV0003":
            return .tooManyAttempts
        case "U0001":
            return .unknownUser
        case "R0005":
            return .passwordNotSet
        case "R0006":
            return .profileNameNotSet
            
        default:
            return .unknown(errorResponse.message)
        }
    }
}

// 코드 발급 EV004: 인증 메일 요청 횟수 초과, EV0001: 이메일 전송 실패, R0001: 이미 존재하는 유저
// 코드 인증 EV0002: 유효하지 않은 이메일, EV0003: 이메일 인증 횟수 초과, R0001: 이미 존재하는 유저
// 비번 설정 U0001: 알 수 없는 유저, R0002: 이미 설정된 비밀번호, R0001: 이미 존재하는 유저
// 로그인 U0001: 알 수 없는 유저, R0005: 설정되지 않은 비밀번호, R0006: 설정되지 않은 닉네임
// 사용자 전용 메시지는 후에 설정, 기획
