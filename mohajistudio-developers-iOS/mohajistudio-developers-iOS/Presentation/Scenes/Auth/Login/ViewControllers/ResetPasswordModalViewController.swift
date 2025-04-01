//
//  ResetPasswordModalView.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 3/14/25.
//

import UIKit

class ResetPasswordModalViewController: UIViewController {
    
    var resetButtonTapped: (() -> Void)?
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = UIColor(named: "Black")?.withAlphaComponent(0.4)
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = UIColor(named: "Surface 1")
        $0.layer.cornerRadius = 16
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "비밀번호 재설정"
        $0.font = UIFont(name: "Pretendard-SemiBold", size: 16)
        $0.textColor = UIColor(named: "Black")
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "비밀번호 재설정 인증 이메일을 보내드릴까요?"
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
        $0.textColor = UIColor(named: "Gray 2")
    }
    
    private let resetButton = UIButton().then {
        $0.layer.cornerRadius = 8
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(named: "Error")?.cgColor
        $0.setTitle("재설정", for: .normal)
        $0.setTitleColor(UIColor(named: "Error"), for: .normal)
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
    }

    private let cancelButton = UIButton().then {
        $0.layer.cornerRadius = 8
        $0.setTitleColor(UIColor(named: "White"), for: .normal)
        $0.setTitle("취소", for: .normal)
        $0.backgroundColor = UIColor(named: "Success")
        $0.titleLabel?.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupAction()
    }
    
    private func setupUI() {
        setupHierarchy()
        setupConstraints()
    }
    
    private func setupHierarchy() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subTitleLabel)
        containerView.addSubview(resetButton)
        containerView.addSubview(cancelButton)
    }
    
    private func setupConstraints() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(164)
            $0.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.top.equalToSuperview().offset(24)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalTo(titleLabel)
        }
        
        cancelButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-24)
            $0.bottom.equalToSuperview().offset(-24)
            $0.width.equalTo(72)
            $0.height.equalTo(32)
        }
        
        resetButton.snp.makeConstraints {
            $0.trailing.equalTo(cancelButton.snp.leading).offset(-8)
            $0.height.equalTo(cancelButton)
            $0.width.equalTo(84)
            $0.bottom.equalTo(cancelButton.snp.bottom)
        }
    }
    
    private func setupAction() {
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(didTapResetButton), for: .touchUpInside)
    }
    
    @objc private func didTapResetButton() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.resetButtonTapped?()
        }
        self.dismiss(animated: false)
        
    }
    
    @objc private func didTapCancelButton() {
        self.dismiss(animated: false)
    }

}
