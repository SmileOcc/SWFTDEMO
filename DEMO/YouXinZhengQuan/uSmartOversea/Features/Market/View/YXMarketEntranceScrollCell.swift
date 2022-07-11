//
//  YXMarketEntranceScrollCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/10/30.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXMarketEntranceScrollCell: UICollectionViewCell {

    var tapItemAction: ((_ index: Int) -> Void)?
    var titleColor: UIColor?

    var items: [[String: String]] = [] {
        didSet {
            if oldValue.count > 0 { return }

            gridView.removeAllSubviews()

            for (i, item) in items.enumerated() {
                let itemView = YXMarketEntranceViewCell()
                itemView.backgroundColor = .clear
                itemView.icon.image = UIImage(named: item["iconName"] ?? "")
                itemView.titleLabel.text = item["title"]
                itemView.tag = i
                if let color = titleColor {
                    itemView.titleLabel.textColor = color
                }

                let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapItem(gesture:)))
                itemView.addGestureRecognizer(tap)

                gridView.addSubview(itemView)
            }
        }
    }

    lazy var gridView: QMUIGridView = {
        let view = QMUIGridView.init(column: 4, rowHeight: 72)!
        view.backgroundColor = .clear
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(gridView)
        gridView.snp.makeConstraints { (make) in
            make.top.equalTo(8)
            make.left.right.top.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tapItem(gesture: UITapGestureRecognizer) {
        self.tapItemAction?(gesture.view?.tag ?? 0)
    }

}
