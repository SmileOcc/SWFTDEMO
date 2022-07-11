//
//  OSSVFollowsUssView.swift
// XStarlinkProject
//
//  Created by odd on 2021/8/5.
//  Copyright © 2021 starlink. All rights reserved.
//

import UIKit

class OSSVFollowsUssView: UIView {

    var followLabel: UILabel = {
        let lab = UILabel.init(frame: CGRect.zero)
        if (app_type == 3) {
            lab.textColor = OSSVThemesColors.col_0D0D0D()
            lab.font = UIFont.vivaiaRegularFont(16)
        } else {
            lab.textColor = OSSVThemesColors.col_B2B2B2()
            lab.font = UIFont.systemFont(ofSize: 12)
            lab.numberOfLines = 2
        }
        lab.text = STLLocalizedString_("following_us")
        if OSSVSystemsConfigsUtils.isRightToLeftShow() {
            lab.textAlignment = NSTextAlignment.right
        } else {
            lab.textAlignment = NSTextAlignment.left
        }
        return lab
    }()
    
    var topSpaceView: UIView = {
        let view = UIView.init(frame: CGRect.zero);
        view.backgroundColor = OSSVThemesColors.col_F5F5F5()
        view.isHidden = true
        return view
    }()
    
    var lineView: UIView = {
        let view = UIView.init(frame: CGRect.zero);
        view.backgroundColor = OSSVThemesColors.col_EEEEEE()
        view.isHidden = true
        return view
    }()
    
    
    var datas: NSMutableArray = NSMutableArray.init()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = OSSVThemesColors.col_FAFAFA();
        
        self.addSubview(self.topSpaceView)
        self.addSubview(followLabel)
        
        self.topSpaceView.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading)
            make.trailing.equalTo(self.snp.trailing)
            make.top.equalTo(self.snp.top)
            make.height.equalTo(8)
        }
        self.followLabel.snp.makeConstraints { make in
            if (app_type == 3) {
                make.top.equalTo(self.snp.top).offset(14 + 8)
            } else {
                make.centerY.equalTo(self.snp.centerY)
            }
            make.leading.equalTo(self.snp.leading).offset(14)
//            make.width.equalTo(103)
        }
        
        self.addSubview(self.lineView)
        self.lineView.snp.makeConstraints { make in
            make.leading.equalTo(self.snp.leading).offset(14)
            make.trailing.equalTo(self.snp.trailing).offset(-14)
            make.top.equalTo(self.snp.top).offset(40.5 + 8)
            make.height.equalTo(0.5)
        }
        
        if (app_type == 3) {
            self.backgroundColor = OSSVThemesColors.stlWhiteColor();
            //self.lineView.isHidden = false
            self.topSpaceView.isHidden = false
        }
        
        var temp:UIButton?
        for _ in 0...4 {
            let platomButton: UIButton = UIButton.init(type: .custom)
            platomButton.isEnabled = false
            //platomButton.backgroundColor = OSSVThemesColors.col_EEEEEE()
            //platomButton.layer.cornerRadius = 12.0
            //platomButton.layer.masksToBounds = true
            platomButton.isHidden = true;
            self.addSubview(platomButton)
            
            if temp != nil {
                platomButton.snp.makeConstraints { make in
                    if (app_type == 3) {
                        make.leading.equalTo(temp!.snp.trailing).offset(20)
                    } else {
                        make.trailing.equalTo(temp!.snp.leading).offset(-20)
                    }
                    make.centerY.equalTo(temp!.snp.centerY)
                    make.size.equalTo(CGSize.init(width: 24, height: 24))

                }
            } else {
                platomButton.snp.makeConstraints { make in
                    if (app_type == 3) {
                        make.top.equalTo(self.snp.top).offset(40+14+8)
                        make.leading.equalTo(self.snp.leading).offset(38)
                    } else {
                        make.centerY.equalTo(self.snp.centerY)
                        make.trailing.equalTo(self.snp.trailing).offset(-14)
                    }
                    make.size.equalTo(CGSize.init(width: 24, height: 24))

                }
            }
            temp = platomButton
        }
    }
    
    @objc class func contentHeigth() ->CGFloat {
        if (app_type == 3) {
            if let datas:NSArray = OSSVAccountsManager.shared().socialPlatforms as NSArray?, datas.count > 0 {
                return 8 + 40 + 52
            }
            return 0
        }
        return 40
    }
    
    @objc func updatePlatoms(datas: NSArray) {
        
        if (app_type == 3) {
            if let datas:NSArray = OSSVAccountsManager.shared().socialPlatforms as NSArray?, datas.count > 0 {
                self.isHidden = false;
            } else {
                self.isHidden = true;
            }
        }
        
        self.datas.removeAllObjects()
        if STLJudgeNSArray(datas) {
            self.datas.addObjects(from: datas as! [Any])
        }
        
        if self.datas.count <= 0 {
            return
        }
        
        for items in self.subviews {
            if items.isKind(of: UIButton.self) {
                items.removeFromSuperview()
            }
        }
        
        var temp:UIButton?
        for i in 0...self.datas.count-1 {
            if let model: OSSVSocialsPlatformsModel = self.datas[i] as? OSSVSocialsPlatformsModel {
                model.type = i;
                
                let platomButton: UIButton = UIButton.init(type: .custom)
                platomButton.yy_setImage(with: URL.init(string: STLToString(model.icon_link)), for: .normal, placeholder: nil)
                platomButton.imageView?.contentMode = ContentMode.scaleAspectFill
                platomButton.tag = 4000+model.type
                platomButton.layer.cornerRadius = 12.0
                platomButton.layer.masksToBounds = true
                platomButton.addTarget(self, action: #selector(platomAction(sender:)), for: .touchUpInside)
                platomButton.backgroundColor = OSSVThemesColors.col_EEEEEE()
                self.addSubview(platomButton)
                
                if temp != nil {
                    platomButton.snp.makeConstraints { make in
                        if (app_type == 3) {
                            make.leading.equalTo(temp!.snp.trailing).offset(20)
                        } else {
                            make.trailing.equalTo(temp!.snp.leading).offset(-20)
                        }
                        make.centerY.equalTo(temp!.snp.centerY)
                        make.size.equalTo(CGSize.init(width: 24, height: 24))

                    }
                } else {
                    platomButton.snp.makeConstraints { make in
                        if (app_type == 3) {
                            make.top.equalTo(self.snp.top).offset(40+14+8)
                            make.leading.equalTo(self.snp.leading).offset(38)
                        } else {
                            make.centerY.equalTo(self.snp.centerY)
                            make.trailing.equalTo(self.snp.trailing).offset(-14)
                        }
                        make.size.equalTo(CGSize.init(width: 24, height: 24))

                    }
                }
                temp = platomButton
            }
        }
    }
    
    typealias followPlotamBlock = (_ model: OSSVSocialsPlatformsModel)->Void
    @objc var followSelectBlock: followPlotamBlock?
    
    @objc func platomAction(sender: UIButton) {
        let tag: NSInteger = sender.tag - 4000
        if self.datas.count > tag,let model: OSSVSocialsPlatformsModel = self.datas[tag] as? OSSVSocialsPlatformsModel {

            OSSVAnalyticsTool.analyticsGAEvent(withName: "personal_action", parameters: ["screen_group":"Me","action":"Follow_\(model.social_name ?? "")"])
            if let url = URL(string: STLToString(model.jump_link)) {
                UIApplication.shared.open(url, options: [:]) { success in
                    
                }
            }
           
            if (self.followSelectBlock != nil) {
                self.followSelectBlock!(model)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
