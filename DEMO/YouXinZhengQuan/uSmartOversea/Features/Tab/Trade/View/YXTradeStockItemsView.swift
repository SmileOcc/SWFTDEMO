//
//  YXTradeStockItemsView.swift
//  uSmartOversea
//
//  Created by Apple on 2020/4/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

import UIKit

class YXTradeStockItemsView: UIView {
    
    typealias ClosureClick = () -> Void
    
    
    // 市场类型
    private var exchangeType: YXExchangeType = .hk
    
    //新股认购
    @objc var onClickIPO: ClosureClick?
    //转入股票
    @objc var onClickShiftIn: ClosureClick?
    //IPO配售预约
    @objc var onClickIpoSub: ClosureClick?
    
    // 蓝色小标记
    lazy var markView: UIView = {
        let markView = UIView()
        markView.backgroundColor = QMUITheme().holdMark()
        return markView
    }()
    
    // 标题
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = YXLanguageUtility.kLang(key: "hold_stock_name")
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = QMUITheme().textColorLevel1()
        return titleLabel
    }()
    
    
    // 新股认购
    lazy var ipoBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_ipo", text: YXLanguageUtility.kLang(key: "hold_new_stock"))
        addTapGestureWith(view: view, sel: #selector(newStockAction))
        return view
    }()
    
    //ipo配售预约
    lazy var ipoSubBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_ipo", text: YXLanguageUtility.kLang(key: "hold_ipo_sub"))
        addTapGestureWith(view: view, sel: #selector(ipoSubAction))
        return view
    }()
    
    // 转入股票
    lazy var shiftInBtn: YXTradeItemSubView = {
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("hold_shiftin", text: YXLanguageUtility.kLang(key: "hold_shiftin"))
        addTapGestureWith(view: view, sel: #selector(shiftInAction))
        return view
    }()
    
    fileprivate lazy var ecmRedDotView: UIView = {
          let view = UIView()
          view.backgroundColor = .red
          view.isHidden = true
          view.layer.cornerRadius = 4
          view.layer.masksToBounds = true
          return view
      }()
      
      @objc var hideEcmRedDot: Bool = false {
          didSet {
              self.ecmRedDotView.isHidden = hideEcmRedDot
          }
      }
    
    //新股认购的标签
    lazy var newStockTagView: QMUIPopupContainerView = {
        let view = QMUIPopupContainerView()
        view.backgroundColor = UIColor.qmui_color(withHexString: "#F86D6D")
        view.shadowColor = UIColor.white
        view.borderColor = UIColor.qmui_color(withHexString: "#F86D6D")
        view.contentEdgeInsets = UIEdgeInsets(top: 1, left: 4, bottom: 1, right: 4)
        view.cornerRadius = 4
        view.safetyMarginsOfSuperview = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        view.textLabel?.font = .systemFont(ofSize: 10)
        view.textLabel?.textColor = UIColor.white
        view.arrowSize = CGSize(width: 4, height: 4)
        view.sourceView = self.ipoTagSourceView
        view.isUserInteractionEnabled = false
        view.isHidden = true
        self.addSubview(view)
        return view
    }()
    
    //新股认购的标签
    lazy var ipoTagSourceView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var itemHeight: CGFloat = {
        if YXUserManager.isENMode() {
            return 70
        }
        return 50
    }()
    
    lazy var placeholderButton: YXTradeItemSubView = { //占位
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("", text: "")
        return view
    }()
    
    lazy var placeholderButton2: YXTradeItemSubView = { //占位
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("", text: "")
        return view
    }()
    
    lazy var placeholderButton3: YXTradeItemSubView = { //占位
        let view = YXTradeItemSubView(frame: CGRect.zero)
        view.updateWith("", text: "")
        return view
    }()
    
    required init(frame: CGRect, exchangeType: YXExchangeType) {
        super.init(frame: frame)
        // 当前市场类型
        self.exchangeType = exchangeType
        
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initView() {
        self.isUserInteractionEnabled = true
        
        self.addSubview(self.markView)
        self.addSubview(self.titleLabel)
        
        self.markView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview().offset(17)
            make.width.equalTo(4)
            make.height.equalTo(14)
        }
        
        self.titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.markView)
            make.left.equalTo(self.markView.snp.right).offset(7)
            make.height.equalTo(22)
            make.right.equalToSuperview().offset(-8)
        }
        
        
        addSubview(shiftInBtn)
        addSubview(placeholderButton)
        var firstBtns = [YXTradeItemSubView]()
        if exchangeType == .hk || exchangeType == .us {
            addSubview(ipoBtn)
            addSubview(ipoTagSourceView)
            ipoTagSourceView.snp.makeConstraints { (make) in
                make.width.height.equalTo(1)
                make.centerX.equalTo(ipoBtn)
                make.top.equalTo(ipoBtn.snp.top).offset(12)
            }
            if exchangeType == .hk, YXUserManager.isHighWorth() {
                addSubview(ipoSubBtn)
                
                addSubview(self.ecmRedDotView)
                let ipoImgView = ipoSubBtn.imageView
                ecmRedDotView.snp.makeConstraints { (make) in
                    make.left.equalTo(ipoImgView.snp.right)
                    make.centerY.equalTo(ipoImgView.snp.top)
                    make.width.height.equalTo(8)
                }
                
                firstBtns = [ipoBtn, ipoSubBtn, shiftInBtn, placeholderButton]
            } else {
                addSubview(placeholderButton2)
                firstBtns = [ipoBtn, shiftInBtn, placeholderButton, placeholderButton2]
            }
        } else {
            addSubview(placeholderButton2)
            addSubview(placeholderButton3)
            firstBtns = [shiftInBtn, placeholderButton, placeholderButton2, placeholderButton3]
        }
        
        firstBtns.snp.distributeViewsAlong(axisType: .horizontal, fixedSpacing: 0)
        firstBtns.snp.makeConstraints { (make) in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.height.equalTo(itemHeight)//50
        }
    }
    
    func addTapGestureWith(view: UIView, sel: Selector) {
        let tap = UITapGestureRecognizer.init(target: self, action: sel)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @objc func ipoSubAction() {
        if let closure = onClickIpoSub {
            closure()
        }
    }
    
    @objc func newStockAction() {
        if let closure = onClickIPO {
            closure()
        }
    }
    
    @objc func shiftInAction() {
        if let closure = onClickShiftIn {
            closure()
        }
    }
}

