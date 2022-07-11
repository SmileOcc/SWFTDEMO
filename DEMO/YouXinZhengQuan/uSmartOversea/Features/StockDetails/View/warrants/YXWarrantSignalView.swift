//
//  YXWarrantSignalView.swift
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/6/5.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import Foundation
import NSObject_Rx

class YXWarrantSignalView: UIView {
    
    @objc var tapItemAction: ((_ market: String, _ symbol: String) -> Void)?
    @objc var tapSignalMoreAction: (() -> Void)?
    
    @objc var selfheight: CGFloat {
        if let list = signalList {
            return CGFloat(list.count) * 68.0 + 40.0
        }else {
            return 0.0
        }
    }
    
    @objc var signalList: [YXBullBearPbSignalItem]? {
        didSet {
            if let list = signalList, list.count > 0 {
                isHidden = false
                
                signalView.removeAllSubviews()
                
                let cells = list.map { [weak self] (item) -> YXBullBearLongShortSignalCell in
                    let cell = YXBullBearLongShortSignalCell(style: .default, reuseIdentifier: nil)
                    cell.item = item
                    cell.contentView.snp.makeConstraints { make in
                        make.edges.equalToSuperview()
                    }
                    cell.tapStockNameAction = self?.tapItemAction
                    self?.signalView.addSubview(cell)
                    return cell
                }
                
//                while cells.count < 3 {
//                    let cell = YXBullBearLongShortSignalCell(style: .default, reuseIdentifier: nil)
//                    cell.removeAllSubviews()
//                    signalView.addSubview(cell)
//                    cells.append(cell)
//                }
                
                if cells.count == 1 {
                    cells.first?.snp.makeConstraints { make in
                        make.left.right.top.bottom.equalToSuperview()
                    }
                }else {
                    cells.snp.distributeViewsAlong(axisType: .vertical, fixedSpacing: 0, leadSpacing: 0, tailSpacing: 0)
                    cells.snp.makeConstraints { (make) in
//                        make.height.equalTo(68)
                        make.left.right.equalToSuperview()
                    }
                }
                
                signalView.snp.updateConstraints { make in
                    make.height.equalTo(list.count * 68)
                }
                
            } else {
                isHidden = true
            }
        }
    }
    lazy var signalView: UIView = {
        let stackView = UIView()
        return stackView
    }()
    
    lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setTitle(YXLanguageUtility.kLang(key: "newStock_detail_see_more"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(QMUITheme().textColorLevel3(), for: .normal)
        button.setImage(UIImage.init(named: "grey_right_arrow"), for: .normal)
        button.setButtonImagePostion(.right, interval: 2)
        
        button.rx.tap.subscribe(onNext: { [weak self] () in
            if let action = self?.tapSignalMoreAction {
                action()
            }
        }).disposed(by: rx.disposeBag)
        
        return button
    }()
    
    lazy var signalTitleView: UIView = {
        
        let view = YXMarketCommonHeaderCell()
        view.title = YXLanguageUtility.kLang(key: "technical_signal")
        view.action = { [weak self] in
            if let action = self?.tapSignalMoreAction {
                action()
            }
        }
        
        return view
    }()
    
    lazy var subTitleView: YXBullBearSectionHeaderSubTitleView = {
        let view = YXBullBearSectionHeaderSubTitleView(frame: .zero, sectionType: .longShortSignal)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
        
        addSubview(signalTitleView)
        addSubview(signalView)
        
        signalTitleView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        signalView.snp.makeConstraints { (make) in
            make.top.equalTo(signalTitleView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(204)
        }
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
