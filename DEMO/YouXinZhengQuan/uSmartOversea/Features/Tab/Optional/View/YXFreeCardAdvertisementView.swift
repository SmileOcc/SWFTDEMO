//
//  YXFreeCardAdvertisementView.swift
//  uSmartOversea
//
//  Created by usmart on 2022/5/21.
//  Copyright © 2022 RenRenDai. All rights reserved.
//  免费卡券广告视图 中台配置卡券 在首页广告展示

import UIKit
let kaquanBannerHeight =  ((((YXConstant.screenWidth - 8*3)/2)*0.376) + 16.0 + 40.0)

class YXFreeCardAdvertisementView: UIView,StackViewSubViewProtocol {
    
    @objc var refreshData: (()->())?
    var clickCallBack: ((Bool)->())?
    
    var model: YXCouponBannerResModel?{
        
        didSet {
            guard let _ = self.model else {
                return
            }
            self.headView.titleLabel.text = model?.text
            self.collectionView.reloadData()
        }
            
    }
    
    lazy var headView: YXFreeCardAdvertisementHeadView = {
        let view = YXFreeCardAdvertisementHeadView.init()
        view.clickCallBack = { [weak self] (isSelected) in
            if isSelected {
                self?.collectionView.isHidden = true
            } else {
                self?.collectionView.isHidden = false
            }
            self?.clickCallBack?(isSelected)
        }
        view.titleLabel.text = "--"
        view.backgroundColor = QMUITheme().foregroundColor()
        return view
    }()
    
    private lazy var layout: QMUICollectionViewPagingLayout = {
        let layout = QMUICollectionViewPagingLayout(style: .default)!
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        return layout
    }()

    
    lazy var containScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    /*
     属性delaysContentTouches设置UIScrollView在得到触摸事件后是否延迟150ms后再调用方法touchesShouldBegin:withEvent:inContentView:;
     属性canCancelContentTouches设置是否能从子控件把滑动事件重新返回给父控件UIScrollView，如果为NO将不调用方法touchesShouldCancelInContentView:;
     default 都是 YES

     方法touchesShouldBegin:withEvent:inContentView:作用为是否把事件传递到子控件。

     方法touchesShouldCancelInContentView:作用为是否允许从子控件中把触摸滑动事件返还给父控件UIScrollView。
     ————————————————
     */
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = QMUITheme().foregroundColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = true

        collectionView.alwaysBounceVertical = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(YXFreeCardAdvertisementCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXFreeCardAdvertisementCell.self))
//        collectionView.canCancelContentTouches = false
        return collectionView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let containView = UIView.init()
        containView.backgroundColor = QMUITheme().foregroundColor()
        addSubview(containView)
        containView.addSubview(headView)
        containView.addSubview(containScrollView)
        containScrollView.contentSize = CGSize(width: YXConstant.screenWidth, height: kaquanBannerHeight - 40)
        containScrollView.addSubview(collectionView)
        
        containScrollView.snp.makeConstraints {
            $0.top.equalTo(headView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(kaquanBannerHeight - 40) //ui规定间距8，然后右侧还要留出8的第三张卡券
        }
        
        containView.snp.makeConstraints{
            $0.top.equalToSuperview().offset(0)
            $0.left.right.bottom.equalToSuperview()
        }
        
        headView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        collectionView.snp.makeConstraints{
            $0.top.equalTo(headView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(kaquanBannerHeight - 40) //ui规定间距8，然后右侧还要留出8的第三张卡券
            $0.width.equalTo(YXConstant.screenWidth)
        }
        
//        _ = NotificationCenter.default.rx
//            .notification(NSNotification.Name.init(YXUserManager.notiSkinChange))
//            .takeUntil(self.rx.deallocated)
//            .subscribe(onNext: {[weak self] _ in
//                guard let strongSelf = self else { return }
//                self?.collectionView.reloadData()
//            })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension YXFreeCardAdvertisementView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        model?.list.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let guessIndexCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NSStringFromClass(YXFreeCardAdvertisementCell.self),
            for: indexPath
        ) as! YXFreeCardAdvertisementCell
        guessIndexCell.model = model?.list[indexPath.row]
//        guessIndexCell.model = YXCouponBannerListModel()
        return guessIndexCell
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = model?.list[indexPath.row]

        trackViewClickEvent(customPageName: "Watchlists", name: "coupon_item", other: ["couponbanner_id":String(model?.couponbanner_id ?? 0),
"imgurl":item?.imgurl ?? "",
"customer_status":String(model?.customer_status ?? 0),
"coupon_banner":String(model?.coupon_banner ?? "coupon_banner")])

        YXWebViewModel.pushToWebVC(YXH5Urls.YX_AWARD_CENTER_URL())

    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: ((YXConstant.screenWidth-19)/2), height: kaquanBannerHeight - 40)
    }
    
    func goToStockDetail(market: String?, symbol: String?) {
        if let mkt = market, let code = symbol {
            let input = YXStockInputModel()
            input.market = mkt
            input.symbol = code
            input.name = ""
            if let root = UIApplication.shared.delegate as? YXAppDelegate {
                let navigator = root.navigator
                navigator.pushPath(.stockDetail, context: ["dataSource": [input], "selectIndex": 0], animated: true)
            }
        }
    }
}



