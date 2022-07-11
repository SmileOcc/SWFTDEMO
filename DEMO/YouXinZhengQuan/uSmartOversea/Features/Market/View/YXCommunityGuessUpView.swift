//
//  YXSquareHeaderView.swift
//  YouXinZhengQuan
//
//  Created by lennon on 2022/3/7.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

import UIKit

//class SquareBannerView:UIView, StackViewSubViewProtocol {
//    lazy var bannerView:YXFCBannerCell = {
//        let view = YXFCBannerCell.init()
//        return view
//    }()
//
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        addSubview(bannerView)
//        bannerView.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(12)
//            $0.bottom.equalToSuperview().offset(-12)
//            $0.left.equalToSuperview().offset(12)
//            $0.right.equalToSuperview().offset(-12)
//        }
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}

//class SquareEntranceView:UIView, StackViewSubViewProtocol {
//
//    var heightDidChage: ((CGFloat) -> Void)?
//
//   private lazy var entranceView:YXModuleView = {
//        let view = YXModuleView(moduleType: .squ) { [weak self] height in
//            guard let `self` = self else { return }
//            self.heightDidChage?(height + 12)
//        }
//        view.backgroundColor = QMUITheme().foregroundColor()
//        view.layer.cornerRadius = 4
//        view.layer.masksToBounds = true
//        return view
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        let containView = UIView.init()
//        containView.backgroundColor = QMUITheme().foregroundColor()
//        addSubview(containView)
//        containView.addSubview(entranceView)
//
//        containView.snp.makeConstraints {
//            $0.left.right.bottom.equalToSuperview()
//            $0.top.equalToSuperview().offset(12)
//        }
//
//        entranceView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}

//class YXHotDiscussionView: UIView, StackViewSubViewProtocol {
//
//    @objc var showMoreCallBack: (()->())?
//
//    lazy var headerCell: YXSquareSectionCell = {
//        let view = YXSquareSectionCell.init()
////        view.clickCallBack = { [weak self] in
////            self?.showMoreCallBack?()
////        }
//        view.hLineView.isHidden = true
//        view.titleLabel.text = YXLanguageUtility.kLang(key: "hot_post")
//        view.subTitleLabel.text = ""
//        view.arrowImgaeView.isHidden = true
//        return view
//    }()
//
//    lazy var cell: YXSquareHotDscussionCell = {
//        let cell = YXSquareHotDscussionCell.init()
//        return cell
//    }()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        addSubview(headerCell)
//        addSubview(cell)
//        headerCell.snp.makeConstraints{
//            $0.top.equalToSuperview()
//            $0.left.right.equalToSuperview()
//            $0.height.equalTo(44)
//        }
//
//        cell.snp.makeConstraints{
//            $0.top.equalTo(headerCell.snp.bottom)
//            $0.left.right.equalToSuperview()
//            $0.height.equalTo(105)
//        }
//
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}


class YXCommunityGuessUpView: UIView,StackViewProtocol {

    @objc var heightDidChange: (() -> Void)?
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    @objc var showMoreCallBack: (()->())?
    
//    lazy var entranceView:SquareEntranceView = {
//        let view = SquareEntranceView.init()
//        view.heightDidChage = { (height) in
//            self.entranceView.contentHeight = height
//            self.entranceView.isHidden = false
//        }
//        view.isHidden = true
//        return view
//    }()
    
//    lazy var hotDiscussionView:YXHotDiscussionView = {
//        let view = YXHotDiscussionView.init()
////        view.showMoreCallBack = { [weak self] in
////            self?.showMoreCallBack?()
////        }
//        view.backgroundColor = QMUITheme().foregroundColor()
//        return view
//    }()
    
//    lazy var bannerView:SquareBannerView = {
//        let view = SquareBannerView.init()
//        view.isHidden = true
//        return view
//    }()
    
