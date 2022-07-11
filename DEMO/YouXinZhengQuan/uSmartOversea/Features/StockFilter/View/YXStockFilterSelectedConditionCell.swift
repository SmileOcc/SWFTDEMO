//
//  YXStockFilterSelectedConditionCell.swift
//  uSmartOversea
//
//  Created by youxin on 2020/9/7.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockFilterSelectedConditionCell: YXTableViewCell {
    
    var deleteAction: (() -> Void)?
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = QMUITheme().textColorLevel1()
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.3
        return label
    }()
    
    lazy var deleteButton: QMUIButton = {
        let button = QMUIButton()
        button.setImage(UIImage(named: "red_delete"), for: .normal)
        _ = button.rx.tap.takeUntil(self.rx.deallocated).subscribe(onNext: { [weak self](e) in
            self?.deleteAction?()
        })
        return button
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func initialUI() {
        self.selectionStyle = .none
        self.backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(contentLabel)
        contentView.addSubview(deleteButton)
        
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.right.equalTo(deleteButton.snp.left).offset(-5)
            make.top.bottom.equalToSuperview()
        }
        
        deleteButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(30)
        }
    }
    
    func creatSelectedValueText(arr: [YXStokFilterListItem]) -> [String] {
        var detail: String?
        var textArr: [String] = []
        for subItem in arr {
            if subItem.isSelected  {
//                if subItem.key == "custom" {
//                    detail = "\(subItem.min)~\(subItem.max)"
//                }else {
//                    detail = subItem.name
//                }
                detail = subItem.name
                if let text = detail {
                    textArr.append(text)
                }
            }
        }
        
        return textArr
    }
    
    override func refreshUI() {
        if let item = self.model as? YXStockFilterItem {
            if  item.queryValueList.count == 1 {
                let arr = creatSelectedValueText(arr: item.queryValueList.first?.list ?? [])
                if arr.count > 1 {
                    let text = arr.joined(separator: ",")
                    contentLabel.text = "\(item.name ?? "--"):  \(text)"
                }else {
                    contentLabel.text = "\(item.name ?? "--"):  \(arr.first ?? "--")"
                }
            }else if item.queryValueList.count == 2 {
                // 联动的列表
                let arr1 = creatSelectedValueText(arr: item.queryValueList.first?.list ?? [])
                let arr2 = creatSelectedValueText(arr: item.queryValueList[1].list)
                contentLabel.text = "\(item.name ?? "--"):  \(arr1.first ?? "--")      \(arr2.first ?? "--")"
            }
        }
    }

}
