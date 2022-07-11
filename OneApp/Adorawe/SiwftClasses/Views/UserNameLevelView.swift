//
//  UserNameLevelView.swift
// XStarlinkProject
//
//  Created by fan wang on 2021/7/23.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit
import YYImage
import RxSwift
import RxCocoa


///个人中心 username/会员等级图标
class UserNameLevelView: UIView {
    
    var disposeBag = DisposeBag()
    
    
    @objc weak var nameBtn:UIButton!
    @objc weak var levelImg:YYAnimatedImageView!
    
    ///occ 未使用
//    lazy var testRankView:RankView = {
//        let rank: RankView = RankView.init(frame: CGRect.zero)
//        rank.isHidden = true
//        return rank
//    }()
    
    @objc var nameHeight:CGFloat = 0{
        didSet{
            nameBtn.snp.updateConstraints { make in
                make.height.equalTo(nameHeight)
            }
        }
    }
    
    @objc var imgUrl:URL? {
        didSet{
            levelImg.isHidden = true;
//            levelImg.yy_setImage(with: imgUrl, placeholder: nil, options: .showNetworkActivity) {[weak self] img, _, _, _, _ in
//                if let img = img{
//
//                    DispatchQueue.main.async {
//                        let ratio = img.size.width / img.size.height
//                        let h = self?.levelImg.bounds.height ?? 18
//                        self?.levelImg.snp.remakeConstraints({ make in
//                            make.width.equalTo(h * ratio)
//                            make.height.equalTo(h)
//                        })
//                        self?.levelImg.image = img
//                    }
//                }
//            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        let container = UIStackView()
        container.axis = .vertical
        container.distribution = .fillProportionally
        container.alignment = .leading
        container.spacing = 4
        
        addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
        
        let nameBtn = UIButton()
        container.addArrangedSubview(nameBtn)
        self.nameBtn = nameBtn
        nameBtn.titleLabel?.snp.makeConstraints({ make in
            make.edges.equalTo(nameBtn)
        })
        
        nameBtn.snp.makeConstraints { make in
            make.height.equalTo(nameHeight)
        }
        
        let levelImg = YYAnimatedImageView()
        levelImg.contentMode = .scaleAspectFit
        container.addArrangedSubview(levelImg)
        levelImg.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        //v 2.0.0隐藏
        levelImg.isHidden = true;
        self.levelImg = levelImg
        levelImg.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        levelImg.addGestureRecognizer(tap)
        tap.rx.event.subscribe(onNext:{ _ in
            let webVc = STLActivityWWebCtrl()
            var targetStr = STLToString(OSSVAccountsManager.shared().account.vip_url) as String
            targetStr = "\(targetStr)?currency=USD"
            webVc.strUrl = targetStr
            self.navigationController().pushViewController(webVc, animated: true)
        }).disposed(by: disposeBag)
        
        if OSSVSystemsConfigsUtils.isRightToLeftShow(){
            nameBtn.titleLabel?.textAlignment = .right
        }else{
            nameBtn.titleLabel?.textAlignment = .left
        }
        
//        self.addSubview(self.testRankView)
//        self.testRankView.snp.makeConstraints { make in
//            make.leading.equalTo(self.snp.leading)
//            make.top.equalTo(self.snp.top)
//            make.height.equalTo(18)
//        }
    }
    
}


class RankView: UIView {
    
    var rankStarImageView: UIImageView = {
        let img = UIImageView.init(frame: CGRect.zero)
        return img;
    }()
    
    var rankBgImageView: UIImageView = {
        let img = UIImageView.init(frame: CGRect.zero)
        return img
    }()
    
    var rankArrowImageView: UIImageView = {
        let img = UIImageView.init(frame: CGRect.zero)
        img.image = UIImage.init(named: "member_arrow")
        img.convertUIWithARLanguage()
        return img
    }()
    
    var rankDesc: UILabel = {
        let lab = UILabel.init(frame: CGRect.zero)
        lab.textColor = OSSVThemesColors.stlWhiteColor()
        lab.font = UIFont.systemFont(ofSize: 10)
        return lab
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.addSubview(self.rankBgImageView);
        self.addSubview(self.rankStarImageView)
        self.addSubview(self.rankArrowImageView)
        self.addSubview(self.rankDesc)
        
        
        self.rankBgImageView.image = UIImage.resize(withImageName: "member_bg_v0")
        self.rankStarImageView.image = UIImage.init(named: "member_v0")
        self.rankDesc.text = "rank is good v1 --ffffffffffffff v2"
        
        self.rankStarImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalTo(self)
        }
        
        //与 rankStarImageView 高度上下相差为2
        self.rankBgImageView.snp.makeConstraints { make in
            make.leading.equalTo(self.rankStarImageView.snp.centerX).offset(2.2)
            make.top.equalTo(self.snp.top).offset(2)
            make.bottom.equalTo(self.snp.bottom).offset(-2)
        }
        
        self.rankDesc.snp.makeConstraints { make in
            make.leading.equalTo(self.rankBgImageView.snp.leading).offset(12)
            make.trailing.equalTo(self.rankBgImageView.snp.trailing).offset(-12)
            make.centerY.equalTo(self.snp.centerY)
        }
        
        self.rankArrowImageView.snp.makeConstraints { make in
            make.trailing.equalTo(self.rankBgImageView.snp.trailing).offset(-4)
            make.centerY.equalTo(self.snp.centerY)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
