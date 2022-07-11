//
//  AddressTypeCell.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxDataSources

class AddressTypeCell: UITableViewCell {
    
    let pub = PublishSubject<Int>()
    
    let disposeBag = DisposeBag()
    
    ///地址标识类型 0 不标识 1家 2学校 3公司
    var addressType:AddressType?{
        didSet{
            collectionView?.reloadData()
        }
    }
    
    
    weak var collectionView:UICollectionView?
    
    lazy var tapItemsTitle:[SelectTagModel] = {
        var items = [
            SelectTagModel(tagName:STLLocalizedString_("Home")!, tagType: .Home,imgName: "home"),
            SelectTagModel(tagName:STLLocalizedString_("School")!, tagType: .School,imgName: "school"),
            SelectTagModel(tagName:STLLocalizedString_("Company")!, tagType: .Office,imgName: "company"),
        ]
        if OSSVSystemsConfigsUtils.isRightToLeftShow(){
            items = items.reversed()
        }
        return items
    }()

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
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
            make.height.equalTo(50)
        }
        
        let titleLbl = UILabel(frame: .zero)
        contentView.addSubview(titleLbl)
        titleLbl.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.leading.equalTo(14+11)
        }
        titleLbl.text = STLLocalizedString_("Address Type")
        titleLbl.font = UIFont.systemFont(ofSize: 14)
        titleLbl.textColor = OSSVThemesColors.col_0D0D0D()
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.equalTo(titleLbl.snp.trailing).offset(8)
            make.top.bottom.equalTo(contentView)
            make.trailing.equalTo(contentView).offset(-25)
        }
        collectionView.register(AddressTagCell.self, forCellWithReuseIdentifier: .AddressTagCellID)
        collectionView.delegate = self
//        collectionView.dataSource = self
        self.collectionView = collectionView
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String,SelectTagModel>> { dataSource, collectionView, indexPath, item in

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: .AddressTagCellID, for: indexPath)
            if let cell = cell as? AddressTagCell{
                cell.tagLbl?.text = item.tagName

                cell.iconImg?.image = UIImage(named: item.imgName)
                if let addressType = self.addressType {
                    cell.isOn = item.tagType == addressType
                }else{
                    cell.isOn = false
                }
            }
            return cell
        }

        Observable.just([SectionModel(model: "", items: tapItemsTitle)]).bind(to: collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.subscribe(onNext:{[weak self] indexPath in
            if let item = self?.tapItemsTitle[indexPath.item]{
                self?.pub.onNext(item.tagType.rawValue)
                self?.addressType = item.tagType
            }
        }).disposed(by: disposeBag)

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension AddressTypeCell:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tempLbl = UILabel()
        tempLbl.font = UIFont.systemFont(ofSize: 12)
        tempLbl.text = tapItemsTitle[indexPath.item].tagName
        let width = tempLbl.sizeThatFits(CGSize(width: CGFloat.infinity, height: 17)).width
        return CGSize(width: width + 36,height: 50)
    }
}


enum AddressType: Int{
    case NoTag = 0
    case Home = 1
    case School = 2
    case Office = 3
}

struct SelectTagModel{
    var tagName:String
    var tagType:AddressType
    var imgName:String
}


class AddressTagCell:UICollectionViewCell{
    
    weak var tagLbl:UILabel?
    weak var statusImg:UIImageView?
    
    weak var iconImg:UIImageView?
    
    var isOn:Bool = false{
        didSet{
            statusImg?.isHighlighted = isOn
            tagLbl?.textColor = isOn ? OSSVThemesColors.col_FFFFFF() : OSSVThemesColors.col_0D0D0D()
            iconImg?.tintColor = isOn ? OSSVThemesColors.col_FFFFFF() : OSSVThemesColors.col_0D0D0D()
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let statusImg = UIImageView(image: UIImage(named: "address_tag_default"), highlightedImage: UIImage(named: "address_tag_slected"))
        contentView.addSubview(statusImg)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        statusImg.snp.makeConstraints { make in
            make.leading.trailing.equalTo(contentView)
            make.centerY.equalTo(contentView.snp.centerY)
            make.height.equalTo(28)
        }
        self.statusImg = statusImg
        
        let iconImageView = UIImageView()
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
            make.leading.equalTo(8)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        self.iconImg = iconImageView
        
        let tagLbl = UILabel()
        contentView.addSubview(tagLbl)
        tagLbl.font = UIFont.systemFont(ofSize: 12)
        tagLbl.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(4)
            make.trailing.equalTo(contentView).offset(-8)
            make.centerY.equalTo(contentView.snp.centerY)
        }
        self.tagLbl = tagLbl
        tagLbl.setContentCompressionResistancePriority(.required, for: .horizontal)
        tagLbl.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var isSelected: Bool{
        didSet{
            isOn = isSelected
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isOn = false
    }
}

extension String{
    static let AddressTagCellID = "AddressTagCellID"
}
