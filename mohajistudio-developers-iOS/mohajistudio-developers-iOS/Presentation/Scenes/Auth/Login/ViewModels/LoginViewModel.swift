//
//  LoginViewModel.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 12/16/24.
//

import Foundation

final class LoginViewModel {
    
    private let authRepository: AuthRepositoryProtocol
    private var tokens: AuthTokenResponse?
    
    private(set) var email: String = ""
    private(set) var password: String = ""
    
    private var timer: Timer?
    private var expirationDate: Date?
    var onTimerUpdated: ((String) -> Void)?
    var onTimerFinished: (() -> Void)?
    
    func updateEmail(_ email: String) {
        self.email = email
    }
    
    func updatePassword(_ password: String) {
        self.password = password
    }
    
    init(authRepository: AuthRepositoryProtocol = AuthRepository()) {
        self.authRepository = authRepository
    }
}
// MARK: - Business Logic
    
extension LoginViewModel {
    
    func login() async throws {
        guard !email.isEmpty else {
            print("email is nil")
            throw NetworkError.unknown("이메일 입력 오류")
        }
        
        tokens = try await authRepository.login(email: email, password: password)
        
        if let tokens = tokens {
            KeychainHelper.shared.saveAccessToken(tokens.accessToken)
            KeychainHelper.shared.saveRefreshToken(tokens.refreshToken)
        }
        
        print("로그인 - 토큰 저장 완료")
    }
    
    func requestEmailVerificationCode() async throws -> RequestEmailCodeResponse {
        guard !email.isEmpty else {
            print("email is nil")
            throw NetworkError.unknown("이메일 입력 오류")
        }
        
        let expiredAt = try await authRepository.requestEmailVerificationWhenPwdReset(email: email)
        
        return expiredAt
    }
    
    func verifyEmailCode(code: String) async throws {
        guard email != "" else { throw NetworkError.unknown("인증할 이메일이 입력되지 않았습니다.") }
        
        tokens = try await authRepository.verifyEmailCode(email: email, code: code)
        // 토큰 처리 로직
        if let tokens = tokens {
            KeychainHelper.shared.saveAccessToken(tokens.accessToken)
            KeychainHelper.shared.saveRefreshToken(tokens.refreshToken)
        }
        
        print("이메일 인증 - 토큰 저장 완료")
    }
    
    func resetPassword(password: String) async throws {
        try await authRepository.resetPassword(password: password)
    }
    
}

// MARK: - Timer
extension LoginViewModel {
    
    func startTimer(expirationDateString: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let expirationDate = dateFormatter.date(from: expirationDateString) else {
            print("날짜 파싱 실패: \(expirationDateString)")
            onTimerFinished?()
            return
        }
        
        self.expirationDate = expirationDate
        
        stopTimer()
        updateTimer()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            self?.updateTimer()
        })
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func updateTimer() {
        guard let expirationDate else {
            stopTimer()
            onTimerFinished?()
            return
        }
        
        let timeInterval = expirationDate.timeIntervalSinceNow
        
        if timeInterval <= 0 {
            stopTimer()
            onTimerFinished?()
            return
        }
        
        let remainingTime = Int(ceil(timeInterval))
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        let timeString = String(format: "%02d:%02d", minutes, seconds)
        
        onTimerUpdated?(timeString)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
}
