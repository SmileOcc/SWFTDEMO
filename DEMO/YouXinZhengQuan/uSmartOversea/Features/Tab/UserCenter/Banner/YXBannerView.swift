//
//  YXBannerView.swift
//  uSmartOversea
//
//  Created by youxin on 2019/7/1.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator

enum YXBannerScaleType {
    case four_one
    case five_two
    case custom
}

class YXBannerView: YXStockDetailBaseView {
    
    let bannerService = YXNewsService()
    var bannerModel: YXUserBanner?
    
    typealias ResultBlock = () -> Void
    var requestSuccessBlock: ResultBlock?
    var requestFailedBlock: ResultBlock?
    

    var imageType: YXBannerScaleType
    var newsType: YXNewsType = .newStock
    
    convenience init(imageType: YXBannerScaleType, scrollInterval: CGFloat = 10.0) {
        self.init(frame: CGRect.zero, imageType: imageType, scrollInterval: scrollInterval)
    }
    
    init(frame: CGRect, imageType: YXBannerScaleType, scrollInterval: CGFloat = 10.0) {
        self.imageType = imageType
        super.init(frame: frame)
        
        self.addSubview(bannerImageView)
        bannerImageView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }

        if imageType != .custom {
            bannerImageView.layer.cornerRadius = 4
            bannerImageView.layer.masksToBounds = true
        }
        bannerImageView.autoScrollTimeInterval = scrollInterval
    }

    required init?(coder aDecoder: NSCoder) {
   
        fatalError("init(coder:) has not been implemented")
    }
    
    
    lazy var bannerImageView: YXImageBannerView = {
        var imageName: String = "placeholder_4bi1"
        switch imageType {
        case .four_one:
            imageName = "placeholder_4bi1"
        case .five_two:
            imageName = "placeholder_5bi2"
        case .custom:
            imageName = "placeholder_4bi1"
        }
        let view = YXImageBannerView(frame: CGRect.zero, delegate: self, placeholderImage: UIImage(named: imageName))!
        view.isUserInteractionEnabled = true
        return view
    }()

}

extension YXBannerView {
    //广告页
    func requestBannerInfo(_ newsType: YXNewsType) {
        self.newsType = newsType
        bannerService.request(.userBanner(id: newsType), response: { [weak self](response) in
            
            guard let strongSelf = self else { return }
            switch response {
            case .success(let result, let code):

                if let code = code, code == .success, let model = result.data, model.dataList?.count ?? 0 > 0 {

                    strongSelf.bannerModel = model
                    var arr = [String]()
                    for news in model.dataList ?? [] {
                        arr.append(news.pictureURL ?? "")
                    }
                    strongSelf.bannerImageView.imageURLStringsGroup = arr
                    strongSelf.requestSuccessBlock?()
                } else {
                    strongSelf.bannerImageView.imageURLStringsGroup = []
                    strongSelf.requestFailedBlock?()
                }
            case .failed(let error):
                log(.error, tag: kNetwork, content: "\(error)")
                strongSelf.bannerImageView.imageURLStringsGroup = []
                strongSelf.requestFailedBlock?()
            }
            
        } as YXResultResponse<YXUserBanner>).disposed(by: rx.disposeBag)
        
    }
}

extension YXBannerView: YXCycleScrollViewDelegate {
    func cycleScrollView(_ cycleScrollView: YXCycleScrollView!, didSelectItemAt index: Int) {

        if let bannerModel = self.bannerModel, index < bannerModel.dataList?.count ?? 0, let root = UIApplication.shared.delegate as? YXAppDelegate {
            let navigator = root.navigator
            if !(bannerModel.dataList?[index].jumpURL?.isEmpty ?? true) { //bannerModel.bannerList[index].jumpURL?.count ?? 0 > 0
                YXBannerManager.goto(withBanner: bannerModel.dataList![index], navigator: navigator)
            }
            let pageString = propViewPageString()
            if pageString.count > 0 {
            }
        }
    }
    
    func propViewPageString() -> String {
        var pageString = ""
        switch self.newsType {
        case .newStockDetail:
            pageString = "new_stock_detail"
            case .newStockApply:
            pageString = "new_stock_subscription"
        case .stockStrategy, .stockStrategy2:
            pageString = "smart_stock"
        case .search:
            pageString = "search"
        case .course:
            pageString = "资讯-课程"
        case .stockDetail:
            pageString = "个股详情"
        default:
            break
        }
        return pageString
    }
}
