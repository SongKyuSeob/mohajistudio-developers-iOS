//
//  UserProfileHeaderView.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 3/14/25.
//

import UIKit

class UserProfileHeaderView: UIView {
    
    var onCloseMenuTapped: (() -> Void)?
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "Close"), for: .normal)
        $0.tintColor = UIColor(named: "Primary")
    }
    
    private let profileImageView = UIImageView().then {
        $0.image = UIImage(named: "Default_profile") // 임시 프로필 이미지
        $0.layer.cornerRadius = 8
        $0.clipsToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.text = "Name"
        $0.textColor = UIColor(named: "Black")
        $0.font = UIFont(name: "Pretendard-Bold", size: 16)
    }
    
    private let roleLabel = UILabel().then {
        $0.text = "Developer"
        $0.textColor = UIColor(named: "Gray 3")
        $0.font = UIFont(name: "Pretendard-Medium", size: 14)
    }
    
    private let topSeparatorView = UIView().then {
        $0.backgroundColor = UIColor(named: "Bg 2")
    }
    
    private let bottomSeparatorView = UIView().then {
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
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(roleLabel)
        addSubview(topSeparatorView)
        addSubview(bottomSeparatorView)
    }
    
    private func setupConstraints() {
        
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(8)
            $0.width.height.equalTo(24)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.top)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        roleLabel.snp.makeConstraints {
            $0.bottom.equalTo(profileImageView.snp.bottom)
            $0.leading.equalTo(nameLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        topSeparatorView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.top).offset(-20)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
        }
        
        bottomSeparatorView.snp.makeConstraints {
            $0.bottom.equalTo(roleLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalTo(topSeparatorView.snp.horizontalEdges)
            $0.height.equalTo(1)
        }
        
    }
    
    func setupAction() {
        closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
    }
    
    func configure(user: SimpleUserInfo) {
        print("유저 정보 업데이트 - 사이드 메뉴")
        if let profileImage = user.profileImage {
            // 이미지 로딩 로직
        } else {
            profileImageView.image = UIImage(named: "Default_profile")
        }
        
        if let jobRole = user.jobRole {
            roleLabel.text = jobRole
        } else {
            roleLabel.text = "iOS Developer"
        }
        
        nameLabel.text = user.nickname
    }
    
    @objc private func didTapCloseButton() {
        self.onCloseMenuTapped?()
    }
    
}
