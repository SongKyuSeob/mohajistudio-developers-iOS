//
//  MenuView.swift
//  mohajistudio-developers-iOS
//
//  Created by 송규섭 on 2/12/25.
//

import UIKit

protocol MenuViewDelegate: AnyObject {
    func didTapCloseButton()
    func didSelectMenuItem(_ index: MenuItem)
}

class MenuView: UIView {
    
    var onLoginTapped: (() -> Void)?
    
    weak var delegate: MenuViewDelegate?
    
    private let sideMenuViewModel = SideMenuViewModel()
    
    private(set) var tableView = UITableView(frame: .zero, style: .grouped).then {
        $0.backgroundColor = UIColor(named: "Bg 1")
        $0.register(MenuStringCell.self, forCellReuseIdentifier: MenuStringCell.identifier)
        $0.register(DevelopersCell.self, forCellReuseIdentifier: DevelopersCell.identifier)
        $0.register(ProfileHeaderView.self, forHeaderFooterViewReuseIdentifier: ProfileHeaderView.identifier)
        $0.register(DevelopersHeaderView.self, forHeaderFooterViewReuseIdentifier: DevelopersHeaderView.identifier)
        $0.sectionHeaderTopPadding = 0
        $0.separatorStyle = .none
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    private func setupUI() {
        setupHierarchy()
        setupConstraints()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupHierarchy() {
        addSubview(tableView)
    }
    
    private func setupConstraints() {
        
        tableView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.bottom.equalToSuperview()
        }
    }
    
}

extension MenuView: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return sideMenuViewModel.menuItems.count
        case 1:
            return sideMenuViewModel.developers.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuStringCell.identifier, for: indexPath) as? MenuStringCell else {
                return UITableViewCell()
            }
            cell.configure(title: sideMenuViewModel.menuItems[indexPath.row].title)
            
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: DevelopersCell.identifier, for: indexPath) as? DevelopersCell else {
                return UITableViewCell()
            }
            let isLastCell = indexPath.row == sideMenuViewModel.developers.count - 1
            cell.configure(user: sideMenuViewModel.developers[indexPath.row], isLastCell: isLastCell)
            
            // 첫 번째 셀인 경우
            if indexPath.row == 0 {
                cell.containerView.clipsToBounds = true
                cell.containerView.layer.cornerRadius = 16
                cell.containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]  // 상단 왼쪽, 오른쪽 코너
            }
            // 마지막 셀인 경우
            else if indexPath.row == sideMenuViewModel.developers.count - 1 {
                cell.containerView.clipsToBounds = true
                cell.containerView.layer.cornerRadius = 16
                cell.containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]  // 하단 왼쪽, 오른쪽 코너
            }
            // 중간 셀들
            else {
                cell.containerView.layer.cornerRadius = 0
            }
            
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            let selectedItem = sideMenuViewModel.menuItems[indexPath.row]
            delegate?.didSelectMenuItem(selectedItem)
        case 1:
            return
        default:
            return
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 56
        case 1:
            return 74
        default:
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProfileHeaderView.identifier) as? ProfileHeaderView else {
                return nil
            }
            
            if sideMenuViewModel.isLoggedIn {
                if let userInfo = sideMenuViewModel.userInfo {
                    print("UserInfo exists:", userInfo)
                    headerView.configure(user: userInfo)
                } else {
                    print("UserInfo is nil")
                }
            } else {
                headerView.configureForGuest()
            }
            
            headerView.onLoginTapped = { [weak self] in
                self?.onLoginTapped?()
            }
            
            headerView.onCloseMenuTapped = { [weak self] in
                self?.delegate?.didTapCloseButton()
            }
            
            return headerView
        case 1:
            guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: DevelopersHeaderView.identifier) as? DevelopersHeaderView else {
                return nil
            }
            if sideMenuViewModel.isLoggedIn {
                headerView.hideSeparatorView(isHidden: false)
            } else {
                headerView.hideSeparatorView(isHidden: true)
            }
            
            return headerView
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height: CGFloat
        switch section {
        case 0:
            height = sideMenuViewModel.isLoggedIn ? 120 : 40
            print("Header height for section 0: \(height), isLoggedIn: \(sideMenuViewModel.isLoggedIn)")
            return height
        case 1:
            return 61
        default:
            return 0
        }
    }
    
}



