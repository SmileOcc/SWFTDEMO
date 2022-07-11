//
//  YXUserCenterOneTableViewCell.swift
//  uSmartOversea
//
//  Created by Mac on 2019/9/6.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class YXUserCenterOneTableViewCell: QMUITableViewCell, YXCycleScrollViewDelegate {
    typealias YXMineHeaderBannerBlock = (_ banner:BannerList,_ index:Int)->Void
    //banner的点击回调
    var bannerSelectBlock: YXMineHeaderBannerBlock?
    
    class func bannerSize() -> CGSize {
        let width = YXConstant.screenWidth - 36
        return CGSize(width: width, height: width / 4)
    }
    
    //广告视图
    lazy var imageBannerView: YXImageBannerView = {
        let banner = YXImageBannerView(frame: CGRect(x: 0, y: 0, width: YXUserCenterOneTableViewCell.bannerSize().width, height: YXUserCenterOneTableViewCell.bannerSize().height), delegate: nil, placeholderImage: UIImage(named: "placeholder_4bi1"))!
//        banner.layer.cornerRadius = 4
//        banner.clipsToBounds = true
        return banner
    }()
    
    //全部活动
    lazy var allActBtn: QMUIButton = {
        let btn = QMUIButton(type: .custom)
        btn.setTitle(YXLanguageUtility.kLang(key: "user_all_activity"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setImage(UIImage(named: "user_all_activity"), for: .normal)
        btn.imagePosition = .right
        btn.spacingBetweenImageAndTitle = 10
        btn.titleLabel?.textAlignment = .right
        return btn
    }()
    
    //标题
    lazy var titleLab: QMUILabel = {
        let lab = QMUILabel()
        lab.font = UIFont.systemFont(ofSize: 20)
        lab.numberOfLines = 0
        lab.text = YXLanguageUtility.kLang(key: "user_activity")
        lab.textAlignment = .left
        return lab
    }()
    
    //小红点
    lazy var redDot: UIView = {
        let view = UIView()
        view.backgroundColor = QMUITheme().sell()
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        view.isHidden = true
        contentView.addSubview(view)
        return view
    }()
    
    
    var bannerAndActSpace: CGFloat = 20
    
    let actSideMargin: CGFloat = 16
    let actSpace: CGFloat = 15
    lazy var actItemWidth: CGFloat = (YXConstant.screenWidth - (actSideMargin + actSpace) * 2) / 3.0
    
    var actItems = [YXUserCenterActCardView]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.initialUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func initialUI()  {
        self.selectionStyle = .none
        self.backgroundColor = QMUITheme().foregroundColor()
        
        
        
        //广告视图
        imageBannerView.delegate = self
        contentView.addSubview(imageBannerView)
        imageBannerView.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(18)
            make.right.equalTo(self).offset(-18)
            make.height.equalTo(imageBannerView.bounds.height)
            make.top.equalToSuperview().offset(10)
        }
        
        //标题
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(18)
            make.top.equalTo(imageBannerView.snp.bottom).offset(bannerAndActSpace)
            make.height.equalTo(28)
        }
        //全部活动
        contentView.addSubview(allActBtn)
        allActBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-18)
            make.centerY.equalTo(titleLab)
        }
        
        
        //小红点
        redDot.snp.makeConstraints { (make) in
            make.right.equalTo(allActBtn.snp.left).offset(-5)
            make.centerY.equalTo(titleLab)
            make.width.height.equalTo(8.0)
        }
        
    }
    
    //更新头部视图
    func updateView(with list: [YXAdListModel]) {
        if let list = YXUserManager.shared().userBanner?.dataList, list.count > 0 {
            imageBannerView.snp.updateConstraints { (make) in
                make.height.equalTo(imageBannerView.bounds.height)
            }
            titleLab.snp.updateConstraints { (make) in
                make.top.equalTo(imageBannerView.snp.bottom).offset(bannerAndActSpace)
            }
            var arr = [String]()
            for news in list {
                arr.append(news.pictureURL ?? "")
            }
            imageBannerView.imageURLStringsGroup = arr
        }else {
            
            imageBannerView.snp.updateConstraints { (make) in
                make.height.equalTo(0)
            }
            
            titleLab.snp.updateConstraints { (make) in
                make.top.equalTo(imageBannerView.snp.bottom).offset(0)
            }
            
        }
        
        self.redDot.isHidden = YXLittleRedDotManager.shared.isHiddenActCenter()
        
        self.actItems.removeAll()
        if list.count > 0 {
            
            var lastItemView: YXUserCenterActCardView?
            
            for model in list {
                let itemView = YXUserCenterActCardView(frame: .zero)
                
                itemView.refreshUI(with: actItemWidth, model:model)
                self.actItems.append(itemView)
                
                contentView.addSubview(itemView)
                itemView.snp.makeConstraints { (make) in
                    if let lastView = lastItemView {
                        make.left.equalTo(lastView.snp.right).offset(actSpace)
                    } else {
                        make.left.equalToSuperview().offset(actSideMargin)
                    }
                    make.top.equalTo(titleLab.snp.bottom).offset(20)
                    make.width.equalTo(actItemWidth)
                    make.bottom.equalTo(self).offset(-15)//底部对齐
                }
                
                lastItemView = itemView
            }
        }
        
        
    }
}

