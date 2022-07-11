//
//  YXHoldShareCommonView.swift
//  uSmartOversea
//
//  Created by Evan on 2022/1/12.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit
import YXKit

class YXHoldShareCommonView: UIView {

    var orderId: String?

    var shareType: HoldShareType = .hold

    var shareImages: [UIImage] = [] {
        didSet {
            pageControl.numberOfPages = shareImages.count
            collectionView.reloadData()
            currentIndex = 0
        }
    }

    private var currentIndex: Int = 0 {
        didSet {
            pageControl.currentPage = currentIndex

            if 0 <= currentIndex,
               currentIndex < shareImages.count {
                bottomView.shareImage = shareImages[currentIndex]
            }
        }
    }

    var contentViews: [UIView] = []

    var imageViewWidth: CGFloat = YXConstant.screenWidth * 0.85
    var imageViewHeight: CGFloat = 0

    func convertToImage() {
        var images: [UIImage] = []

        for contentView in contentViews {
            contentView.setNeedsDisplay()
            contentView.layoutIfNeeded()

            if let image = UIImage.qmui_image(with: contentView) {
                images.append(image)
            }
        }

        self.shareImages = images
    }

    //MARK: Show Or Hide
    var modalVC: QMUIModalPresentationViewController? = nil

    @objc func showShareView() {
        convertToImage()

        if !shareImages.isEmpty {
            let modalViewController = QMUIModalPresentationViewController();
            modalViewController.qmui_preferredStatusBarStyleBlock = { () -> UIStatusBarStyle in
                return .lightContent
            }
            //modalViewController.modal = YES;
            weak var weakView = self
            modalViewController.animationStyle = .slide
            modalViewController.contentViewMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            modalViewController.contentView = weakView;
            modalViewController.showWith(animated: true, completion: nil)
            self.modalVC = modalViewController
        }
        
        self.checkShareActivityExist()
    }

    @objc func hideShareView() {
        self.modalVC?.hideWith(animated: true, completion: nil)
    }

    @objc func showShareBottomView(){
        let modalViewController = QMUIModalPresentationViewController()
        modalViewController.qmui_preferredStatusBarStyleBlock = { () -> UIStatusBarStyle in
            return .lightContent
        }
        weak var weakView = self
        modalViewController.animationStyle = .fade
        modalViewController.contentViewMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        modalViewController.contentView = weakView;
        modalViewController.showWith(animated: true, completion: nil)
        self.modalVC = modalViewController
    }

    //MARK: Initializer
    @objc init(frame: CGRect, shareType: HoldShareType) {
        super.init(frame: frame)
        self.shareType = shareType
        initUI()
    }


    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let statusBarHeight = YXConstant.statusBarHeight()
        let pageControlMinHeight: CGFloat = 20
        let bottomShareViewHeight: CGFloat = self.bottomView.currentContentHeight()
        let collectionViewMaxHeight = YXConstant.screenHeight - statusBarHeight - bottomShareViewHeight - pageControlMinHeight * 2
        let imageRatio: CGFloat = 323.0/468.0 // 分享的图片宽高比
        var collectionViewItemWidth = self.width - UIEdgeInsetsGetHorizontalValue(collectionViewLayout.sectionInset)
        var collectionViewItemHeight = collectionViewItemWidth / imageRatio
        
        if collectionViewItemHeight > collectionViewMaxHeight { // 如果按比例计算的高度超过了最大高度，那么重新设置高度以及宽度
            collectionViewItemHeight = collectionViewMaxHeight
            collectionViewItemWidth = collectionViewItemHeight * imageRatio
        }

        collectionView.frame = CGRect(
            x: 0,
            y: statusBarHeight + (self.bottomView.top - statusBarHeight - collectionViewItemHeight) / 2,
            width: self.width,
            height: collectionViewItemHeight
        )

        collectionViewLayout.itemSize = CGSize(width: collectionViewItemWidth, height: collectionViewItemHeight)
        collectionViewLayout.invalidateLayout()

