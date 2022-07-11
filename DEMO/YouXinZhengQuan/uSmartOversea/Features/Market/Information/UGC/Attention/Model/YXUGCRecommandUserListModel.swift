//
//  YXUGCRecommandUserListModel.swift
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

import UIKit

//MARK:推荐的人的模型
class YXUGCRecommandUserListModel: YXResponseModel {
    
    @objc var list:[YXUGCRecommandUserModel] = []
    @objc var position:Int = 0
    @objc var query_token:String = ""
    
    @objc class func modelCustomPropertyMapper() -> [String : Any] {
        return [
            "list": "data.list",
            "position":"data.position",
            "query_token":"data.query_token"
        ]
    }
    
    @objc class func modelContainerPropertyGenericClass() -> [String : Any]? {
        return [
            "list": YXUGCRecommandUserModel.self,
        ]
    }
}

class YXUGCRecommandUserModel: YXModel {
    @objc var authExplain:String = ""
    @objc var avatar:String = ""
    @objc var id:String = ""
   
    @objc var nickname:String = ""
    @objc var uuid:String = ""
    @objc var userRoleType:Int = 0
    @objc var auth_user:Bool = false
    @objc var follow_status:Int32 = 0 //默认都是没有关注的
}


extension YXUGCRecommandUserListModel: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}

//MARK:没有关注的人 模型
class YXUGCNoAttensionUserModel: YXModel {
    @objc var title:String = ""
}

extension YXUGCNoAttensionUserModel: ListDiffable {

    func diffIdentifier() -> NSObjectProtocol {
        return self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}


