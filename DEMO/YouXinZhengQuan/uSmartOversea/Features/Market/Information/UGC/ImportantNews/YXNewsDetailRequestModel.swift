//
//  YXNewsDetailRequestModel.swift
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/5/26.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

class YXNewsDetailRequestModel: YXHZBaseRequestModel {
    
    @objc var newsid = ""

    override func yx_requestUrl() -> String {
        return "/news-newsdetail/api/v1/detail_user"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
       return YXResponseModel.self
    }

}


class YXNewsDetailListRequestModel: YXHZBaseRequestModel {
    
    @objc var articleId = ""
    @objc var pageSize = 3
    override func yx_requestUrl() -> String {
        return "/news-relatedwitharticle/api/v1/query/article"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
       return YXResponseModel.self
    }

}


class YXArticleDetailRequestModel: YXHZBaseRequestModel {
    
    @objc var cid = ""

    override func yx_requestUrl() -> String {
        return "/feed-apiserver/api/v1/query-feed-detail"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
       return YXResponseModel.self
    }

}

class YXArticleDetailTranslateRequestModel: YXHZBaseRequestModel {
    
    @objc var newsid = ""

    override func yx_requestUrl() -> String {
        return "/news-translator/api/v1/translate"
    }

    override func yx_requestMethod() -> YTKRequestMethod {
        return YTKRequestMethod.GET
    }

    override func yx_responseModelClass() -> AnyClass {
       return YXResponseModel.self
    }

}

