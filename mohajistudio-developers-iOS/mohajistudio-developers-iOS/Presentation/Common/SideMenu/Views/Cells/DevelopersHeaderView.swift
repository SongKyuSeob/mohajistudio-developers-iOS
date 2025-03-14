//
//  DevelopersHeaderView.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 2/13/25.
//

import UIKit

class DevelopersHeaderView: UITableViewHeaderFooterView {

    static let identifier = "DevelopersHeaderView"
    
    private let closeButton = UIButton().then {
        $0.setImage(UIImage(named: "Close"), for: .normal)
        $0.tintColor = UIColor(named: "Primary")
    }
    
    private let separatorView = UIView().then {
        $0.backgroundColor = UIColor(named: "Bg 2")
    }
    
    private let developersBlock = HeaderWithIconView().then {
        $0.configure(iconName: "Users", headerTitle: "Developers")
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    private func setupUI() {
        setupHierarchy()
        setupConstraints()
    }
    
    private func setupHierarchy() {
        contentView.addSubview(separatorView)
        contentView.addSubview(developersBlock)
    }
    
    private func setupConstraints() {
        separatorView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        developersBlock.snp.makeConstraints {
            $0.top.equalTo(separatorView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(24)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    
    private func setupActions() {
        
    }

    func hideSeparatorView(isHidden: Bool) {
        separatorView.isHidden = isHidden
    }

}
