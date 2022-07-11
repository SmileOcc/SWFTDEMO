//
//  YXStockLivePopupView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/11/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXStockLivePopupView: QMUIPopupContainerView {
    
    lazy var cell: YXLiveStockListCell = {
        let cell = YXLiveStockListCell(style: .default, reuseIdentifier: nil)
        cell.indexLabel.removeFromSuperview()
        cell.contentContentView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(12)
        }
        cell.line.removeFromSuperview()
        cell.contentView.backgroundColor = .clear
        cell.backgroundColor = .clear
        
        return cell
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentEdgeInsets = .zero
        maskViewBackgroundColor = .clear
        contentView.addSubview(cell)

        backgroundColor = UIColor(hexString: "#E8F4FD")

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func sizeThatFits(inContentView size: CGSize) -> CGSize {
        return CGSize(width: YXConstant.screenWidth - 24, height: 70)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        cell.frame = self.contentView.bounds
    }
        
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
