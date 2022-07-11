//
//  YXSquareSectionCell.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/6.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit


/// 带市场的组头
class YXSquareMarketSectionCell: UICollectionViewCell {
    
    var clickCallBack: (()->())?
    
    var segmentCallBack: ((_ index: Int)->())?
    let titleLabel = UILabel.init(text: "", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 20))!
    let subTitleLabel = UILabel.init(text: "", textColor: QMUITheme().textColorLevel3(), textFont: UIFont.systemFont(ofSize: 12))!
    let arrowImgaeView = UIImageView.init(image: UIImage(named: "right_black_arrow"))
    let clickControl = UIControl.init()
    
    let segmentView = UISegmentedControl.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        
        let hLineView  = UIView.init()
        hLineView.backgroundColor = UIColor.qmui_color(withHexString: "#E5E5E5")
        
        segmentView.insertSegment(withTitle: YXLanguageUtility.kLang(key: "hold_hk_account"), at: 0, animated: false)
        segmentView.insertSegment(withTitle: YXLanguageUtility.kLang(key: "hold_us_account"), at: 1, animated: false)
        segmentView.backgroundColor = QMUITheme().foregroundColor()
        
        if #available(iOS 13, *) {
            let tintColorImage = UIImage.qmui_image(with: QMUITheme().themeTextColor())
            segmentView.setBackgroundImage(UIImage.qmui_image(with: UIColor.clear), for: .normal, barMetrics: .default)
            segmentView.setBackgroundImage(tintColorImage, for: .selected, barMetrics: .default)
            segmentView.setBackgroundImage(UIImage.qmui_image(with: QMUITheme().themeTextColor().withAlphaComponent(0.2)), for: .highlighted, barMetrics: .default)
            segmentView.setBackgroundImage(tintColorImage, for: [.highlighted, .selected], barMetrics: .default)
            
        }
        segmentView.layer.borderWidth = 1
        segmentView.layer.borderColor = QMUITheme().themeTextColor().cgColor
        segmentView.layer.cornerRadius = 4
        segmentView.clipsToBounds = true
        let normarAtt = [NSAttributedString.Key.foregroundColor: QMUITheme().mainThemeColor(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        let selectAtt = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]
        segmentView.setTitleTextAttributes(normarAtt, for: .normal)
        segmentView.setTitleTextAttributes(selectAtt, for: .selected)
        
        segmentView.addTarget(self, action: #selector(self.segmentAction(_:)), for: .valueChanged)
        
        clickControl.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
        contentView.backgroundColor = QMUITheme().foregroundColor()
        
        let topView = UIView.init()
        
        contentView.addSubview(topView)
        contentView.addSubview(hLineView)
        
        topView.addSubview(titleLabel)
        topView.addSubview(subTitleLabel)
        topView.addSubview(arrowImgaeView)
        topView.addSubview(clickControl)
        
        topView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(55)
        }
        
        hLineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.height.equalTo(1)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
//            make.height.equalTo(28)
        }
        arrowImgaeView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
//            make.height.equalTo(17)
        }
        subTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(titleLabel)
            make.left.equalTo(titleLabel.snp.right).offset(6)
        }
        
        clickControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 下面的市场
        contentView.addSubview(segmentView)
        segmentView.snp.makeConstraints { make in
            make.top.equalTo(topView.snp.bottom).offset(15)
            make.width.equalTo(144)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
        }
        
    }
    
    @objc func click(_ sender: UIControl) {
        clickCallBack?()
    }
    
    @objc func segmentAction(_ sender: UISegmentedControl) {
        segmentCallBack?(sender.selectedSegmentIndex)
    }
}



class YXSquareSectionCell: UICollectionViewCell {
    
    var clickCallBack: (()->())?
    
    let titleLabel = UILabel.init(text: "", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 20, weight: .medium))!
    
    let subTitleLabel = UILabel.init(text: "", textColor: QMUITheme().textColorLevel2(), textFont: UIFont.systemFont(ofSize: 12))!
    
    let arrowImgaeView = UIImageView.init(image: UIImage(named: "guessup_right_arrow"))
 
    let clickControl = UIControl.init()
    
    let hLineView  = UIView.init()
    
    var model: YXSquareSection? {
        
        didSet {
            self.titleLabel.text = model?.name
            self.subTitleLabel.text = model?.subName
            
            if let color = model?.color {
                subTitleLabel.textColor = color
            }            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
                
        hLineView.backgroundColor = QMUITheme().separatorLineColor()
        
        clickControl.addTarget(self, action: #selector(self.click(_:)), for: .touchUpInside)
        contentView.backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(arrowImgaeView)
        contentView.addSubview(clickControl)
        contentView.addSubview(hLineView)
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        arrowImgaeView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
        subTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right).offset(6)
        }
        
        clickControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        hLineView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()            
            make.height.equalTo(1)
        }
    }
    
    @objc func click(_ sender: UIControl) {
        clickCallBack?()
    }
}
