//
//  LoginView.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 12/16/24.
//

import UIKit
import SnapKit
import Then

protocol EmailViewDelegate: AnyObject {
    func emailViewDidTapLogin(email: String)
    func emailViewDidTapSignUpBtn()
    func emailViewDidTapBackButton()
}

class EmailView: BaseStepView {
    // MARK: - UI 컴포넌트 설정
    
    private let logoLabel = UILabel().then {
        $0.textColor = UIColor(named: "Black")
        $0.font = UIFont(name: "Pretendard-Bold", size: 30)
        $0.text = "Mohaji Tech Blog"
        $0.textAlignment = .left
    }
    
    private let subtitleLabel = UILabel().then {
        $0.textColor = UIColor(named: "Gray 2")
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.text = "이메일로 로그인"
        $0.textAlignment = .left
    }
    
    private let emailFieldBlock = InputFormView(contentTitle: "email", fieldPlaceholder: "Mohaji@naver.com", type: .emailAddress)
    
    private let loginButton = AuthButton(title: "로그인")
    
    private let toSignUpButton = UIButton().then {
        
        let fullString = "아직 회원이 아니신가요? 회원가입"
        let attributedString = NSMutableAttributedString(string: fullString)
        
        attributedString.addAttributes([
            .font: UIFont(name: "Pretendard-Medium", size: 14),
            .foregroundColor: UIColor(named: "Info")
        ], range: NSRange(location: 0, length: 13))
        
        attributedString.addAttributes([
            .font: UIFont(name: "Pretendard-Bold", size: 14),
            .foregroundColor: UIColor(named: "Info")
        ], range: NSRange(location: 14, length: 4))
        
        $0.setAttributedTitle(attributedString, for: .normal)
    }
    
    weak var delegate: EmailViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupActions()
        setupInputFormViewDelegate(for: emailFieldBlock)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - UI 설정
    
    private func setupUI() {
        backgroundColor = UIColor(named: "Bg 1")
        setupHierarchy()
        setupConstraints()
    }
    
    private func setupHierarchy() {
        addSubview(surfaceView)
        [logoLabel, subtitleLabel, emailFieldBlock, loginButton, toSignUpButton].forEach { surfaceView.addSubview($0) }
    }
    
    private func setupConstraints() {
        
        logoLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(186)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(logoLabel.snp.bottom).offset(20)
            $0.trailing.leading.equalTo(logoLabel)
        }
        
        emailFieldBlock.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(60)
            $0.leading.trailing.equalTo(logoLabel)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(emailFieldBlock.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(logoLabel)
            $0.height.equalTo(44)
        }
        
        toSignUpButton.snp.makeConstraints {
            $0.top.equalTo(loginButton).offset(60)
            $0.leading.trailing.equalTo(logoLabel)
            
        }
    }
    
    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        toSignUpButton.addTarget(self, action: #selector(toSignUpButtonTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
    }
    
    @objc private func loginButtonTapped() {
        guard let email = emailFieldBlock.getValue(),
        ValidationUtility.isValidEmail(email) else {
            emailFieldBlock.representError(isHidden: false, errorMessage: "올바른 이메일 형식이 아닙니다.")
            return
        }
        
        delegate?.emailViewDidTapLogin(email: email)
    }
    
    @objc private func toSignUpButtonTapped() {
        delegate?.emailViewDidTapSignUpBtn()
    }
    
    @objc private func didTapBackButton() {
        delegate?.emailViewDidTapBackButton()
    }
    
}

