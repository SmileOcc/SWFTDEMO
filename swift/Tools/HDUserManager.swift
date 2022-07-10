//
//  HDUserManager.swift
//  HDBaseProject
//
//  Created by 航电 on 2020/9/8.
//  Copyright © 2020 航电. All rights reserved.
//

import UIKit
import CoreLocation

public class HDUserManager: NSObject {
    
    public var id: Int?
    public var userName: String?
    //1：系统管理员，2：普通用户，3：施工人员
    public var userType: Int?
    public var password: String?
    //用户状态：1：启用，2：禁用，3：删除（默认1）
    public var status: Int?
    public var createTime: Int?
    public var updateTime: Int?
    public var systemCode: String?
    public var openid: Int?
    public var systemCodes: String?
    public var token: String?
    public var orgNames: String?
    public var roleNames: String?
    public var menus: Array<Any>?
    public var constructionRelateId: Int?
    public var desc: String?
    public var email: String?
    public var headSculpture: String?
    public var orgId: Int?
    public var phone: String?
    public var roleId: Int?
    public var realName: String?
    //个人下所有组织机构id
    public var organizations: Array<Any>?
    //个人下所有组织机构数据
    public var organizationAlls: Array<Any>?
    //个人项目集合
    public var projectList: Array<Any>?
    public var loginOut: Bool = false;
    
    
    //单例
    static public let sharedInstance = HDUserManager();
    
    public func dicToModel(userDic: NSDictionary) {
        self.loginOut = true;
        
        id = userDic["id"] as? Int
        userName = userDic["userName"] as? String
        userType = userDic["userType"] as? Int
        password = userDic["password"] as? String
        status = userDic["status"] as? Int
        createTime = userDic["createTime"] as? Int
        updateTime = userDic["updateTime"] as? Int
        systemCode = userDic["systemCode"] as? String
        openid = userDic["openid"] as? Int
        systemCodes = userDic["systemCodes"] as? String
        token = userDic["token"] as? String
        orgNames = userDic["orgNames"] as? String
        roleNames = userDic["roleNames"] as? String
        constructionRelateId = userDic["constructionRelateId"] as? Int
        desc = userDic["desc"] as? String
        email = userDic["email"] as? String
        headSculpture = userDic["headSculpture"] as? String
        orgId = userDic["orgId"] as? Int
        phone = userDic["phone"] as? String
        roleId = userDic["roleId"] as? Int
        realName = userDic["realName"] as? String
        
        let newMenus = (userDic["menus"] as? Array<Any>)!
        let mutArray = NSMutableArray();
        for item in newMenus {
            let menu = Menu()
            let detail = item as! NSDictionary
            menu.id = detail["id"] as? Int
            menu.type = userDic["type"] as? Int
            menu.name = userDic["name"] as? String
            menu.code = userDic["code"] as? String
            menu.url = userDic["url"] as? String
            menu.prentId = userDic["prentId"] as? Int
            menu.tier = userDic["tier"] as? Int
            menu.status = userDic["status"] as? Int
            menu.subMenue = userDic["subMenue"] as? Array
            mutArray.add(menu);
        }
        menus = (mutArray as! Array<Any>);
    }

    public func dicToOrganizationModel(userDic: NSDictionary) {
        
        let newOrganizations = (userDic["data"] as? Array<Any>)!
        let mutArray = NSMutableArray();
        let mutIdArray = NSMutableArray();
        for item in newOrganizations {
            let menu = OrganizationModel()
            let detail = item as! NSDictionary
            menu.id = detail["id"] as? Int
            menu.name = userDic["name"] as? String
            menu.code = userDic["code"] as? String
            menu.pid = userDic["pid"] as? Int
            menu.idPath = userDic["idPath"] as? String
            menu.status = userDic["status"] as? Int
            menu.systemCode = userDic["systemCode"] as? String
            menu.createTime = userDic["createTime"] as? String
            menu.updateTime = userDic["updateTime"] as? String
            mutArray.add(menu);
            mutIdArray.add(menu.id as Any);
        }
        organizationAlls = (mutArray as! Array<Any>);
        organizations = (mutIdArray as! Array<Any>);
    }
    
    public func dicToProjectModel(userDic: NSDictionary) {
        
        let projects = (userDic["data"] as? Array<Any>)!
        let mutArray = NSMutableArray();
        for item in projects {
            let menu = project()
            let detail = item as! NSDictionary
            menu.contractBeginTime = detail["contractBeginTime"] as? Int
            menu.contractEndTime = detail["contractEndTime"] as? Int
            menu.mobile = detail["mobile"] as? String
            menu.projectId = detail["projectId"] as? Int
            menu.projectManager = detail["projectManager"] as? String
            menu.projectName = detail["projectName"] as? String
            menu.questionNum = detail["questionNum"] as? Int
            mutArray.add(menu)
        }

        projectList = (mutArray as! Array<Any>)
    }
    
    override init() {
        super.init()
    }
}

public class Menu: NSObject {
    public var id: Int?
    //菜单类型：1：菜单，2：页面，3: 按钮
    public var type: Int?
    public var name: String?
    public var code: String?
    public var url: String?
    //父类菜单
    public var prentId: Int?
    //菜单层级
    public var tier: Int?
    //状态：1：启用，2：停用，3：删除（默认1）
    public var status: Int?
    public var subMenue: Array<Any>?
}

public class OrganizationModel: NSObject {
    //组织机构id
    public var id: Int?
    //组织机构名称
    public var name: String?
    //组织机构编码
    public var code: String?
    //父组织机构id
    public var pid: Int?
    //组织机构全路径
    public var idPath: String?
    //组织机构状态1：启用，2：禁用，3：删除
    public var status: Int?
    //系统编码
    public var systemCode: String?
    //创建时间
    public var createTime: String?
    //修改时间
    public var updateTime: String?
}

public class project: NSObject {
    public var contractBeginTime: Int?
    public var contractEndTime: Int?
    public var mobile: String?
    public var projectId: Int?
    public var projectManager: String?
    public var projectName: String?
    public var questionNum: Int?
}
