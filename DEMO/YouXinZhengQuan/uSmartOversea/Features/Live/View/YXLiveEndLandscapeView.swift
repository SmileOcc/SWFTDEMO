//
//  YXLiveEndLandscapeView.swift
//  uSmartOversea
//
//  Created by suntao on 2021/2/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXLiveEndLandscapeView: UIView {

    var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = YXLanguageUtility.kLang(key: "live_finished")
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        
        return label
    }()
    
    var lookerLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.text = YXLanguageUtility.kLang(key: "live_viewer_count")
        label.font = UIFont.systemFont(ofSize: 16)
        
        return label
    }()
    
    var countLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.text = "--"
        label.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        
        return label
    }()
    
    @objc var count: String? {
        didSet {
            self.countLabel.text = count ?? "" + YXLanguageUtility.kLang(key: "live_viewer")
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }
    
    func initUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.7)
        addSubview(titleLabel)
        addSubview(lookerLabel)
        addSubview(countLabel)
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
        }
        
        lookerLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        countLabel.snp.makeConstraints { (make) in
            make.top.equalTo(lookerLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
