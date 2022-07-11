//
//  YXNewsPopHandle.swift
//  YouXinZhengQuan
//
//  Created by lennon on 2021/10/8.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit
import RxSwift


class YXNewsAlertView: UIView {
    
    enum NewsType {
        case noneTpye
        case flash
        case infoDetail
        
        func name() -> String {
            switch self {
            case .flash:
                return  "快讯弹窗"
            case .infoDetail:
                return "资讯弹窗"
            default:
                return  ""
            }
        }
    }
    
    var type = NewsType.noneTpye
    
    lazy var watchMoreBtn: UIButton = {
        let watchMoreBtn = UIButton()
        watchMoreBtn.setTitleColor(UIColor.qmui_color(withHexString: "#0D50D8"), for: .normal)
        watchMoreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return watchMoreBtn
    }()
    
    init(frame: CGRect,  model:YXNoticeStruct) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.qmui_color(withHexString: "#FFFFFF")
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        let imageView = UIImageView(image: UIImage.init(named: "infoDetailBg"))
        addSubview(imageView)
        
        let newSTitleLab = UILabel()
        newSTitleLab.font = UIFont.systemFont(ofSize: 20)
        newSTitleLab.textColor = UIColor.qmui_color(withHexString: "#FFFFFF")
        addSubview(newSTitleLab)
        
        if let data = model.pushPloy?.data(using: .utf8),
           let json = ((try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) as [String : Any]??),
           let showPageUrl = json?["showPageUrl"] as? String, showPageUrl.count > 0
        {
            if showPageUrl.contains("flash_news") {
                watchMoreBtn.setTitle(YXLanguageUtility.kLang(key: "news_view_more"), for: .normal)
                newSTitleLab.text = YXLanguageUtility.kLang(key: "news_select")
                type = NewsType.flash
            } else if showPageUrl.contains("info_detail") {
                watchMoreBtn.setTitle(YXLanguageUtility.kLang(key: "news_view"), for: .normal)
                newSTitleLab.text = YXLanguageUtility.kLang(key: "news_selecte_market_Quotations")
                type = NewsType.infoDetail
            }
                
        }
        
        let hadTitle = (model.title?.count ?? 0 ) > 0
        
        let titleLab = QMUILabel();
        
        if  hadTitle {
            titleLab.text = model.title
            titleLab.textColor = QMUITheme().textColorLevel1()
            titleLab.font = UIFont.systemFont(ofSize: 16)
            titleLab.numberOfLines = 2
            titleLab.qmui_lineHeight = 24
            titleLab.lineBreakMode = .byTruncatingTail
            addSubview(titleLab)
            titleLab.snp.makeConstraints {
                $0.top.equalTo(imageView.snp.bottom).offset(12)
                $0.leading.equalToSuperview().offset(18)
                $0.trailing.equalToSuperview().offset(-18)
            }
            
        }

        
        let contentLab = UILabel()
        contentLab.text = model.content ?? " "
        contentLab.textColor = QMUITheme().textColorLevel1().withAlphaComponent(0.65)
        contentLab.font = UIFont.systemFont(ofSize: 14)
        contentLab.numberOfLines = 3
        contentLab.lineBreakMode = .byTruncatingTail
        addSubview(contentLab)
        
        let lineView = UIView()
        lineView.backgroundColor = QMUITheme().separatorLineColor()
        addSubview(lineView)
        
