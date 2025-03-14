//
//  ProfileDefaultHeaderView.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 3/14/25.
//

import UIKit

class GuestProfileHeaderView: UIView {

    var onLoginTapped: (() -> Void)?
    var onCloseMenuTapped: (() -> Void)?
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "Close"), for: .normal)
        $0.tintColor = UIColor(named: "Primary")
    }
    
    private let loginButton = UIButton().then {
        $0.setImage(UIImage(named: "Login"), for: .normal)
        $0.tintColor = UIColor(named: "Primary")
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = UIColor(named: "Bg 2")
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
        addSubview(closeButton)
        addSubview(loginButton)
        addSubview(separatorView)
    }
    
    private func setupConstraints() {
        
        closeButton.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(24)
        }
        
        loginButton.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(24)
        }
        
        separatorView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.height.equalTo(2)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
    }
    
    private func setupAction() {
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
    }
    
    @objc private func didTapLoginButton() {
        self.onLoginTapped?()
    }
    
    @objc private func didTapCloseButton() {
        self.onCloseMenuTapped?()
    }
    
}
