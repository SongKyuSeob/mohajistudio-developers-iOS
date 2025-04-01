//
//  ResetPwdView.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 3/17/25.
//

import UIKit

protocol ResetPwdViewDelegate: AnyObject {
    func resetPwdViewDidTapBack()
    func resetPwdViewDidTapNext(password: String)
}

class ResetPwdView: BaseStepView {
    
    private let titleLabel = UILabel().then {
        $0.text = "비밀번호 재설정"
        $0.textColor = UIColor(named: "Black")
        $0.textAlignment = .left
        $0.font = UIFont(name: "Pretendard-Bold", size: 24)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "비밀번호를 설정해주세요"
        $0.textColor = UIColor(named: "Gray 2")
        $0.textAlignment = .left
        $0.font = UIFont(name: "Pretendard-Medium", size: 16)
    }
    
    private let infoButton = UIButton().then {
        $0.setImage(UIImage(systemName: "info.circle"), for: .normal)
        $0.tintColor = UIColor(named: "Gray 2")
    }
    
    private let tooltipView = PasswordTooltipView()
    
    private let passwordFieldBlock = InputFormView(contentTitle: "비밀번호", fieldPlaceholder: "**********", type: .password)
    
    private let checkPasswordFieldBlock = InputFormView(contentTitle: "비밀번호 확인", fieldPlaceholder: "***********", type: .password)
    
    private let nextButton = UIButton().then {
        $0.backgroundColor = UIColor(named: "Primary")
        $0.layer.cornerRadius = 8.0
        $0.layer.cornerCurve = .continuous
        $0.setTitle("다음", for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 16)
        $0.titleLabel?.textColor = .white
    }
    
    // MARK: - Properties
    weak var delegate: ResetPwdViewDelegate?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
        [passwordFieldBlock, checkPasswordFieldBlock].forEach {
            setupTextFieldDelegate(for: $0.getTextField())
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = UIColor(named: "Bg 1")
        setupHierarchy()
        setupConstraints()
        setupTooltip()
    }
    
    private func setupHierarchy() {
        [titleLabel, subTitleLabel, infoButton, passwordFieldBlock, checkPasswordFieldBlock, nextButton]
            .forEach { surfaceView.addSubview($0) }
        
        surfaceView.bringSubviewToFront(infoButton)
    }
    
    private func setupConstraints() {
        
        let passwordTitleLabel = passwordFieldBlock.getTitleLabel()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(titleLabel)
        }
        
        passwordFieldBlock.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(52)
        }
        
        infoButton.snp.makeConstraints {
            $0.centerY.equalTo(passwordTitleLabel.snp.centerY)
            $0.leading.equalTo(passwordTitleLabel.snp.trailing).offset(5)
        }
        
        checkPasswordFieldBlock.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(passwordFieldBlock.snp.bottom).offset(16)
        }
        
        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalTo(titleLabel)
            $0.top.equalTo(checkPasswordFieldBlock.snp.bottom).offset(40)
            $0.height.equalTo(44)
        }
        
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        passwordFieldBlock.getTextField().addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        checkPasswordFieldBlock.getTextField().addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    // MARK: - Actions
    @objc private func backButtonTapped() {
        delegate?.resetPwdViewDidTapBack()
    }
    
    @objc private func nextButtonTapped() {
        guard let password = passwordFieldBlock.getValue() else {
            passwordFieldBlock.representError(isHidden: false, errorMessage: "비밂번호를 입력해주세요.")
            setNeedsLayout()
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
            return
        }
        
        guard ValidationUtility.isValidPassword(password) else { passwordFieldBlock.representError(isHidden: false, errorMessage: "유효하지 않은 비밀번호입니다. 안내에 따라 다시 설정해주세요."); return }
        
        guard let checkPassword = checkPasswordFieldBlock.getValue(), password == checkPassword else { checkPasswordFieldBlock.representError(isHidden: false, errorMessage: "비밀번호와 일치하지 않습니다."); return }
        
        delegate?.resetPwdViewDidTapNext(password: password)
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if textField == passwordFieldBlock.getTextField() {
            passwordFieldBlock.representError(isHidden: true, errorMessage: nil)
        } else if textField == checkPasswordFieldBlock.getTextField() {
            checkPasswordFieldBlock.representError(isHidden: true, errorMessage: nil)
        }
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    func showVerificationError(error: String) {
        passwordFieldBlock.representError(isHidden: false, errorMessage: error)
        
        setNeedsLayout()
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            print("height 업데이트 완료")
        }
    }
    
    func resetVerificationError() {
        passwordFieldBlock.representError(isHidden: true, errorMessage: nil)
        
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    private func setupTooltip() {
        tooltipView.isHidden = true
        surfaceView.addSubview(tooltipView)
        
        tooltipView.snp.makeConstraints {
            $0.leading.equalTo(infoButton.snp.trailing).offset(8)
            $0.top.equalTo(infoButton.snp.bottom).offset(4)
        }
        
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
    }
    
    @objc private func infoButtonTapped() {
        tooltipView.isHidden.toggle()
        
        if !tooltipView.isHidden {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.tooltipView.isHidden = true
            }
        }
    }

}
