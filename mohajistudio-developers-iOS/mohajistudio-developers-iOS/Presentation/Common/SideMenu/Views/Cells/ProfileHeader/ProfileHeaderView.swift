//
//  ProfileHeaderView.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 2/13/25.
//

import UIKit

class ProfileHeaderView: UITableViewHeaderFooterView {
    
    static let identifier = "ProfileHeaderView"
    
    private let guestView = GuestProfileHeaderView()
    private let userProfileView = UserProfileHeaderView()
    
    var onLoginTapped: (() -> Void)? {
        didSet {
            guestView.onLoginTapped = onLoginTapped
        }
    }
    
    var onCloseMenuTapped: (() -> Void)? {
        didSet {
            guestView.onCloseMenuTapped = onCloseMenuTapped
            userProfileView.onCloseMenuTapped = onCloseMenuTapped
        }
    }
        
    private let separatorView = UIView().then {
        $0.backgroundColor = UIColor(named: "Bg 2")
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    private func setupUI() {
        setupHierarchy()
        setupConstraints()
    }
    
    private func setupHierarchy() {
        contentView.addSubview(guestView)
    }
    
    private func setupConstraints() {
        guestView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureForGuest() {
        // 먼저 모든 뷰 제거
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // 게스트 뷰만 추가
        contentView.addSubview(guestView)
        guestView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func configure(user: SimpleUserInfo) {
        // 먼저 모든 뷰 제거
        contentView.subviews.forEach { $0.removeFromSuperview() }
        
        // 유저 프로필 뷰만 추가
        contentView.addSubview(userProfileView)
        userProfileView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        userProfileView.configure(user: user)
    }
    
}
