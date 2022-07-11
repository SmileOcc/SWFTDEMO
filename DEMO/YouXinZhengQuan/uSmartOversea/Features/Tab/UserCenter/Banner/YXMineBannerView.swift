//
//  YXMineBannerView.swift
//  uSmartOversea
//
//  Created by usmart on 2021/5/10.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXMineBannerView: UIView, UICollectionViewDataSource,UICollectionViewDelegate {
  

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    var adSize : CGSize  = CGSize.init(width: uniVerLength(300), height: uniVerLength(150))
    
    func reloadData() {
        collectionView.reloadData()
    }
   // YXUserManager.shared().userBanner
    
    var bannerList: [BannerList]? {
        didSet{
            if bannerList!.count > 1 {
                layout.itemSize = CGSize.init(width: uniVerLength(300), height: adSize.height)
            }else {
                layout.itemSize = adSize
            }
            self.reloadData()
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let layout = UICollectionViewFlowLayout()

    
    private lazy var collectionView : UICollectionView = {
        let view = UICollectionView.init(frame: .zero, collectionViewLayout: self.layout)
        return view
    }()
    func setupUI()  {
        self.backgroundColor = QMUITheme().foregroundColor()
        collectionView.backgroundColor = QMUITheme().foregroundColor()
        collectionView.showsHorizontalScrollIndicator = false
        
        addSubview(collectionView)
        layout.minimumInteritemSpacing = uniVerLength(8)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets.init(top: 0, left: uniVerLength(16), bottom: 0, right: uniVerLength(16))
        layout.itemSize = adSize
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(YXMineBannerCell.self, forCellWithReuseIdentifier: NSStringFromClass(YXMineBannerCell.self))
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(uniVerLength(33))
            make.bottom.equalTo(uniVerLength(-24))
            make.width.equalToSuperview()
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bannerList?.count ?? 0
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(YXMineBannerCell.self), for: indexPath) as! YXMineBannerCell
        let banner = bannerList?[indexPath.row]
        cell.imageView.sd_setImage(with: URL.init(string: banner?.pictureURL ?? ""), placeholderImage: UIImage.init(named: "min_banner"), options: .retryFailed, context: nil)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let appDelegate = YXConstant.sharedAppDelegate as? YXAppDelegate{
            YXBannerManager.goto(withBanner:bannerList![indexPath.row], navigator: appDelegate.navigator)
        }
    }
    
   

}

class YXMineBannerCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var imageView:UIImageView = {
        let imageViwe = UIImageView()
        imageViwe.clipsToBounds = true
        imageViwe.image = UIImage.init(named: "min_banner")
        return imageViwe
    }()
}
