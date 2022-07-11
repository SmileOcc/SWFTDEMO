//
//  GoodsSummaryList.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/15.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON
import YYImage
import RxSwift

class GoodsSummaryList: UIView {
    
    let tapPub = PublishSubject<Void>()
    
    weak var titleLbl:UILabel!
    weak var goodsCount:UILabel!
    weak var goodsList:UICollectionView!
    
    private var disposeBag = DisposeBag()
    
    var goodsItems:[JSON]?{
        didSet{
            goodsList.reloadData()
        }
    }

    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        let titleLbl = UILabel()
        titleLbl.font = UIFont.boldSystemFont(ofSize: 14)
        titleLbl.textColor = OSSVThemesColors.col_000000(1)
        self.titleLbl = titleLbl
        addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.leading.top.equalTo(15)
        }
        let arrImg = UIImageView(image: UIImage(named: "address_arr"))
        addSubview(arrImg)
       
        arrImg.snp.makeConstraints { make in
            make.trailing.equalTo(-15)
            make.width.height.equalTo(12)
            make.centerY.equalTo(titleLbl.snp.centerY)
        }
        
        let goodsCount = UILabel()
        addSubview(goodsCount)
        self.goodsCount = goodsCount
        goodsCount.font = UIFont.systemFont(ofSize: 12)
        goodsCount.snp.makeConstraints { make in
            make.trailing.equalTo(arrImg.snp.leading).offset(-6)
            make.centerY.equalTo(titleLbl.snp.centerY)
        }
        let tapButton = UIButton()
        addSubview(tapButton)
        tapButton.snp.makeConstraints { make in
            make.trailing.equalTo(arrImg.snp.trailing)
            make.top.equalTo(10)
            make.bottom.equalTo(goodsCount.snp.bottom).offset(10)
            make.leading.equalTo(goodsCount.snp.leading)
        }
        tapButton.rx.tap.subscribe(onNext:{[weak self] in
            self?.tapPub.onNext(())
        }).disposed(by: disposeBag)
        
        let layout = HorizontalCollectionFlowLauout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 78, height: 78)
        let goodsList = UICollectionView(frame: .zero, collectionViewLayout: layout)
        addSubview(goodsList)
        goodsList.snp.makeConstraints { make in
            make.top.equalTo(52)
            make.leading.equalTo(15)
            make.trailing.equalTo(-15)
            make.height.equalTo(78)
            make.bottom.equalTo(0)
        }
        self.goodsList = goodsList
        goodsList.dataSource = self
        goodsList.delegate = self
        goodsList.register(GoodsImgViewCell.self, forCellWithReuseIdentifier: "GoodsImgViewCell")
    }
}

extension GoodsSummaryList:UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goodsItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GoodsImgViewCell", for: indexPath)
        if let cell = cell as? GoodsImgViewCell,
           let data = goodsItems?[indexPath.row,true]{
            cell.goodsImg.yy_setImage(with: URL(string: data["goods_thumb"].string ?? ""), placeholder: UIImage(named: "small_placeholder"))
            cell.countLbl.text = "x" + ( data["goods_number"].string ?? "")
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tapPub.onNext(())
    }
}

class GoodsImgViewCell:UICollectionViewCell{
    
    weak var goodsImg:YYAnimatedImageView!
    weak var countLbl:UILabel!
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    func setupViews(){
        let imageView = YYAnimatedImageView()
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        imageView.contentMode = .scaleAspectFit
        self.goodsImg = imageView
        
        let countLbl = UILabel()
        contentView.addSubview(countLbl)
        countLbl.font = UIFont.boldSystemFont(ofSize: 12)
        countLbl.backgroundColor = OSSVThemesColors.col_ffffff(0.7)
        self.countLbl = countLbl
        countLbl.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        countLbl.textAlignment = .center
    }
}
