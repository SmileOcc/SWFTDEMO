//
//  YXLearningChatRoomCell.swift
//  uSmartOversea
//
//  Created by ellison on 2018/12/25.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SDCycleScrollView
import FLAnimatedImage

class YXLearningChatRoomCell: UICollectionViewCell {
    
    typealias ClosureIndexPath = (_ indexPath: IndexPath) -> Void
    
    var selectedIndex : Int = 0
    
    var isColorChanged = false // 切换了红涨绿跌
    
    var isFistComeData : Bool = true
    
    var currentPage : Int = 0
    
    var disposeBag: DisposeBag? = DisposeBag()
    
    var onClickOpenAccount:(()->Void)?
    
    var dataSource: [YXRecommendChatResModel] = [YXRecommendChatResModel]() {
        didSet {
//            if dataSource.count < 4 {
//                self.collectionView.isScrollEnabled = false
//                pageControl.numberOfPages = 1
//            } else {
//                self.collectionView.isScrollEnabled = true
//                if dataSource.count % 3 == 0 {
//                    pageControl.numberOfPages = dataSource.count/3
//                } else {
//                    pageControl.numberOfPages = dataSource.count/3 + 1
//                }
//            }
            collectionView.reloadData()
        }
    }
        
    @objc var onClickIndexPath: ClosureIndexPath?
    
    var onClickTimeLineView: ((_ selectedIndex: Int) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = QMUITheme().foregroundColor()
        initializeViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }
        
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .zero
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceHorizontal = true
        collectionView.alwaysBounceVertical = false
        collectionView.register(YXLearningChatRoomSubCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXLearningChatRoomSubCell.self))
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        return collectionView
    }()
    
    fileprivate lazy var pageControl: TAPageControl = {
        let pageControl = TAPageControl()
        pageControl.hidesForSinglePage = true
        
        var selectedColor: UIColor?
        var normalColor: UIColor?
        selectedColor = QMUITheme().mainThemeColor()
        normalColor = QMUITheme().textColorLevel4()
        pageControl.dotImage = UIImage(color: normalColor!, size: CGSize(width: 8, height: 2))
        pageControl.currentDotImage = UIImage(color: selectedColor!, size: CGSize(width: 8, height: 2))
        pageControl.isUserInteractionEnabled = false
        pageControl.currentPage = 0
        pageControl.spacingBetweenDots = 0
        
        return pageControl
    }()
    
    fileprivate func initializeViews() {
        contentView.addSubview(collectionView)
//        contentView.addSubview(pageControl)
        collectionView.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(5)
        }
        
//        pageControl.snp.makeConstraints { (make) in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(collectionView.snp.bottom).offset(8)
//        }
    }

}

//MARK: - UICollectionViewDelegate
extension YXLearningChatRoomCell: UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if indexPath.item == selectedIndex {
//            return
//        }
//        selectedIndex = indexPath.item
        if let closure = onClickIndexPath {
            closure(indexPath)
        }
        
        YXToolUtility.handleBusinessWithLogin {
            let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: YXH5Urls.chatRoom(chatRoomId: self.dataSource[indexPath.row].chatGroupId ?? "")]
            NavigatorServices.shareInstance.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
        }
//        collectionView.reloadData()
    }

}

//MARK: - UICollectionViewDataSource
extension YXLearningChatRoomCell: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXLearningChatRoomSubCell.self), for: indexPath) as! YXLearningChatRoomSubCell
        if let model = dataSource[safe:indexPath.row] {
            cell.kolNameLabel.text = model.chatGroupName
            if let url = URL(string: model.chatGroupUrl ?? "") {
                cell.kolImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "user_default_photo"))
            } else {
                cell.kolImageView.image = UIImage(named: "user_default_photo")
            }
            cell.tipsLable.isHidden = !(model.userStatus == 0 || model.userStatus == 4 && !model.isJoined)
            cell.tipsLable.text = model.userStatus == 4 ? YXLanguageUtility.kLang(key: "nbb_title_free") :YXLanguageUtility.kLang(key: "nbb_title_free_trial")
            cell.badgeView.isHidden = !model.isSpot
            if model.userStatus == 3 { //vip
                cell.tipsLable.isHidden = false
                cell.tipsLable.text = "vip"
            }
        }
       return cell
        
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension YXLearningChatRoomCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: 84 , height: 115)

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

extension YXLearningChatRoomCell: UIScrollViewDelegate {
    
//    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        print("scrollViewDidEndScrollingAnimation")
//        self.scrollViewEndChangeUI(scrollView)
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print("scrollViewDidEndDragging")
//        if !decelerate {
//            self.scrollViewEndChangeUI(scrollView)
//        }
//    }

    //scrollView 已结束 减速
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//
//        let index = self.collectionView.contentOffset.x / self.collectionView.width
//
//        self.pageControl.currentPage = Int(ceil(index))
//
//    }
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//
//    }
}


class YXLearningChatRoomSubCell: UICollectionViewCell {
    
    //kol头像
    lazy var kolImageView: UIImageView = {
        let imageView = UIImageView()
//        imageView.layer.cornerRadius = 25
//        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    //kol名称
    lazy var kolNameLabel: QMUILabel = {
        let label = QMUILabel()
        label.textColor = QMUITheme().textColorLevel1()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var badgeView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "F95151")!
        view.layer.cornerRadius = 6
        return view
    }()
    
    //kol试用提示
    lazy var tipsLable: QMUILabel = {
        let label = QMUILabel()
        label.textColor = UIColor(hexString: "F9A800")
        label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.text = YXLanguageUtility.kLang(key: "nbb_title_free_trial")
        return label
    }()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        backgroundColor = QMUITheme().foregroundColor()
//        layer.cornerRadius = 12
//        layer.shadowColor = UIColor.qmui_color(withHexString: "#000000")?.withAlphaComponent(0.05).cgColor
//        layer.shadowOffset = CGSize(width: 0, height: 4)
//        layer.shadowOpacity = 1.0
//        layer.shadowRadius = 12.0
        
        contentView.addSubview(kolImageView)
        contentView.addSubview(kolNameLabel)
        contentView.addSubview(tipsLable)
        contentView.addSubview(badgeView)
        
        kolImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.size.equalTo(60)
            make.centerX.equalToSuperview()
        }
        
        badgeView.snp.makeConstraints { make in
            make.top.equalTo(kolImageView.snp.top)
            make.right.equalTo(kolImageView.snp.right)
            make.size.equalTo(12)
        }
        
        kolNameLabel.snp.makeConstraints { make in
            make.top.equalTo(kolImageView.snp.bottom).offset(8)
            make.left.equalTo(kolImageView.snp.left)
            make.right.equalTo(kolImageView.snp.right)
        }
        
        tipsLable.snp.makeConstraints { make in
            make.top.equalTo(kolNameLabel.snp.bottom).offset(2)
            make.left.equalTo(kolImageView.snp.left)
            make.right.equalTo(kolImageView.snp.right)
        }
        badgeView.isHidden = true
        tipsLable.isHidden = true
        
        self.layoutIfNeeded()
        kolImageView.layer.cornerRadius = kolImageView.frame.size.width / 2;
        kolImageView.layer.masksToBounds = true
    }
    
}