    lazy var guessUpOrDownView:SquareGuessUpOrDownView = {
        let view = SquareGuessUpOrDownView.init()
        view.refreshData = { [weak self] in
            guard let `self` = self else { return }
            self.loadGuessData()
        }
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//        stackView.addArrangedSubview(entranceView)
//        stackView.addArrangedSubview(bannerView)
        stackView.addArrangedSubview(guessUpOrDownView)

        configStackView()
        
//        bannerView.contentHeight = 111
        guessUpOrDownView.contentHeight = 50
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func loadBannerData() {
//        let bannerModel = YXBannerAdvertisementRequestModel.init()
//        bannerModel.show_page = 126
//        let request = YXRequest.init(request: bannerModel)
//        request.startWithBlock { response in
//            if response.code == YXResponseStatusCode.success, let data = response.data {
//                let model = YXBannerActivityModel.yy_model(withJSON: data)
//                self.bannerView.bannerView.model = model
//                if let list = model?.bannerList, list.count > 0 {
//                    self.bannerView.isHidden = false
//
//                }else {
//                    self.bannerView.isHidden = true
//                }
//            }else {
//                self.bannerView.isHidden = true
//
//            }
//        } failure: { baseRequest in
//            self.bannerView.isHidden = true
//        }
//    }
    
//    func loadDiscussionData() {
//        let  requestModel = YXSquareHotDiscussionRequestModel.init()
//        let  request = YXRequest.init(request: requestModel)
//
//        request.startWithBlock { response in
//            if response.code == YXResponseStatusCode.success, let data = response.data {
//                let model = YXHotDiscussionListModel.yy_model(withJSON: data)
//                self.hotDiscussionView.cell.list = model?.list
//            }
//        } failure: { baseRequest in
//
//        }
//    }
    
    func loadGuessData() {
        let requestModel = YXGuessUpAndDowListReqModel.init()
        requestModel.limit = 30
        let request = YXRequest.init(request: requestModel)
        request.startWithBlock {  responseModel in
            if responseModel.code == .success,let model = responseModel as? YXGuessUpAndDownListResModel {
                
                var stockCodes:[[String:Any]] = []
                if model.list.count > 0 {

                    if let saveModel = self.guessUpOrDownView.model {

                        for stockInfo in model.list {
                            let isContain  = saveModel.list.contains { $0.secuCode == stockInfo.secuCode }
                            if !isContain {
                                self.guessUpOrDownView.model  = model
                                break
                            }
                        }
                        
                    } else {
                        self.guessUpOrDownView.model  = model
                    }
                    for item in model.list {
                        var dict: [String:Any] = [:]
                        if let stockCode = item.secuCode, let market = item.market {
                            dict["market"] = market
                            dict["code"] = stockCode
                            stockCodes.append(dict)
                        }
                    }
                    
                    let guessInfos =  YXGuessStockInfosRequestModel.init()
                    guessInfos.stockCodes = stockCodes
                    let guessDataResquest = YXRequest.init(request: guessInfos)
                    guessDataResquest.startWithBlock { responseModel in
                        if responseModel.code == .success,let model = responseModel as? YXGuessUpOrDownInfoLists, let guessUpOrDownModel = self.guessUpOrDownView.model {
                            
                            for (i ,item) in model.list.enumerated() {
                                let model = guessUpOrDownModel.list[i]
                                model.upCount = item.upCount
                                model.guessChange = item.guessChange
                                model.downCount = item.downCount
                                model.transDate = item.transDate
                            }
                            self.guessUpOrDownView.model = guessUpOrDownModel
                        }
                    } failure: { request in
                        
                    }
                    self.isHidden = false
                    self.guessUpOrDownView.collectionView.isHidden = false
                    self.frame.size = CGSize.init(width: self.frame.size.width, height: 220);
                    self.heightDidChange?()

                } else {
//                    self.guessUpOrDownView.collectionView.isHidden = true
//                    self.frame.size = CGSize.init(width: self.frame.size.width, height: 50);
//                    self.heightDidChange?()

                    self.isHidden = true
                    self.guessUpOrDownView.collectionView.isHidden = true
                    self.frame.size = CGSize.init(width: self.frame.size.width, height: 0);
                    self.heightDidChange?()
                }
            } else {
                self.isHidden = true
                self.guessUpOrDownView.collectionView.isHidden = true
                self.frame.size = CGSize.init(width: self.frame.size.width, height: 0);
                self.heightDidChange?()

            }
        } failure: { request in
            self.guessUpOrDownView.collectionView.isHidden = true
            self.frame.size = CGSize.init(width: self.frame.size.width, height: 50);
            self.heightDidChange?()

        }
    }
    
    func loadData() {
      
//        loadDiscussionData()
//        loadBannerData()
        loadGuessData()
    }
    
}



