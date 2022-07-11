//
//  SummaryGroupView.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/13.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON
import SnapKit

class SummaryGroupView: UIView {
    
    private let disposeBag = DisposeBag()
    
    lazy var checkoutDataPub:PublishSubject<JSON?> = {
        let pub = PublishSubject<JSON?>()
        pub.subscribe(onNext:{[weak self] data in
            self?.fillSummaryData(data: data)
        }).disposed(by: disposeBag)
        return pub
    }()
    
    weak var summaryList:GoodsSummaryList!
    weak var couponInputSelect:CouponInputSelect!
    weak var priceList:PriceList!

    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        let stackView = UIStackView()
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(0)
        }
        backgroundColor = OSSVThemesColors.col_ffffff(1)
        //MARK: 商品列表图
        let summaryList = GoodsSummaryList(frame: .zero)
        self.summaryList = summaryList
        stackView.addArrangedSubview(summaryList)
        summaryList.tapPub.subscribe(onNext:{
            //展示商品列表
            self.displayPopGoodsList()
        }).disposed(by: disposeBag)
        
        
        //MARK: 优惠券
        let couponInputSelect = CouponInputSelect(frame: .zero)
        stackView.addArrangedSubview(couponInputSelect)
        self.couponInputSelect = couponInputSelect
        
        //MARK: 价格列表
        let priceList = PriceList(frame: .zero)
        stackView.addArrangedSubview(priceList)
        self.priceList = priceList
    }
    
    func fillSummaryData(data:JSON?){
        let summaryTitle = data?["result"]["war_order_list"].array?.first?["goods_list"].array?.first?["warehouse_name"].string
        var goodsListArr:[JSON] = []
        var googsCount = 0
        data?["result"]["war_order_list"].array?.forEach({ warOrderList in
            warOrderList["goods_list"].array?.forEach({ goods in
                goodsListArr.append(goods)
                googsCount += Int(goods["goods_number"].string ?? "") ?? 0
            })
        })
        summaryList.titleLbl.text = summaryTitle
        summaryList.goodsCount.text = "\(googsCount) \(STLLocalizedString_("checkOutItems")!)"
        summaryList.goodsItems = goodsListArr
        
        couponInputSelect.data = data?["result"]
        
        priceList.data = data?["result"]
        
    }
    
    func displayPopGoodsList(){
        let popContent = PopGoodsListView(frame: .zero)
        popContent.goodsItems = summaryList.goodsItems
        let pop = zhPopupController(view: popContent, size: CGSize(width: CGFloat.screenWidth, height: CGFloat.screenHeight * 0.8))
        popContent.popView = pop
        pop.layoutType = .bottom
        pop.presentationStyle = .fromBottom
        
        pop.show()
    }

}
