//
//  YXSegmentView.swift
//  uSmartOversea
//
//  Created by ysx on 2021/12/28.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXSegmentView: UIView {

    var clickItme :((_ index:YXExchangeType)->(Void))?
    
    
    lazy var topView : UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        return view
    }()
    
    lazy var bgImageView: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage.init(named: "icon_markt_mask_right")
        return imageView
    }()
    
    private lazy var currentBtn:UIButton = UIButton()
    
    private lazy var line1:UIView = lineView()
    private lazy var line2:UIView = lineView()
    
    fileprivate func lineView() -> UIView{
        let lineView = UIView()
        lineView.backgroundColor = UIColor.qmui_color(withHexString: "#FFFFFF")?.withAlphaComponent(0.2)
        return lineView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    
    func setupUI() {
        backgroundColor = .clear
        addSubview(bgImageView)
        addSubview(topView)
       
       topView.snp.makeConstraints { make in
          make.edges.equalToSuperview()
        }
        bgImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var chlidViews:[UIView] = [UIView]()
    
    func addChildView(_ sub:UIView)  {
        if chlidViews.contains(sub) == false {
            chlidViews.append(sub)
            addSubview(sub)
            sub.snp.makeConstraints { make in
                make.bottom.left.right.equalToSuperview()
                make.top.equalTo(topView.snp.bottom)
            }
        }
    }
    
    private var subTitles:[YXExchangeType] = [YXExchangeType]()
    private var titlesBtn:[UIButton] = [UIButton]()
    func addTitles(titles:[YXExchangeType]) {
        subTitles.removeAll()
        titlesBtn.forEach { btn in
            btn.removeFromSuperview()
        }
        titlesBtn.removeAll()
        
        subTitles = titles
        
        for (_,subStr) in subTitles.enumerated() {
            let btn = creatBtn(title: subStr.displayText,needBubble: subStr == .sg)
            btn.tag = subStr.rawValue
            titlesBtn.append(btn)
        }
        currentBtn = titlesBtn.first ?? UIButton()
        selectMarket(button: currentBtn)
        layoutTitleBtn()
    }
    
    fileprivate func layoutTitleBtn(){

        if titlesBtn.count == 0{
            return
        }
        let w = (YXConstant.screenWidth - 32) / CGFloat(titlesBtn.count)
        
        titlesBtn.forEach { btn in
            topView.addArrangedSubview(btn)
            btn.snp.makeConstraints { make in
                make.width.equalTo(w)
                make.height.equalTo(36)
            }
        }
        addSubview(line1)
        line1.isHidden = true
        line1.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(11)
            make.centerY.equalToSuperview()
            make.left.equalTo(w)
        }
        addSubview(line2)
        line2.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(11)
            make.centerY.equalToSuperview()
            make.left.equalTo(w * 2)
        }
    }
    
    fileprivate func creatBtn(title:String,needBubble:Bool)->UIButton{
        let btn = QMUIButton()
        btn.imagePosition = .right
        btn.spacingBetweenImageAndTitle = 4
        btn.titleLabel?.textAlignment = .center
        btn.setTitle(title, for: .normal)
        btn.setTitle(title, for: .selected)
        btn.setTitleColor(.white, for: .selected)
        btn.setTitleColor(UIColor.qmui_color(withHexString: "#FFFFFF")?.withAlphaComponent(0.5), for: .normal)
        btn.addTarget(self, action: #selector(clickBtn), for: .touchUpInside)
        btn.titleLabel?.font = .systemFont(ofSize: 14)
//        if needBubble {
//            btn.setImage(UIImage.init(named: "icon_bubble_new"), for: .normal)
//        }
        return btn
    }
    
    @objc func clickBtn(button:UIButton){
        if currentBtn == button {
            return
        }
        currentBtn = button
        titlesBtn.forEach { btn in
            btn.isSelected = false
            btn.titleLabel?.font = .systemFont(ofSize: 14)
        }
        if titlesBtn.count > 1 {
            if button == titlesBtn.first {
                bgImageView.image = UIImage.init(named: "icon_markt_mask_right")
                line1.isHidden = true
                line2.isHidden = false
            }else if button == titlesBtn.last {
                bgImageView.image = UIImage.init(named: "icon_markt_mask_left")
                line1.isHidden = false
                line2.isHidden = true
            } else {
                bgImageView.image = UIImage.init(named: "icon_markt_mask_center")
                line1.isHidden = true
                line2.isHidden = true
            }
        }
        self.selectMarket(button: button)
        clickItme?(YXExchangeType(rawValue: button.tag) ?? .us)
    }
    
    func selectMarket(button:UIButton) {
        button.isSelected = true
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

