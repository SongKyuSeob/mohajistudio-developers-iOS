//
//  AuthInterceptor.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 12/30/24.
//

import Foundation
import Alamofire

struct AuthInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        
        if let token = KeychainHelper.shared.getAccessToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        completion(.success(request))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetry)
            return
        }
        
        guard let refreshToken = KeychainHelper.shared.getRefreshToken() else {
            redirectToLogin()
            completion(.doNotRetry)
            return
        }
        
        // 토큰 재발급 시도
        print("리프레시 토큰 시도: \(refreshToken)")
        
        let refreshRequest = RefreshTokenRequest(refreshToken: refreshToken)
        
        do {
            let jsonData = try JSONEncoder().encode(refreshRequest)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("리프레시 토큰 요청 본문: \(jsonString)")
            }
        } catch {
            print("로깅 오류: \(error)")
        }
        
        AF.request(AuthRouter.refreshToken(refreshRequest))
            .validate()
            .responseDecodable (of: AuthTokenResponse.self) { response in
                print(response.result)
                switch response.result {
                case .success(let tokenResponse):
                    KeychainHelper.shared.saveAccessToken(tokenResponse.accessToken)
                    KeychainHelper.shared.saveRefreshToken(tokenResponse.refreshToken)
                    
                    completion(.retry)
                case .failure(let error):
                    print("Token refresh failed: \(error)")
                    
                    if let statusCode = response.response?.statusCode, statusCode == 401 || statusCode == 403 {
                        KeychainHelper.shared.clearTokens()
                        redirectToLogin()
                    }
                    
                    completion(.doNotRetry)
                }
                
            }
    }
    
    private func redirectToLogin() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name("SessionExpired"), object: nil)
        }
    }
    
}