        pageControl.sizeToFit()
    }

    func initUI() {
        let bottomShareViewHeight: CGFloat = self.bottomView.currentContentHeight()

        backgroundColor = UIColor.qmui_color(withHexString: "#262A55")

        addSubview(collectionView)
        addSubview(pageControl)
        addSubview(bottomView)

        pageControl.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom)
            make.left.right.equalToSuperview().inset(30)
            make.bottom.equalTo(self.bottomView.snp.top)
        }

        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(bottomShareViewHeight)
            make.bottom.equalToSuperview()
        }
    }

    private lazy var collectionViewLayout: QMUICollectionViewPagingLayout = {
        let layout = QMUICollectionViewPagingLayout(style: .default)!
        layout.scrollDirection = .horizontal
        layout.allowsMultipleItemScroll = false
        layout.sectionInset = UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 26)
        layout.minimumLineSpacing = 16
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        view.showsHorizontalScrollIndicator = false
        view.backgroundColor = .clear
        view.delegate = self
        view.dataSource = self
        view.register(YXHoldShareViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXHoldShareViewCell.self))
        return view
    }()

    private lazy var pageControl: TAPageControl = {
        let pageControl = TAPageControl()
        pageControl.spacingBetweenDots = 0
        pageControl.isUserInteractionEnabled = false
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        let dotSize = CGSize(width: 8, height: 2)
        pageControl.dotSize = dotSize
        var selectedColor = UIColor.qmui_color(withHexString: "#FFFFFF")
        var normalColor = UIColor.qmui_color(withHexString: "#FFFFFF")?.withAlphaComponent(0.3)
        pageControl.currentDotImage = UIImage.qmui_image(with: selectedColor, size: dotSize, cornerRadius: 0)
        pageControl.dotImage = UIImage.qmui_image(with: normalColor, size: dotSize, cornerRadius: 0)
        return pageControl
    }()

    lazy var bottomView: YXShareBottomAlertView = {
        let view = YXShareBottomAlertView()
        view.isDefaultShowMessage  = true
        var thirdPlatforms:[YXSharePlatform] = [.facebook,.facebookMessenger,.whatsApp,.twitter,.instagram,.uSmartSocial,.telegram,.line]
        var toolsPlatforms:[YXSharePlatform] = [.save,.more]
        
        view.showMysteryBoxBadge = false
        view.configure(shareType: .image, toolTypes: toolsPlatforms, thirdTypes: thirdPlatforms, clickCallBlock: nil, resultCallBlock: { [weak self] (platform, result) in

            guard let `self` = self else { return }
            
            //记录完成一次持仓分享 记录到首页时弹出去评分弹框
            YXGiveScoreAlertManager.sharedChangeScoreModel()
            if self.shareType == .order {
                //盲盒 FB默认都可以，其他的根据数据返回成功
                if platform == .facebook || result {
                    self.checkLottery()
                }
            }
            
        }, cancelBlock: { [weak self] in
            guard let `self` = self else { return }
            self.hideShareView()
        })
        
        view.shareToUsmartCommunityCallback = { [weak self] in
            guard let `self` = self else { return }
            //记录完成一次持仓分享 记录到首页时弹出去评分弹框
            YXGiveScoreAlertManager.sharedChangeScoreModel()
            self.shareToUsmartCommunity(self.bottomView.shareImage)
        }
        
        return view
    }()
    
    /// 检查是否可以抽奖
    @objc func checkLottery() {
        guard let orderId = self.orderId else { return }

        let requestModel = YXShareBindBoxRequestModel()
        requestModel.orderId = orderId

        let request = YXRequest(request: requestModel)
        request.startWithBlock { [weak self] responseModel in
            if responseModel.code == .success,
               let model = responseModel as? YXShareBindBoxResponseModel,
               model.result {
                self?.showLottery()
            }
        } failure: { _ in

        }
    }

    /// 显示抽奖
    @objc func showLottery() {
        if let modalVC = self.modalVC, modalVC.isVisible {
            self.modalVC?.hideWith(animated: false, completion: { finished in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let shareLotteryViewController = YXShareLotteryViewController()
                    shareLotteryViewController.orderId = self.orderId
                    shareLotteryViewController.modalPresentationStyle = .overFullScreen
                    UIApplication.shared.keyWindow?.rootViewController?.present(shareLotteryViewController, animated: false, completion: nil)
                }
            })
        } else {
            let shareLotteryViewController = YXShareLotteryViewController()
            shareLotteryViewController.orderId = self.orderId
            shareLotteryViewController.modalPresentationStyle = .overFullScreen
            UIApplication.shared.keyWindow?.rootViewController?.present(shareLotteryViewController, animated: false, completion: nil)
        }
    }
    
    @objc func checkShareActivityExist() {
        guard let orderId = self.orderId else { return }

        let requestModel = YXCheckUserShareActivityRequestModel()
        requestModel.orderId = orderId
        let request = YXRequest.init(request: requestModel)
        request.startWithBlock(success: { [weak self]  (response) in
            guard let strongSelf = self else { return }

            if response.code == .success,
               let model = response as? YXCheckUserShareActivityRespoonseModel,
               model.result {
                strongSelf.bottomView.showMysteryBoxBadge = true
                strongSelf.bottomView.refreshUI()
            }
           
        }, failure: { (request) in
            
        })

        
    }
}

extension YXHoldShareCommonView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shareImages.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: NSStringFromClass(YXHoldShareViewCell.self),
            for: indexPath
        ) as! YXHoldShareViewCell
        cell.imageView.image = shareImages[indexPath.row]
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = CGPoint(x: scrollView.contentOffset.x + scrollView.width / 2.0, y: scrollView.height / 2.0)
        if let indexPath = self.collectionView.indexPathForItem(at: point),
           currentIndex != indexPath.row {
            currentIndex = indexPath.row
        }
    }

}

extension YXHoldShareCommonView {

    func shareToUsmartCommunity(_ image: UIImage?) {
        if let modalVC = self.modalVC, modalVC.isVisible {
            self.modalVC?.hideWith(animated: false, completion: { finished in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !YXUserManager.isLogin() {
                        YXToolUtility.handleBusinessWithLogin {

                        }
                        return
                    }

                    if let root = UIApplication.shared.delegate as? YXAppDelegate {
                        let navigator = root.navigator
                        let viewModel = YXReportViewModel.init(services: navigator, params: nil)
                        if let image = image {
                            viewModel.images = [image]
                        }
                        navigator.push(viewModel, animated: true)
                    }
                }
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if !YXUserManager.isLogin() {
                    YXToolUtility.handleBusinessWithLogin {

                    }
                    return
                }

                if let root = UIApplication.shared.delegate as? YXAppDelegate {
                    let navigator = root.navigator
                    let viewModel = YXReportViewModel.init(services: navigator, params: nil)
                    if let image = image {
                        viewModel.images = [image]
                    }
                    navigator.push(viewModel, animated: true)
                }
            }
        }
       
    }
}
