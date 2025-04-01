//
//  LoginViewController.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 12/16/24.
//

import UIKit

class LoginViewController: UIViewController {
    
    enum Step {
        case email
        case password
        case resetPwdVerify
        case resetPwd
        
        func view(delegate: Any) -> UIView {
            switch self {
            case .email: 
                let view = EmailView()
                view.delegate = delegate as? EmailViewDelegate
                return view
            case .password:
                let view = PasswordView()
                view.delegate = delegate as? PasswordViewDelegate
                return view
            case .resetPwdVerify:
                let view = ResetPwdEmailCodeView()
                view.delegate = delegate as? ResetPwdEmailCodeViewDelegate
                return view
            case .resetPwd:
                let view = ResetPwdView()
                view.delegate = delegate as? ResetPwdViewDelegate
                return view
            }
        }
    }
    
    private var currentStep: Step = .email
    private let viewModel: LoginViewModel
    
    private let containerView = UIView()
    
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = containerView
        view.backgroundColor = UIColor(named: "BackgroundColor")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateView(for: currentStep)
    }
    
    private func updateView(for step: Step, animated: Bool = false, reverseAnimation: Bool = false) {
        let newView = step.view(delegate: self)
        
        if animated {
            containerView.addSubview(newView)
            newView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            containerView.layoutIfNeeded()
            
            if let newStepView = newView as? BaseStepView,
               let oldView = containerView.subviews.first(where: { $0 != newView }),
               let oldStepView = oldView as? BaseStepView {
                
                // surfaceView의 width를 기준으로 offset 계산
                let surfaceWidth = newStepView.surfaceView.bounds.width
                let initialOffset = (reverseAnimation ? -surfaceWidth : surfaceWidth) * 0.2
                
                // backButton은 애니메이션에서 제외하고 고정
                newStepView.backButton.alpha = 1
                newStepView.backButton.transform = .identity
                oldStepView.backButton.alpha = 1
                oldStepView.backButton.transform = .identity
                
                // 새로운 뷰의 컴포넌트들 초기 위치 설정 (backButton 제외)
                newStepView.surfaceView.subviews.forEach { subview in
                    if subview != newStepView.backButton {
                        subview.transform = CGAffineTransform(translationX: initialOffset, y: 0)
                        subview.alpha = 0.3
                    }
                }
                
                // 애니메이션 적용
                UIView.animate(withDuration: 0.5,
                               delay: 0,
                               options: [.curveEaseOut]) {
                    // 새로운 컴포넌트들은 원래 위치로
                    newStepView.surfaceView.subviews.forEach { subview in
                        if subview != newStepView.backButton {
                            subview.transform = .identity
                            subview.alpha = 1
                        }
                    }
                    
                    // 현재 컴포넌트들은 반대 방향으로
                    let exitOffset = (reverseAnimation ? surfaceWidth : -surfaceWidth) * 0.2
                    oldStepView.surfaceView.subviews.forEach { subview in
                        if subview != oldStepView.backButton {
                            subview.transform = CGAffineTransform(translationX: exitOffset, y: 0)
                            subview.alpha = 0.3
                        }
                    }
                } completion: { _ in
                    oldView.removeFromSuperview()
                }
            }
        } else {
            containerView.subviews.forEach { $0.removeFromSuperview() }
            containerView.addSubview(newView)
            newView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }

    func moveToNextStep() {
        switch currentStep {
        case .email:
            currentStep = .password
            updateView(for: .password, animated: true, reverseAnimation: false)
        case .password:
            currentStep = .resetPwdVerify
            updateView(for: .resetPwdVerify, animated: true, reverseAnimation: false)
        case .resetPwdVerify:
            currentStep = .resetPwd
            updateView(for: .resetPwd, animated: true, reverseAnimation: false)
        case .resetPwd:
            showAlert(title: "비밀번호 재설정 완료" ,message: "로그인 페이지로 이동합니다.", confirmHandler:  {
                self.viewModel.updateEmail("")
                self.viewModel.updatePassword("")
                KeychainHelper.shared.clearTokens()
                self.currentStep = .email
                self.updateView(for: .email, animated: true, reverseAnimation: true)
            })
        }
    }
    
    func moveToPreviousStep() {
        switch currentStep {
        case .email:
            return
        case .password:
            currentStep = .email
            viewModel.updateEmail("")
            updateView(for: .email, animated: true, reverseAnimation: true)
        case .resetPwdVerify:
            currentStep = .password
            updateView(for: .password, animated: true, reverseAnimation: true)
        case .resetPwd:
            currentStep = .password
            updateView(for: .password, animated: true, reverseAnimation: true)
        }
    }
    
}

extension LoginViewController: EmailViewDelegate {
    
