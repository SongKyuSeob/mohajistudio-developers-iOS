//
//  ResetPwdEmailCodeView.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 3/15/25.
//

import UIKit

protocol ResetPwdEmailCodeViewDelegate: AnyObject {
    func didTapBackButton()
    func didTapResendButton()
    func didTapNextButton(code: String)
}

class ResetPwdEmailCodeView: BaseStepView {
    
    weak var delegate: ResetPwdEmailCodeViewDelegate?
    private var viewModel: LoginViewModel?
    private var email: String?
    
    private let titleLabel = UILabel().then {
        $0.text = "이메일 인증"
        $0.font = UIFont(name: "Pretendard-Bold", size: 24)
        $0.textColor = UIColor(named: "Black")
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "이메일 인증코드가 발송되었습니다.\n인증 코드를 입력해주세요."
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.textColor = UIColor(named: "Gray 2")
    }
    
    private let verificationCodeField = UITextField().then {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 56, height: 0))
        $0.rightView = paddingView
        $0.rightViewMode = .always
        $0.leftView = paddingView
        $0.leftViewMode = .always
        
        $0.backgroundColor = UIColor(named: "Bg 1")
        $0.autocapitalizationType = .none
        $0.attributedPlaceholder = NSAttributedString(
            string: "123456",
            attributes: [.foregroundColor: UIColor(named: "Gray 3")]
        )
        $0.textAlignment = .left
        $0.layer.cornerRadius = 8.0
        $0.layer.cornerCurve = .continuous
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
    }
    
    private let timerLabel = UILabel().then {
        $0.textColor = UIColor(named: "Primary")
        $0.font = UIFont(name: "Pretendard-Light", size: 12)
        $0.textAlignment = .center
        $0.text = "05:00"
    }
    
    private let errorLabel = UILabel().then {
        $0.textColor = UIColor(named: "Error")
        $0.font = UIFont(name: "Pretendard-Medium", size: 12)
        $0.textAlignment = .center
        $0.isHidden = true
    }
    
    private let resendButton = UIButton().then {
        $0.setTitle("재전송", for: .normal)
        $0.backgroundColor = UIColor(named: "Info")
        $0.tintColor = .white
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.layer.cornerRadius = 8.0
        $0.layer.cornerCurve = .continuous
    }
    
    private let nextButton = UIButton().then {
        $0.backgroundColor = UIColor(named: "Primary")
        $0.layer.cornerRadius = 8.0
        $0.layer.cornerCurve = .continuous
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.titleLabel?.textColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    private func setupUI() {
        setupHierarchy()
        setupConstraints()
    }
    
    private func setupHierarchy() {
        addSubview(surfaceView)
        surfaceView.addSubview(backButton)
        surfaceView.addSubview(titleLabel)
        surfaceView.addSubview(subTitleLabel)
        surfaceView.addSubview(verificationCodeField)
        surfaceView.addSubview(timerLabel)
        surfaceView.addSubview(errorLabel)
        surfaceView.addSubview(resendButton)
        surfaceView.addSubview(nextButton)
    }
    
    private func setupConstraints() {
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(186)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(titleLabel)
        }
        
        verificationCodeField.snp.makeConstraints {
            $0.trailing.equalTo(resendButton.snp.leading).offset(-8)
            $0.leading.equalTo(subTitleLabel.snp.leading)
            $0.height.equalTo(40)
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(60)
        }
        
        timerLabel.snp.makeConstraints {
            $0.trailing.equalTo(verificationCodeField.snp.trailing).offset(-12)
            $0.centerY.equalTo(verificationCodeField.snp.centerY)
        }
        
        errorLabel.snp.makeConstraints {
            $0.centerX.equalTo(verificationCodeField.snp.centerX)
            $0.top.equalTo(verificationCodeField.snp.bottom).offset(8)
        }
        
        resendButton.snp.makeConstraints {
            $0.trailing.equalTo(subTitleLabel.snp.trailing)
            $0.width.equalTo(80)
            $0.height.equalTo(verificationCodeField.snp.height)
            $0.top.equalTo(verificationCodeField.snp.top)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.height.equalTo(43)
            $0.top.equalTo(verificationCodeField.snp.bottom).offset(60)
        }
    }
    
    private func setupAction() {
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        resendButton.addTarget(self, action: #selector(didTapResendButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        verificationCodeField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    @objc private func didTapBackButton() {
        self.delegate?.didTapBackButton()
    }
    
    @objc private func didTapResendButton() {
        self.verificationCodeField.text = ""
        resetVerificationError()
        
        guard let email = email else {
            print("resendButtonTapped - email is nil")
            return
        }
        
        delegate?.didTapResendButton()
    }
    
    @objc private func didTapNextButton() {
        guard let code = verificationCodeField.text else { print("이메일 인증 코드 값이 비었습니다."); return }
                                                                 
        delegate?.didTapNextButton(code: code)
    }
    
    @objc private func textFieldDidChange() {
        resetVerificationError()
    }
    
    func updateTimerText(_ timeString: String) {
        timerLabel.text = timeString
    }
    
    func timerFinished() {
        timerLabel.text = "00:00"
    }
    
    func showVerificationError(error: String) {
        verificationCodeField.layer.borderColor = UIColor.red.cgColor
        verificationCodeField.layer.borderWidth = 1.0
        errorLabel.text = error
        errorLabel.isHidden = false
    }
    
    func resetVerificationError() {
        verificationCodeField.layer.borderWidth = 0
        errorLabel.text = ""
        errorLabel.isHidden = true
    }
    
}
