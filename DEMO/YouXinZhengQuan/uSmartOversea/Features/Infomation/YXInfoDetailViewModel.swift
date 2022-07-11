//
//  YXInfoDetailViewModel.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum YXInfomationType : Int {
    case Unknown = 0        // 未知详情跳转类型
    case Normal = 1         // 普通资讯-跳转类型
    case Recommend = 2      // 必读资讯-跳转类型
    case Internal = 3       // 内部H5浏览器-跳转类型
    case External = 4       // 外部浏览器-跳转类型
    case Native = 5         // Native跳转类型
    
    func converNewType() -> String {
        switch self {
        case .Native:
            return "1"
        case .Internal:
            return "2"
        default:
            return ""
        }
    }
}

extension YXInfomationType: Codable {
    public init(from decoder: Decoder) throws {
        self = try YXInfomationType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .Unknown
    }
}

class YXInfoDetailViewModel: YXWebViewModel {
    
    var type: YXInfomationType = .Unknown
    
    var newsId : String?
    
    var newsTitle: String?
    
    var algorithm: String?
    
    var source: String?
    
    var isCollectEnter: Bool = false //是否是收藏进入
    
    var dataCallback: ((Bool) -> Void)?
    
    // 是否已經收藏
    var isCollectResponse: YXResultResponse<JSONAny>?
    
    // 进行收藏或取消收藏
    var collectResponse: YXResultResponse<JSONAny>?
    
    var isCollectRelay = BehaviorRelay<Bool>(value: false)
    
    override var services: (HasYXNewsService & HasYXWebService)! {
        didSet {
            isCollectResponse  = { [weak self] (response) in
                guard let `self` = self else { return }
                
                switch response {
                case .success(let result, let code ):
                    switch code {
                    case .success?:
                        if let dic = result.data?.value as? Dictionary<AnyHashable, Any> {
                            if let collected = dic["collected"] as? Bool {
                                self.isCollectRelay.accept(collected)
                            } else {
                                self.isCollectRelay.accept(false)
                            }
                        } else {
                            self.isCollectRelay.accept(false)
                        }
                    default:
                        self.isCollectRelay.accept(false)
                    }
                default:
                    self.isCollectRelay.accept(false)
                }
            }
            
            collectResponse = { [weak self] (response) in
                guard let `self` = self else { return }

                switch response {
                case .success(let result, let code ):
                    switch code {
                    case .success?:
                        self.isCollectRelay.accept(!self.isCollectRelay.value)
                        if self.isCollectRelay.value {
                            self.hudSubject.onNext(.message(YXLanguageUtility.kLang(key: "collection_success"), false))
                        } else {
                            self.hudSubject.onNext(.message(YXLanguageUtility.kLang(key: "collection_cancel"), false))
                        }
                        // 如果是从收藏列表进入的资讯
                        if self.isCollectEnter,
                            let dataCallback = self.dataCallback {
                            dataCallback(self.isCollectRelay.value)
                        }
                    default:
                        if let msg = result.msg {
                            self.hudSubject.onNext(.message(msg, false))
                        }
                    }
                default:
                    self.hudSubject.onNext(.error(YXLanguageUtility.kLang(key: "common_net_error"), false))
                }
            }
        }
    }
    
    override init(dictionary: Dictionary<String, Any>) {
        super.init(dictionary: dictionary)
        
        self.type = dictionary["type"] as? YXInfomationType ?? .Unknown
        
        self.newsId = dictionary["newsId"] as? String
        
        self.algorithm = dictionary["algorithm"] as? String
        
        self.source = dictionary["source"] as? String
        
        if let newsId = self.newsId {
            self.url = YXH5Urls.YX_NEWS_URL(newsId: newsId)
        }
        
        self.newsTitle = dictionary["newsTitle"] as? String
    }
}
