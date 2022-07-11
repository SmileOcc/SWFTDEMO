//
//  YXBannerManager.swift
//  uSmartOversea
//
//  Created by rrd on 2019/6/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import UIKit
import URLNavigator


class YXBannerManager: NSObject {
    
    class func goto(withBanner banner:BannerList, navigator:NavigatorServicesType) {
        //http://szwiki.youxin.com/pages/viewpage.action?pageId=1116777
        switch banner.newsJumpType {
        case .Native:
            if let jumpURL = banner.jumpURL, jumpURL.count > 0 {
                YXGoToNativeManager.shared.gotoNativeViewController(withUrlString: jumpURL)
            }
        case .Normal, .Recommend:
            if let newsID = banner.newsID, newsID.count > 0 {
                let dictionary: Dictionary<String, Any> = ["newsId" : newsID, "type" : banner.newsJumpType,"source" : YXPropInfoSourceValue.adBanner,
 ]
                let context = YXNavigatable(viewModel: YXInfoDetailViewModel(dictionary: dictionary))
                navigator.push(YXModulePaths.infoDetail.url, context: context)
            }
        case .Internal:
            if let jumpURL = banner.jumpURL, jumpURL.count > 0 {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: jumpURL, "type":YXInfomationType.Internal]
                navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        case .External, .Unknown:
            if let jumpURL = banner.jumpURL, jumpURL.count > 0 {
                let dic: [String: Any] = [YXWebViewModel.kWebViewModelUrl: jumpURL, "type":YXInfomationType.External]
                navigator.push(YXModulePaths.webView.url, context: YXWebViewModel(dictionary: dic))
            }
        }
    }

}
