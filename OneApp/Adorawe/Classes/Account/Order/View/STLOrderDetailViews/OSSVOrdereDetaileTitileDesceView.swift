//
//  OSSVOrdereDetaileTitileDesceView.swift
// XStarlinkProject
//
//  Created by odd on 2021/9/4.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVOrdereDetaileTitileDesceView: UIView {

    @objc lazy var titleLabel: UILabel = {
        $0.textColor = OSSVThemesColors.col_0D0D0D()
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textAlignment = .left
        if OSSVSystemsConfigsUtils.isRightToLeftShow() {
            $0.textAlignment = .right
        }
        return $0
    }(UILabel.init());
    
    @objc lazy var descLabel: UILabel = {
        let labe = UILabel.init()
        labe.textColor = OSSVThemesColors.col_0D0D0D()
        labe.font = UIFont.boldSystemFont(ofSize: 12)
        labe.textAlignment = .left
        if OSSVSystemsConfigsUtils.isRightToLeftShow() {
            labe.textAlignment = .right
        }
        return labe
    }()
    
    @objc lazy var copyBtn: UIButton = {
        let btn = UIButton.init(type: .custom)
        btn.setImage(UIImage.init(named: "order_copy12"), for: .normal)
        btn.addTarget(self, action: #selector(actionCopy), for: .touchUpInside)
        btn.setEnlargeEdge(10)
        btn.isHidden = true
        return btn
    }()
    
    @objc func showCopy(show: Bool) {
        self.copyBtn.isHidden = !show
        self.descLabel.snp.updateConstraints { make in
            make.trailing.equalTo(self.snp.trailing).offset(show ? -30 :-14)
        }
    }
    
    @objc func actionCopy() {
        if self.eventlock != nil {
            self.eventlock!()
        }
    }
    
    typealias CopyBlock = ()->Void
    @objc var eventlock:CopyBlock?
    
    @objc init(frame:CGRect, title: String!) {
        super.init(frame: frame)
        
        self.titleLabel.text = title

        self.addSubview(self.titleLabel)
        self.addSubview(self.descLabel)
        self.addSubview(self.copyBtn)

        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading).offset(14)
            make.centerY.equalTo(self.snp.centerY)
        }

        self.copyBtn.snp.makeConstraints { make in
            make.trailing.equalTo(self.snp.trailing).offset(-14)
            make.centerY.equalTo(self.snp.centerY)
            make.size.equalTo(CGSize.init(width: 12, height: 12))
        }
        
        self.descLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.snp.trailing).offset(-14)
            make.centerY.equalTo(self.snp.centerY)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
