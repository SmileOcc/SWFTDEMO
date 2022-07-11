//
//  PopGoodsListView.swift
//  Adorawe
//
//  Created by fan wang on 2021/12/15.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import SwiftyJSON

class PopGoodsListView: UIView {
    
    var goodsItems:[JSON]?
    
    weak var popView:zhPopupController?
    
    private weak var goodsList:UICollectionView!
    
    let disposeBag = DisposeBag()

    override init(frame: CGRect){
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews(){
        backgroundColor = .white
        let titleLbl = UILabel()
        addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.top.equalTo(15)
            make.centerX.equalTo(self.snp.centerX)
        }
        titleLbl.font = UIFont.boldSystemFont(ofSize: 16)
        titleLbl.text = STLLocalizedString_("productList")
        
        let closeIcon = UIButton()
        closeIcon.setImage(UIImage(named: "close_16"), for: .normal)
        addSubview(closeIcon)

        closeIcon.snp.makeConstraints { make in
            make.trailing.equalTo(-6)
            make.width.height.equalTo(30)
            make.centerY.equalTo(titleLbl.snp.centerY)
        }
        closeIcon.rx.tap.subscribe(onNext:{[weak self] in
            self?.popView?.dismiss()
        }).disposed(by: disposeBag)
        
        let line = UIView()
        addSubview(line)
        line.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.height.equalTo(1)
            make.top.equalTo(48)
        }
        line.backgroundColor = OSSVThemesColors.col_E1E1E1()
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: CGFloat.screenWidth, height: 72 + 17)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(0)
            make.top.equalTo(line.snp.bottom).offset(4)
            make.bottom.equalTo(self.snp.bottomMargin)
        }
        collectionView.register(WideGoodsCell.self, forCellWithReuseIdentifier: "WideGoodsCell")
        collectionView.dataSource = self
        self.goodsList = collectionView
    }

}

extension PopGoodsListView:UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goodsItems?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WideGoodsCell", for: indexPath)
        if let cell = cell as? WideGoodsCell,
           let data = goodsItems?[indexPath.row,true]{
            cell.goodsImg.yy_setImage(with: URL(string: data["goods_thumb"].string ?? ""), placeholder: UIImage(named: "small_placeholder"))
            cell.countLbl.text = "x" + ( data["goods_number"].string ?? "")
            cell.goodsTitleLbl.text = data["goods_title"].string
            cell.goodsAttrLbl.text = data["goods_attr"].string
            cell.priceLbl.text = data["shop_price_converted"].string
        }
        return cell
    }


}

class WideGoodsCell:UICollectionViewCell{
    weak var goodsImg:YYAnimatedImageView!
    weak var countLbl:UILabel!
    weak var goodsTitleLbl:UILabel!
    weak var goodsAttrLbl:UILabel!
    weak var priceLbl:UILabel!
    
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
            make.leading.equalTo(14)
            make.centerY.equalTo(contentView.snp.centerY)
            make.width.height.equalTo(72)
        }
        imageView.contentMode = .scaleAspectFit
        self.goodsImg = imageView
        
        let goodsTitleLbl = UILabel()
        contentView.addSubview(goodsTitleLbl)
        goodsTitleLbl.font = UIFont.systemFont(ofSize: 12)
        goodsTitleLbl.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(14)
            make.trailing.equalTo(-30)
            make.top.equalTo(imageView.snp.top)
        }
        self.goodsTitleLbl = goodsTitleLbl
        
        let goodsAttrLbl = UILabel()
        contentView.addSubview(goodsAttrLbl)
        goodsAttrLbl.font = UIFont.boldSystemFont(ofSize: 12)
        goodsAttrLbl.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(14)
            make.top.equalTo(goodsTitleLbl.snp.bottom).offset(4)
        }
        self.goodsAttrLbl = goodsAttrLbl
        
        let priceLbl = UILabel()
        contentView.addSubview(priceLbl)
        priceLbl.font = UIFont.boldSystemFont(ofSize: 14)
        priceLbl.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(14)
            make.bottom.equalTo(imageView.snp.bottom)
        }
        self.priceLbl = priceLbl
        
        let countLbl = UILabel()
        contentView.addSubview(countLbl)
        countLbl.font = UIFont.boldSystemFont(ofSize: 14)
        self.countLbl = countLbl
        countLbl.snp.makeConstraints { make in
            make.trailing.equalTo(-14)
            make.bottom.equalTo(imageView.snp.bottom)
        }
        
        let underLine = UIView()
        underLine.backgroundColor = OSSVThemesColors.col_E1E1E1()
        contentView.addSubview(underLine)
        underLine.snp.makeConstraints { make in
            make.bottom.equalTo(0)
            make.leading.equalTo(14)
            make.trailing.equalTo(-14)
            make.height.equalTo(0.5)
        }
    }
}
