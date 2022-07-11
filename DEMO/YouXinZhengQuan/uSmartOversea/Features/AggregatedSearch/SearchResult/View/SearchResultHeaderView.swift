//
//  SearchResultHeaderView.swift
//  YouXinZhengQuan
//
//  Created by Evan on 2022/3/2.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchResultHeaderView: UITableViewHeaderFooterView {

    var didTap: (() -> Void)?

    var searchType: SearchType? {
        didSet {
            switch searchType {
            case .community(let subType):
                titleLabel.text = subType.title
            default:
                titleLabel.text = searchType?.title
            }
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .mediumFont20()
        label.textColor = QMUITheme().textColorLevel1()
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundColor = QMUITheme().foregroundColor()
        contentView.backgroundColor = QMUITheme().foregroundColor()
        initSubviews()

        rx.tapGesture().subscribe(onNext: { [weak self] _ in
            self?.didTap?()
        }).disposed(by: rx.disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initSubviews() {
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
        }

        let arrowButton = QMUIButton()
        arrowButton.setImage(UIImage(named: "icon_detail_arrow"), for: .normal)
        arrowButton.tintColor = QMUITheme().textColorLevel1()
        arrowButton.adjustsImageTintColorAutomatically = true
        contentView.addSubview(arrowButton)
        arrowButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
    }

}