class YXFreeCardAdvertisementHeadView: UIView {
    
    var clickCallBack: ((Bool)->())?
    
    lazy var preadOutBtn:  QMUIButton = {
        let button = QMUIButton()
        button.titleLabel?.font = .mediumFont12()
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .normal)
        button.setTitleColor(QMUITheme().mainThemeColor(), for: .selected)
//        button.setTitle(YXLanguageUtility.kLang(key: "beerich_comment_btn_less"), for: .normal)
//        button.setTitle(YXLanguageUtility.kLang(key: "beerich_comment_btn_more"), for: .selected)
        button.setImage(UIImage(named: "banner_close_less"), for: .normal)
        button.setImage(UIImage(named: "banner_close_more"), for: .selected)

        button.contentEdgeInsets = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        button.isSelected = false
        
        return button
    }()
    
    let titleLabel = UILabel.init(text: "", textColor: QMUITheme().textColorLevel1(), textFont: UIFont.systemFont(ofSize: 12, weight: .medium))!
    
//    let subTitleLabel = UILabel.init(text: "", textColor: QMUITheme().textColorLevel2(), textFont: UIFont.systemFont(ofSize: 12))!
    let arrowImgaeView = UIImageView.init(image: UIImage(named: "guessup_right_arrow"))

    let headImgaeView = UIImageView.init(image: UIImage(named: "banner_head_img"))
 
    let clickControl = UIControl.init()
    
    let hLineView  = UIView.init()
    
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
        self.backgroundColor = QMUITheme().foregroundColor()
        self.addSubview(headImgaeView)
        self.addSubview(titleLabel)
        self.addSubview(preadOutBtn)
        self.addSubview(clickControl)
//        self.addSubview(hLineView)
        
        headImgaeView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(headImgaeView.snp.right).offset(4)
        }
        
        preadOutBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
        }
        
        clickControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//        hLineView.snp.makeConstraints { make in
//            make.left.right.bottom.equalToSuperview()
//            make.height.equalTo(1)
//        }
    }
    
    @objc func click(_ sender: UIControl) {
        self.preadOutBtn.isSelected = !self.preadOutBtn.isSelected
        clickCallBack?(self.preadOutBtn.isSelected)
    }
}


class YXFreeCardAdvertisementCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
//        imageView.layer.cornerRadius = 4
//        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    
    var model: YXCouponBannerListModel? {
        didSet {
            self.imageView.sd_setImage(with: URL(string: model?.imgurl ?? ""), placeholderImage: UIImage.init(named: "card_banner"))
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = QMUITheme().foregroundColor()
//        layer.cornerRadius = 4
//        layer.masksToBounds = true
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func initializeViews() {
        contentView.backgroundColor = QMUITheme().foregroundColor()
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { (make) in
//            make.bottom.equalToSuperview().offset(-8)
//            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(0.376);// 高/宽 == 0.376
        }
        imageView.layoutIfNeeded()
    }
}