    func emailViewDidTapSignUpBtn() {
        let signUpVM = SignUpViewModel()
        let vc = SignUpViewController(viewModel: signUpVM)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func emailViewDidTapLogin(email: String) {
        if ValidationUtility.isValidEmail(email) {
            viewModel.updateEmail(email)
            print("emailViewDelegate - emailViewDidTapLogin")
            moveToNextStep()
        }
        else {
            print("이메일이 유효하지 않습니다. 다시 입력해주세요.")
        }
        
    }
    
    func emailViewDidTapBackButton() {
        self.navigationController?.dismiss(animated: true)
    }

}

extension LoginViewController: PasswordViewDelegate {
    
    func passwordViewDidTapFindPasswordBtn() {
        let resetPwdVC = ResetPasswordModalViewController()
        resetPwdVC.modalPresentationStyle = .overFullScreen
        
        resetPwdVC.resetButtonTapped = {
            Task {
                do {
                    let response = try await self.viewModel.requestEmailVerificationCode()
                    
                    await MainActor.run {
                        self.moveToNextStep()
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            if let resetPwdEmailCodeView = self.containerView.subviews.first as? ResetPwdEmailCodeView {
                                self.viewModel.onTimerUpdated = { timeString in
                                    DispatchQueue.main.async {
                                        resetPwdEmailCodeView.updateTimerText(timeString)
                                    }
                                }
                                
                                self.viewModel.onTimerFinished = {
                                    DispatchQueue.main.async {
                                        resetPwdEmailCodeView.timerFinished()
                                    }
                                }
                                
                                self.viewModel.startTimer(expirationDateString: response.expiredAt)
                            }
                        }
                    }
                } catch let error as NetworkError {
                    self.showAlert(message: error.errorMessage, cancelHandler: {
                        self.moveToPreviousStep()
                    })
                } catch {
                    await MainActor.run {
                        self.showAlert(message: "인증코드 요청에 실패했습니다.", cancelHandler: {
                            self.moveToPreviousStep()
                        })
                    }
                }
            }
        }
        
        self.present(resetPwdVC, animated: false)
    }
    
    func passwordViewDidTapBackBtn() {
        moveToPreviousStep()
    }
    
    func passwordViewDidTapLogin(password: String) {
        viewModel.updatePassword(password)
        
        Task {
            do {
                print("login버튼 탭")
                try await viewModel.login()

                await MainActor.run {
                    self.showAlert(message: "로그인에 성공했습니다.", confirmHandler:  {
                        self.navigationController?.dismiss(animated: true)
                    })
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    self.showAlert(message: error.errorMessage)
                }
            }
            catch {
                await MainActor.run {
                    self.showAlert(message: "예기치 못한 오류가 발생했습니다.\n다시 시도해주세요.")
                }
            }
        }
    }
    
}

extension LoginViewController: ResetPwdEmailCodeViewDelegate {
    func didTapNextButton(code: String) {
        guard let currentView = containerView.subviews.first as? ResetPwdEmailCodeView else { return }
        
        guard ValidationUtility.isValidVerificationCode(code) else {
            currentView.showVerificationError(error: "인증코드가 올바르지 않습니다.")
            return
        }
        
        Task {
            do {
                try await viewModel.verifyEmailCode(code: code)
                await MainActor.run {
                    moveToNextStep()
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    showAlert(message: error.errorMessage)
                }
            } catch {
                await MainActor.run {
                    showAlert(message: "예기치 못한 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.")
                }
            }
        }
    }
    
    func didTapResendButton() {
        Task {
            do {
                let response = try await viewModel.requestEmailVerificationCode()
                
                if let resetPwdEmailCodeView = containerView.subviews.first as? ResetPwdEmailCodeView {
                    viewModel.startTimer(expirationDateString: response.expiredAt)
                }
            } catch {
                await MainActor.run {
                    self.showAlert(message: "인증코드 재전송에 실패했습니다.")
                }
            }
        }
    }
    
    func didTapBackButton() {
        print("비번 재설정 이메일 인증 페이지 뒤로가기 버튼 탭")
        moveToPreviousStep()
    }
}

extension LoginViewController: ResetPwdViewDelegate {
    func resetPwdViewDidTapBack() {
        moveToPreviousStep()
    }
    
    func resetPwdViewDidTapNext(password: String) {
        
        guard ValidationUtility.isValidPassword(password) else { return }
        
        Task {
            do {
                try await viewModel.resetPassword(password: password)
                await MainActor.run {
                    moveToNextStep()
                }
            } catch let error as NetworkError {
                await MainActor.run {
                    showAlert(message: error.errorMessage)
                }
            } catch {
                await MainActor.run {
                    showAlert(message: "예기치 못한 오류가 발생했습니다.\n다시 시도해주세요.")
                }
            }
        }
    }
}