extension YXUserCenterOneTableViewCell {
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {
        if let list = YXUserManager.shared().userBanner?.dataList, list.count > 0 {
            let banner = list[index]
            bannerSelectBlock!(banner,index)
        }
    }
}



class YXUserCenterActCardView: UIView {
    
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        addSubview(iv)
        return iv
    }()
    
    
    //标题
    private lazy var titleLab: QMUILabel = {
        let lab = QMUILabel()
        lab.font = UIFont.systemFont(ofSize: 12)
        lab.textAlignment = .center
        lab.textColor = QMUITheme().textColorLevel1()
        addSubview(lab)
        return lab
    }()
    
    //副标题
    private lazy var subTitleLab: QMUILabel = {
        let lab = QMUILabel()
        lab.font = UIFont.systemFont(ofSize: 10)
        lab.textAlignment = .center
        lab.textColor = QMUITheme().textColorLevel3()
        addSubview(lab)
        return lab
    }()
    
    //点击按钮
    private var clickBtn: UIButton = {
        let btn = UIButton(type: .custom)
        return btn
    }()
    
    
    var clickBtnBlock: ( (YXAdListModel) -> () )? //跳转响应
    
    private var model: YXAdListModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = QMUITheme().foregroundColor()
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 5
        self.layer.cornerRadius = 6
        
        
        imageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-5)
            make.top.left.equalToSuperview().offset(5)
            make.height.equalTo(58)
        }
        
        titleLab.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(5)
        }
        
        subTitleLab.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(titleLab.snp.bottom)
        }
        
        
        addSubview(clickBtn)
        clickBtn.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.clickBtn.rx.tap.subscribe(onNext: {[weak self] (_) in
            guard let `self` = self else { return }
            
            if let block = self.clickBtnBlock, let model = self.model {
                block(model)
            }
        }).disposed(by: self.rx.disposeBag)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func refreshUI(with itemWidth:CGFloat, model: YXAdListModel) {
        self.model = model
        
        let placeholderImg = UIImage.qmui_image(with: UIColor.qmui_color(withHexString: "#D8D8D8"), size: CGSize(width: itemWidth, height: 58), cornerRadius: 0)
        
        self.imageView.frame = CGRect(x: 5, y: 5, width: itemWidth, height: 58)
        
        if let picUrl = model.logoURLWhite, picUrl.isNotEmpty(), let picURL = URL(string: picUrl) {
            self.imageView.sd_setImage(with: picURL, placeholderImage: placeholderImg, options: []) { (image, error, cacheType, url) in
            }
        } else {
            self.imageView.image = placeholderImg
        }
        
        self.titleLab.text = model.titleMain
        self.subTitleLab.text = model.titleVice
    }
}