        addSubview(watchMoreBtn)
        
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(60)
            $0.centerX.equalToSuperview()
        }
        
        newSTitleLab.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(18)
        }
        
        contentLab.snp.makeConstraints {
            if hadTitle {
                $0.top.equalTo(titleLab.snp.bottom).offset(8)
            } else {
                $0.top.equalTo(imageView.snp.bottom).offset(12)
            }
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(18)
            $0.trailing.equalToSuperview().offset(-18)
        }
        
        lineView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
            $0.top.equalTo(contentLab.snp.bottom).offset(12)
        }
        
        watchMoreBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(lineView.snp.bottom)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview()
        }
        
            
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class YXNewsPopHandle: NSObject {
    
    var popType = YXPopAlertStatus.notShow
    
    let disposeBag = DisposeBag()
    
    func showNewsAlertView(with new: YXNoticeStruct, vc:UIViewController) {
        //配置了pushPloy才弹
        if let data = new.pushPloy?.data(using: .utf8),
           let json = ((try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) as [String : Any]??)
        {
            guard vc is YXInformationHomeViewController  else {
                return
            }
            
            
            // 英文快讯不弹
            if let showPageUrl = json?["showPageUrl"] as? String, showPageUrl.count > 0, showPageUrl.contains("flash_news"), YXUserManager.isENMode(){

                    return
            }

            //背景
            let bgView = UIView()
            bgView.backgroundColor = .clear
            
            let newsAlterView = YXNewsAlertView(frame: .zero, model: new)
            
            newsAlterView.watchMoreBtn.rx.tap.asObservable().subscribe(onNext: { [weak bgView, weak newsAlterView, weak self] in
                guard let bgView = bgView, let newsAlterView = newsAlterView, let `self` = self else {
                    return
                }
                bgView.hide()
                self.popType = .notShow
                if let showPageUrl = json?["showPageUrl"] as? String, showPageUrl.count > 0 {
                    
                    YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: showPageUrl)
                    let url = NSURL(string: showPageUrl)
                    let urlComponents = NSURLComponents(url: url as! URL, resolvingAgainstBaseURL: false)
                    var parameter:[String:String] = [:]
                    urlComponents?.queryItems?.forEach {
                        parameter[$0.name] = $0.value
                    }
                    var properties: [String : Any] = [:]
                    if parameter.keys.contains("newsid") {
                        
//                         properties = [YXSensorAnalyticsPropsConstants.propViewPage() : newsAlterView.type.name(),
//                                                          YXSensorAnalyticsPropsConstants.propViewName() : "点击查看详情",
//                                                          YXSensorAnalyticsPropsConstants.propUserId() : YXUserManager.userUUID(),
//                                                          YXSensorAnalyticsPropsConstants.propNewsId() : parameter["newsid"] ?? "" ]
                    } else {
//                        properties = [YXSensorAnalyticsPropsConstants.propViewPage() : newsAlterView.type.name(),
//                                                         YXSensorAnalyticsPropsConstants.propViewName() : "点击查看更多",
//                                                         YXSensorAnalyticsPropsConstants.propUserId() : YXUserManager.userUUID() ]
                    }
                        
                    YXSensorAnalyticsTrack.track(withEvent: .ViewClick, properties: properties)
                }
              
            }).disposed(by: self.disposeBag)
            bgView.addSubview(newsAlterView)
            
            
            newsAlterView.snp.makeConstraints {
                $0.center.equalToSuperview()
                $0.width.equalTo(285)
            }
            
            //关闭按钮
            let button = UIButton(type: .custom)
            button.setImage(UIImage(named: "pop_close"), for: .normal)
            bgView.addSubview(button)
            button.snp.makeConstraints { (make) in
                make.width.height.equalTo(30)
                make.top.equalTo(newsAlterView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
            }
            bgView.frame = UIScreen.main.bounds
            UIView.hideOldShowAlertView()
            bgView.showInWindow()
            popType = .showed
            
            //关闭响应
            button.rx.tap.asObservable().subscribe(onNext: { [weak bgView, weak newsAlterView, weak self] (_) in
                guard let bgView = bgView, let newsAlterView = newsAlterView, let `self` = self else {
                    return
                }
                bgView.hide()
                self.popType = .notShow
                
                if let showPageUrl = json?["showPageUrl"] as? String, showPageUrl.count > 0 {
                    
                    let url = NSURL(string: showPageUrl)
                    let urlComponents = NSURLComponents(url: url as! URL, resolvingAgainstBaseURL: false)
                    var parameter:[String:String] = [:]
                    urlComponents?.queryItems?.forEach {
                        parameter[$0.name] = $0.value
                    }
                    var properties: [String : Any] = [:]
                    if parameter.keys.contains("newsid") {
                        
//                         properties = [YXSensorAnalyticsPropsConstants.propViewPage() : newsAlterView.type.name(),
//                                                          YXSensorAnalyticsPropsConstants.propViewName() : "点击关闭",
//                                                          YXSensorAnalyticsPropsConstants.propUserId() : YXUserManager.userUUID(),
//                                       YXSensorAnalyticsPropsConstants.propNewsId() : parameter["newsid"] ?? ""]
                    } else {
//                        properties = [YXSensorAnalyticsPropsConstants.propViewPage() : newsAlterView.type.name(),
//                                                         YXSensorAnalyticsPropsConstants.propViewName() : "点击关闭",
//                                                         YXSensorAnalyticsPropsConstants.propUserId() : YXUserManager.userUUID() ]
                    }
                        
                    YXSensorAnalyticsTrack.track(withEvent: .ViewClick, properties: properties)
                }
                
            }).disposed(by: self.disposeBag)
        }
    }
    
}//
