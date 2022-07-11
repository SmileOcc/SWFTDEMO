//
//  OSSVTimeRangeSelectView.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/13.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift

class OSSVTimeRangeSelectView: UICollectionReusableView {
    
    
        
    var datas:[TimeRangeModel]?{
        didSet{
            collectionView?.reloadData()
            if let datas = datas,
               datas.count > 0{
                UIView.performWithoutAnimation {
                    collectionView?.scrollToItem(at: IndexPath(item: self.currentIndex, section: 0), at: .centeredHorizontally, animated: false)
                }
            }
        }
    }
    
    let indexSelectPub = PublishSubject<Int>()
    
    var currentIndex:Int = 0
    
    let disposeBag = DisposeBag()
    
    weak var collectionView:UICollectionView?

    override init(frame: CGRect) {
        super.init(frame: frame)
//        self.backgroundColor = OSSVThemesColors.col_F5F5F5()
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupSubViews() {
        let layout = HorizontalCollectionFlowLauout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 4
        let collect = UICollectionView(frame: .zero, collectionViewLayout: layout)
        addSubview(collect)
        collect.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
        }
        
        collect.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        
        collect.register(TimeRangeCell.self, forCellWithReuseIdentifier: String.timeRangeCellReuseID)
        self.collectionView = collect
        collect.delegate = self
        collect.dataSource = self
        collect.showsHorizontalScrollIndicator = false
        collect.backgroundColor = UIColor.clear
    }
}

extension OSSVTimeRangeSelectView:UICollectionViewDelegateFlowLayout,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        datas?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String.timeRangeCellReuseID, for: indexPath)
        if let cell = cell as? TimeRangeCell,
           let item = datas?[indexPath.item]{
            cell.goodsTotalLbl?.text = String(item.total ?? 0)
            cell.nameLbl?.text = item.name
            cell.isOn = currentIndex == indexPath.item
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tempLbl = UILabel()
        tempLbl.font = UIFont.boldSystemFont(ofSize: 12)
        tempLbl.text = datas?[indexPath.item].name
        let nameSize = tempLbl.sizeThatFits(CGSize(width: CGFloat.infinity, height: 20))
        tempLbl.font = UIFont.systemFont(ofSize: 12)
        tempLbl.text = STLLocalizedString_("new_in")
        let newInSize = tempLbl.sizeThatFits(CGSize(width: CGFloat.infinity, height: 20))
        let width = max(nameSize.width, newInSize.width) + 28
        return CGSize(width: width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentIndex = indexPath.item
        collectionView.reloadData()
        indexSelectPub.onNext(indexPath.item)
        if let data = datas?[indexPath.item,true] {
            bannerClicked(attr_node_2: "new_stream_\(data.date ?? "")")
            
            GATools.logNewTimenavigate(navigation: data.name ?? "")
        }
        
    }
    
    ///埋点
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let data = datas?[indexPath.item,true] {
            bannerViewed(attr_node_2: "new_stream_\(data.date ?? "")")
            GATools.logNewTimenavigate(navigation: data.name ?? "",isclick: true)
        }
    }
}


class TimeRangeCell:UICollectionViewCell{
    
    weak var nameLbl:UILabel?
    weak var goodsTotalLbl:UILabel?
    weak var newInLbl:UILabel?
    
    var isOn:Bool = false{
        didSet{
            let textColor = isOn ? UIColor.white : OSSVThemesColors.col_6C6C6C()
            nameLbl?.textColor = textColor
            goodsTotalLbl?.textColor = textColor
            newInLbl?.textColor = textColor
            self.backgroundColor = isOn ? OSSVThemesColors.col_0D0D0D() : UIColor.white
        }
    }
    
    override var isSelected: Bool{
        didSet{
            isOn = isSelected
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.setupViews()
        isOn = false
    }
    
    func setupViews() {
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        self.layer.cornerRadius = 6
        
        let container = UIStackView()
        container.axis = .vertical
        container.alignment = .center
        container.distribution = .equalCentering
        
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0))
        }
        
        
        
        let nameLbl = UILabel()
        self.nameLbl = nameLbl
        nameLbl.font = UIFont.boldSystemFont(ofSize: 12)
        container.addArrangedSubview(nameLbl)
        
        let totalLbl = UILabel()
        goodsTotalLbl = totalLbl
        totalLbl.font = UIFont.systemFont(ofSize: 12)
        container.addArrangedSubview(totalLbl)
        
        let newInLbl = UILabel()
        newInLbl.font = UIFont.systemFont(ofSize: 12)
        self.newInLbl = newInLbl
        container.addArrangedSubview(newInLbl)
        newInLbl.text = STLLocalizedString_("new_in")
    }
    
    
    required init?(coder: NSCoder) {
        isOn = false
        super.init(coder: coder)
    }
}

extension String {
    static let timeRangeCellReuseID = "TimeRangeCell"
    static let timeRangeHeaderReuseID = "timeRangeHeaderReuseID"
}



class HorizontalCollectionFlowLauout: UICollectionViewFlowLayout {
    override var flipsHorizontallyInOppositeLayoutDirection: Bool{
        return true
    }
}
