//
//  YXNavigatorMap.swift
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/5/13.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

import Foundation
import URLNavigator
import SwiftyJSON
import UIKit

let YX_NG_SCHEME = "usmart://"

public struct YXNavigationMap {
    
    static var navigator :NavigatorServicesType!
    
    static func initialize(navigator: NavigatorServicesType, services:AppServices) {
        
        self.navigator = navigator
        // 智能盯盘
        navigator.register(YXModulePaths.smartWatch.url) { (url, values, context) -> UIViewController? in
            if let smartType = context as? YXSmartType {
                let vc = YXSmartViewController()
                vc.smartType = smartType
                vc.navigator = navigator
                return vc
            }
            return nil
        }
        // 智能盯盘设置
        navigator.register(YXModulePaths.smartSettings.url) { (url, values, context) -> UIViewController? in
            if let smartType = context as? YXSmartType {
                let vc = YXSmartPushSettingsViewController.instantiate(withViewModel: YXSmartSettingViewModel(), andServices: YXSmartService(), andNavigator: navigator)
                vc.smartType = smartType
                return vc
            }
            return nil
        }
        
        // 代码搜索
        navigator.register(YXModulePaths.pushSearch.url) { (url, values, context) -> UIViewController? in
            
            let dic = context as? [String : Any]
            let types: [YXSearchType] = dic?["types"] as? [YXSearchType] ?? []
            let param: YXSearchParam? = dic?["param"] as? YXSearchParam
            let secuGroup: YXSecuGroup? = dic?["secuGroup"] as? YXSecuGroup
            
            let searchViewModel = YXNewSearchViewModel()
            searchViewModel.types = types
            searchViewModel.secuGroup = secuGroup
            searchViewModel.defaultParam = param
            let viewController = YXNewSearchViewController.instantiate(withViewModel: searchViewModel, andServices: services, andNavigator: navigator)
            
            viewController.didTouchedCancel = {[weak viewController] in
                viewController?.navigationController?.popViewController(animated: false)
            }
            
            viewController.didSelectedItem = { (item) in

                let input = YXStockInputModel()
                input.market = item.market
                input.symbol = item.symbol
                input.name = item.name ?? ""
                input.type1 = item.type1
                input.type2 = item.type2
                input.type3 = item.type3

                navigator.push(YXModulePaths.stockDetail.url , context: ["dataSource" : [input], "selectIndex" : 0])
            }
            
            viewController.navigationItem.hidesBackButton = true
            
            return viewController
        }
        
        // 代码搜索
        navigator.register(YXModulePaths.search.url) { (url, values, context) -> UIViewController? in
            
            let dic = context as? [String : Any]
            let types: [YXSearchType] = dic?["types"] as? [YXSearchType] ?? []
            let param: YXSearchParam? = dic?["param"] as? YXSearchParam
            let secuGroup: YXSecuGroup? = dic?["secuGroup"] as? YXSecuGroup
            let showPopular: Bool = dic?["showPopular"] as? Bool ?? true
            let showLike: Bool = dic?["showLike"] as? Bool ?? true
            let showHistory: Bool = dic?["showHistory"] as? Bool ?? true
            
            let searchViewModel = YXNewSearchViewModel()
            searchViewModel.types = types
            searchViewModel.secuGroup = secuGroup
            searchViewModel.defaultParam = param
            searchViewModel.showPopular = showPopular
            searchViewModel.showHistory = showHistory

            let viewController = YXNewSearchViewController.instantiate(withViewModel: searchViewModel, andServices: services, andNavigator: navigator)
            viewController.ishiddenLikeButton = !showLike
            let navController = YXNavigationController(rootViewController: viewController)
            navController.modalPresentationStyle = .fullScreen
            if #available(iOS 11.0, *) {
                navController.navigationBar.prefersLargeTitles = false
            }
            
            viewController.didTouchedCancel = {[weak viewController] in
                viewController?.dismiss(animated: false, completion: nil)
            }
            
            viewController.didSelectedItem = { (item) in

                let input = YXStockInputModel()
                input.market = item.market
                input.symbol = item.symbol
                input.name = item.name ?? ""
                input.type1 = item.type1
                input.type2 = item.type2
                input.type3 = item.type3 
                
                navigator.push(YXModulePaths.stockDetail.url, context: ["dataSource" : [input], "selectIndex" : 0])
                
                
            }
            
            return navController
        }

        // 综合搜索
        navigator.register(YXModulePaths.aggregatedSearch.url) { (url, values, context) -> UIViewController? in
            let vm = SearchViewModel(services: navigator, params: nil)
            let vc = SearchViewController(viewModel: vm)
            let navController = YXNavigationController(rootViewController: vc)
            navController.modalPresentationStyle = .fullScreen
            if #available(iOS 11.0, *) {
                navController.navigationBar.prefersLargeTitles = false
            }
            return navController
        }

        navigator.register(YXModulePaths.pushAggregatedSearch.url) { (url, values, context) -> UIViewController? in
            let vm = SearchViewModel(services: navigator, params: nil)
            let vc = SearchViewController(viewModel: vm)
            return vc
        }
        
        // 用户中心-设置
        navigator.register(YXModulePaths.userCenterSet.url) { (url, values, context) -> UIViewController? in
            let vc = YXSetViewController.instantiate(withViewModel: YXSetViewModel(), andServices: services, andNavigator: navigator)
            return vc
        }
        
        navigator.register(YXModulePaths.userCenterUserAccount.url) { (url, values, context) -> UIViewController? in
            let vc = YXAccountViewController.instantiate(withViewModel: YXAccountViewModel(), andServices: services, andNavigator: navigator)
            return vc
        }
        
        // 个股详情
        navigator.register(YXModulePaths.stockDetail.url) { (url, values, context) -> UIViewController? in
            if let params = context as? [String : Any],
                let inputs = params["dataSource"] as? [YXStockInputModel],
                let selectIndex = params["selectIndex"] as? Int {

                let viewModel = YXStockDetailViewModel(dataSource: inputs, selectIndex: selectIndex)
                
                if let selectTab = params["selectTab"] as? StockDetailViewTabType {
                    viewModel.selectTabType = selectTab
                }
                
                let vc = YXStockDetailViewController.instantiate(withViewModel: viewModel, andServices: services, andNavigator: navigator)
                
                let viewController = UIViewController.current()
                if viewController is YXNewSearchViewController {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        let navControllers = viewController.navigationController?.viewControllers
                        var array = navControllers ?? []
                        if array.count > 2 {
                            array.removeLast()
                            array.removeLast()
                            array.removeLast()
                            array.append(vc)
                            
                            viewController.navigationController?.viewControllers = array
                        }
                    }
                }
                
                return vc
            }
            return nil
        }

        // k线设置
        navigator.register(YXModulePaths.stockDetailChartSetting.url) { (url, values, context) -> UIViewController? in
            let vc = YXStockDetailKlineSettingVC()
            vc.viewModel.navigator = navigator
            return vc
        }

        
        // 网页浏览
        navigator.register(YXModulePaths.webView.url) { (url, values, context) -> UIViewController? in            
            if let viewModel = context as? YXWebViewModel {
                let vc = YXWebViewController.instantiate(withViewModel: viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        
        // 开户引导页
        navigator.register(YXModulePaths.openAccountGuide.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXOpenAccountGuideViewModel> {
                let accountGuideViewModel = YXOpenAccountGuideViewModel.init(dictionary: [:])
                let vc = YXOpenAccountGuideViewController.instantiate(withViewModel: accountGuideViewModel, andServices: services, andNavigator: navigator)
                vc.hidesBottomBarWhenPushed = false
                return vc
            }
            return nil
        }
        
        // 登录注册开户引导页
        navigator.register(YXModulePaths.loginOpenAccountGuide.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXOpenAccountGuideViewModel> {
                let accountGuideViewModel = YXOpenAccountGuideViewModel.init(dictionary: [:])
                let vc = YXLoginOpenAccountGuideViewController.instantiate(withViewModel: accountGuideViewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        
        // 美股行情权限
        navigator.register(YXModulePaths.USAuthState.url) { (url, values, context) -> UIViewController? in
            let vcName =  UIViewController.topMost?.className() ?? ""
            
            // 记录进入美股行情权限声明前的数据, 用于定位某些用户启动进去美股行情权限声明
            let data = YXUserManager.shared().curLoginUser
            let jsonEncoder = JSONEncoder()
            if let json = try? jsonEncoder.encode(data),
               let jsonString = String(data: json, encoding: .utf8) {
                let logStr = "美股行情权限声明:" + "当前界面:" + vcName + "用户当前数据:" + jsonString
                log(.warning, tag: kOther, content: logStr)
            } else {
                let logStr = "美股行情权限声明:" + "当前界面:" + vcName + "用户当前数据解析失败"
                log(.warning, tag: kOther, content: logStr)
            }
            
            if let navigatable = context as? YXNavigatable<YXUSAuthStateWebViewModel> {
                let vc = YXUSAuthStateWebViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 开户页
        navigator.register(YXModulePaths.openAccount.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXOpenAccountWebViewModel> {
                let vc = YXOpenAccountWebViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 用户默认登录页
        navigator.register(YXModulePaths.defaultLogin.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXLoginViewModel> {
                let vc = YXDefaultLoginViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 用户密码登录页
//        navigator.register(YXModulePaths.passwordLogin.url) { (url, values, context) -> UIViewController? in
//            if let navigatable = context as? YXNavigatable<YXLoginViewModel> {
//                let vc = YXLoginViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
//                if let temp = navigatable.userInfo?["fromDefaultData"] {
//                    vc.fromDefaultData = temp as? [String]
//                }
//                if let temp = navigatable.userInfo?["defaultLoginFillPhone"] {
//                    vc.defaultLoginFillPhone = temp as? ([String]) -> Void
//                }
//                
//                //
//                
//                //vc.fillPhone = navigatable.userInfo?["formDefaultData"] as? [String] ?? nil //传fillPhone  解决 短信登录和 密码登录之间传phone的问题
//                return vc
//            }
//            return nil
//        }
        
        // 机构默认登录页
        navigator.register(YXModulePaths.orgDefaultLogin.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXOrgLoginViewModel> {
                let vc = YXOrgDefaultLoginViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        
        /* 模块：找回密码-第1步
         验证手机号码 */
        /*调用的地方：
         1、弹框：密码错误次数过多账号已锁定 ，【找回密码】
         2、密码登录的 【找回密码】
         3、模块：修改登录密码- 修改登录密码 的 【忘记密码】*/
        navigator.register(YXModulePaths.forgetPwdInputPhone.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXForgetPwdPhoneViewModel> {
                let vc = YXForgetPwdPhoneViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 双重验证
        navigator.register(YXModulePaths.doubleCheck.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXDoubleCheckViewModel> {
                let vc = YXDoubleCheckViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 修改密码
        navigator.register(YXModulePaths.changePwd.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXChangePwdViewModel> {
                let vc = YXChangePwdViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 修改手机-验证旧手机
        navigator.register(YXModulePaths.changePhoneOld.url) { (url, values, context) -> UIViewController? in
            let vc = YXChangePhoneOldViewController.instantiate(withViewModel: YXChangePhoneOldViewModel() , andServices: services, andNavigator: navigator)
            return vc
        }
        
        // 修改手机-验证新手机
        navigator.register(YXModulePaths.changePhoneNew.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXChangePhoneNewViewModel> {
                let vc = YXChangePhoneNewViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 修改邮箱
        navigator.register(YXModulePaths.changeEmail.url) { (url, values, context) -> UIViewController? in
            
            if let navigatable = context as? YXNavigatable<YXChangeEmailViewModel> {
                let vc = YXChangeEmailViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 修改交易密码
        navigator.register(YXModulePaths.changeTradePwd.url) { (url, values, context) -> UIViewController? in
           
            if let navigatable = context as? YXNavigatable<YXChangeTradePwdViewModel> {
                let vc = YXAuthenTradeViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
            
            
//            if let navigatable = context as? YXNavigatable<YXChangeTradePwdViewModel> {
//                let vc = YXChangeTradePwdViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
//                return vc
//            }
//            return nil
        }
        
        /*跳转 ->  模块：重置交易密码 第1步
         请验证身份 */
        navigator.register(YXModulePaths.authenticate.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXAuthenticateViewModel> {
                let vc = YXAuthenticateViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 通知
        navigator.register(YXModulePaths.noti.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXNotiViewModel> {
                let vc = YXNotiViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 绑定手机
        navigator.register(YXModulePaths.bindPhone.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXFirstBindPhoneViewModel> {
                let vc = YXFirstBindPhoneViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.skin.url) { (url, values, context) -> UIViewController? in
            let vc = YXSkinSetViewController.instantiate(withViewModel: YXSkinSetViewModel() , andServices: services, andNavigator: navigator)
            return vc
        }
        
        navigator.register(YXModulePaths.loginBindPhone.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXLoginBindPhoneViewModel> {
                let vc = YXLoginBindPhoneViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        // 登录--证件号码激活
        navigator.register(YXModulePaths.loginIdNumActivate.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXIdCardActivateViewModel> {
                let vc = YXIdCardActivateViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        // 第三方平台登录--证件号码激活
        navigator.register(YXModulePaths.thirdLoginIdNumActivate.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXThirdPhoneActivateViewModel> {
                let vc = YXThirdPhoneActivateViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.bindCheckPhone.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXCheckPhoneViewModel> {
                let vc = YXCheckPhoneViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 验证邮箱找回交易密码
        navigator.register(YXModulePaths.verifyEmail.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXVerifyEmailViewModel> {
                let vc = YXVerifyEmailViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 调试配置
        navigator.register(YXModulePaths.debugInfo.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXDebugViewModel> {
                let vc = YXDebugViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // JS调试配置入口
        navigator.register(YXModulePaths.jsDebugInfo.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXDebugJSEntranceViewModel> {
                let vc = YXDebugJSEntranceViewController.instantiate(withViewModel: navigatable.viewModel , andServices:
                    services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 用户中心-我的收藏
        navigator.register(YXModulePaths.userCenterCollect.url) { (url, values, context) -> UIViewController? in
            let vc = YXCollectViewController.instantiate(withViewModel: YXCollectViewModel(), andServices: services, andNavigator: navigator)
            return vc
        }
        
        // 注册Code
        navigator.register(YXModulePaths.registerCode.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXRegisterCodeViewModel> {
                
                
                let vc = YXRegisterCodeViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                vc.fromDefaultLogin = navigatable.userInfo?["fromDefaultLogin"] as? Bool ?? false
                //以下4个是第三方登录绑定手机号要传的参数
                vc.accessToken = navigatable.userInfo?["accessToken"] as? String ?? ""
                vc.appleUserId = navigatable.userInfo?["appleUserId"] as? String ?? ""
                vc.openId = navigatable.userInfo?["openId"] as? String ?? ""
                vc.thirdLoginType = navigatable.userInfo?["thirdLoginType"] as? YXThirdLoginType ?? YXThirdLoginType.weChat
                vc.fillPhone = navigatable.userInfo?["fillPhone"] as? ([String]) -> Void
                
                vc.tempCaptcha = navigatable.userInfo?["tempCaptcha"] as? String ?? ""
                vc.recommendCode = navigatable.userInfo?["recommendCode"] as? String ?? ""
                vc.promotValue = navigatable.userInfo?["promotValue"] as? YXPromotionValue ?? YXPromotionValue()
                return vc
            }
            return nil
        }
        
        // 普通注册界面Code
        navigator.register(YXModulePaths.normalRegisterCode.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXSignUpRegisterCodeViewModel> {
                
                
                let vc = YXSignUpRegisterCodeViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                vc.tempCaptcha = navigatable.userInfo?["tempCaptcha"] as? String ?? ""
                vc.recommendCode = navigatable.userInfo?["recommendCode"] as? String ?? ""
                return vc
            }
            return nil
        }
        
        // 普通注册设置密码
        navigator.register(YXModulePaths.normalRegisterSetPwd.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXSignUpSetPwdViewModel> {
                
                
                let vc = YXSignUpSetPwdViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 用户中心
        navigator.register(YXModulePaths.userCenter.url) { (url, values, context) -> UIViewController? in
            let vc = YXUserCenterViewController.instantiate(withViewModel: YXUserCenterViewModel(), andServices: services, andNavigator: navigator)
            return vc
        }
        
        // 用户中心-关于
        navigator.register(YXModulePaths.userCenterAbout.url) { (url, values, context) -> UIViewController? in
            let vc = YXAboutViewController.instantiate(withViewModel: YXAboutViewModel(), andServices: services, andNavigator: navigator)
            return vc
        }
        
        // 用户中心-意见反馈
        navigator.register(YXModulePaths.userCenterFeedback.url) { (url, values, context) -> UIViewController? in
            let vc = YXFeedbackViewController.instantiate(withViewModel: YXFeedbackViewModel(), andServices: services, andNavigator: navigator)
            return vc
        }
        
        // 用户中心-风险测评
        navigator.register(YXModulePaths.userCenterBondRisk.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXWebViewModel> {
                let vc = YXWebViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.forgetPwdSet.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXForgetPwdSetViewModel> {
                let vc = YXForgetPwdSetViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
//        navigator.register(YXModulePaths.forgetPwdCode.url) { (url, values, context) -> UIViewController? in
//            if let navigatable = context as? YXNavigatable<YXForgetPwdCodeViewModel> {
//                let vc = YXForgetPwdCodeViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
//                return vc
//            }
//            return nil
//        }
        
        navigator.register(YXModulePaths.orgForgetPwdReset.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXOrgForgetPwdResetViewModel> {
                let vc = YXOrgForgetPwdResetViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }

        navigator.register(YXModulePaths.orgForgetPwdCheckAccount.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXOrgForgetPwdCheckAccountViewModel> {
                let vc = YXOrgForgetPwdCheckAccountViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }


        navigator.register(YXModulePaths.orgActiviteAccount.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXOrgActivateViewModel> {
                let vc = YXOrgActivateViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.orgCheckActiviteAccount.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXOrgCheckActivateViewModel> {
                let vc = YXOrgCheckActivateViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.orgCheckRegisterNumber.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXOrgRegisterNumberVertifyViewModel> {
                let vc = YXOrgRegisterNumberVertifyViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.orgCheckRegisterEmail.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXOrgRegisterEmailVertifyViewModel> {
                let vc = YXOrgRegisterEmailViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }

        navigator.register(YXModulePaths.orgAccount.url) { (url, values, context) -> UIViewController? in
            let vc = YXOrgAccountViewController.instantiate(withViewModel: YXOrgAccountViewModel(), andServices: services, andNavigator: navigator)
            return vc
        }
        
        navigator.register(YXModulePaths.history.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXHistoryViewModel> {
                let vc = YXHistoryViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.shiftInStock.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXShiftInStockViewModel> {
                let vc = YXShiftInStockViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.shiftInHistory.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXShiftInStockHistoryViewModel> {
                let vc = YXShiftInStockHistoryViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.exchange.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXCurrencyExchangeViewModel> {
                let vc = YXCurrencyExchangeViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 新股中心
        navigator.register(YXModulePaths.newStockCenter.url) { (url, values, context) -> UIViewController? in
            
            let vc = YXNewStockCenterViewController()
            
            var market = YXMarketType.HK.rawValue
            var isToPreMarket = false
            if let dict = context as? [String : Any] {
                if let tempMarket = dict["market"] as? String {
                    market = tempMarket
                }
                if let toPreMarket = dict["toPreMarket"] as? Bool {
                    isToPreMarket = toPreMarket
                }
                if let defaultTab = dict["defaultTab"] as? YXNewStockCenterTab {
                    vc.defaultTabViewTab = defaultTab
                }
            }
       
            vc.viewModel.exchangeType = YXExchangeType.exchangeType(market)
            vc.viewModel.navigator = navigator
            vc.viewModel.isToPreMarket = isToPreMarket
            return vc
        }
        
        // 新股市场
        navigator.register(YXModulePaths.newStockMarket.url) { (url, values, context) -> UIViewController? in

            if let dict = context as? [String : Any],
                let market = dict["market"] as? String {
                
                let vc = YXNewStockMarketViewController()
                vc.viewModel.market = market
                vc.viewModel.navigator = navigator
                return vc
            }
            return nil
        }
        
        // 新股认购记录列表
        navigator.register(YXModulePaths.newStockPurcahseList.url) { (url, values, context) -> UIViewController? in
//            let vc = YXNewStockListViewController()
//            vc.navigator = navigator
//            if let type = context as? YXExchangeType {
//                vc.exchangeType = type
//            }
//            return vc

            var exchangeType: YXExchangeType = .hk
            if let type = context as? YXExchangeType {
                exchangeType = type
            }
            let dic: [String: Any] = [
                YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_NEW_STOCK_SUBSCRIBE_RECORD_URL(exchangeType.rawValue)
            ]
    
            let vc = YXWebViewController.instantiate(withViewModel: YXWebViewModel(dictionary: dic), andServices: services, andNavigator: navigator)
            return vc
        }
        
        // 新股市场
        navigator.register(YXModulePaths.newStockDelivered.url) { (url, values, context) -> UIViewController? in
            let vc = YXNewStockDeliveredViewController()
            vc.viewModel.navigator = navigator
            return vc
        }
  
        // 新股明细
        navigator.register(YXModulePaths.newStockDetail.url) { (url, values, context) -> UIViewController? in
            if let dict = context as? [String : Any],
                let exchangeType = dict["exchangeType"] as? Int,
                let stockCode = dict["stockCode"] as? String {
                
                let ipoId = dict["ipoId"] as? Int64
                
//                let vc = YXNewStockDetailViewController()
//                vc.exchangeType = exchangeType
//                vc.ipoId = ipoId
//                vc.stockCode = stockCode
//                vc.viewModel.navigator = navigator

                let dic: [String: Any] = [
                    YXWebViewModel.kWebViewModelUrl: YXH5Urls.YX_NEWSTOCK_DETAIL_URL(exchangeType: exchangeType, ipoId: ipoId ?? 0, stockCode: stockCode)
                ]
                let vc = YXWebViewController.instantiate(withViewModel: YXWebViewModel(dictionary: dic), andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // IPO新股认购明细
        navigator.register(YXModulePaths.newStockIPOListDetail.url) { (url, values, context) -> UIViewController? in
            if let dic = context as? [String : Any],
                let applyId = dic["applyID"] as? String {
                let vc = YXNewStockIPOListDetailVC()
                vc.applyID = applyId
                vc.viewModel.navigator = navigator
                if let subsType = dic["applyType"] as? YXNewStockSubsType {
                    vc.viewModel.applyType = subsType
                }
                
                if let exchangeType = dic["exchangeType"] as? YXExchangeType {
                    vc.viewModel.exchangeType = exchangeType
                }
                return vc
            }
            return nil
        }
        
        // ECM新股认购明细
        navigator.register(YXModulePaths.newStockECMListDetail.url) { (url, values, context) -> UIViewController? in
            if let dic = context as? [String : Any],
                let applyId = dic["applyID"] as? String {
                let vc = YXNewStockECMListDetailVC()
                vc.applyID = applyId
                if let exchangeType = dic["exchangeType"] as? YXExchangeType {
                    vc.viewModel.exchangeType = exchangeType
                }
                vc.viewModel.navigator = navigator
                return vc
            }
            return nil
        }
        
        // IPO新股认购
        navigator.register(YXModulePaths.newStockIPOPurchase.url) { (url, values, context) -> UIViewController? in
            if let params = context as? YXPurchaseDetailParams {
                let vc = YXNewStockIPOPurchaseVC()
                vc.viewModel.navigator = navigator
                vc.viewModel.sourceParam = params
                return vc
            }
            return nil
        }
        
        // 美股认购
        navigator.register(YXModulePaths.newStockUSPurchase.url) { (url, values, context) -> UIViewController? in
            if let params = context as? YXPurchaseDetailParams {
                let vc = YXNewStockUSPurchaseVC()
                vc.viewModel.navigator = navigator
                vc.viewModel.sourceParam = params
                return vc
            }
            return nil
        }
        
        // ECM新股认购
        navigator.register(YXModulePaths.newStockECMPurchase.url) { (url, values, context) -> UIViewController? in
            if let params = context as? YXPurchaseDetailParams {
                let vc = YXNewStockECMPurchaseVC()
                vc.viewModel.navigator = navigator
                vc.viewModel.sourceParam = params
                return vc
            }
            return nil
        }
        
        // 美股确认页
        navigator.register(YXModulePaths.newStockUSConfirm.url) { (url, values, context) -> UIViewController? in
            if let params = context as? YXPurchaseDetailParams {
                let vc = YXNewStockUSConfirmVC()
                vc.viewModel.navigator = navigator
                vc.viewModel.sourceParam = params
                return vc
            }
            return nil
        }
        
        // 个人资料
        navigator.register(YXModulePaths.personalData.url) { (url, values, context) -> UIViewController? in
            let vc = YXPersonDataViewController.instantiate(withViewModel: YXPersonalDataViewModel(), andServices: services, andNavigator: navigator)
            return vc
        }
        
        // 隐私协议
        navigator.register(YXModulePaths.appPrivacy.url) { (url, values, context) -> UIViewController? in
            let vc = YXPrivacyViewController.instantiate(withViewModel: YXPrivacyViewModel(), andServices: services, andNavigator: navigator)
            return vc
        }
        // 跳转 修改昵称
        navigator.register(YXModulePaths.modifyNickName.url) { (url, values, context) -> UIViewController? in
            let vc = YXModifyNickNameViewController.instantiate(withViewModel: YXModifyNickNameViewModel(), andServices: services, andNavigator: navigator)
            return vc
        }
        
        navigator.register(YXModulePaths.forgetPwdPhone.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXForgetPwdPhoneViewModel> {
                let vc = YXForgetPwdPhoneViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        //设置登录密码
        navigator.register(YXModulePaths.setLoginPwd.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXSetLoginPwdViewModel> {
                let vc = YXSetLoginPwdViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 交易下单页面
        navigator.register(YXModulePaths.trading.url) { (url, values, context) -> UIViewController? in

            nil
        }
        
        // 持仓列表
        navigator.register(YXModulePaths.holdList.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXHoldListViewModel> {
                let vc = YXHoldListViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
            
        // 股票和债券持仓列表
        navigator.register(YXModulePaths.mixHoldList.url) { (url, values, context) -> UIViewController? in
                if let navigatable = context as? YXNavigatable<YXMixHoldListViewModel> {
                        let vc = YXMixHoldListViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                        return vc
            }
            return nil
        }

        
        // 订单列表
        navigator.register(YXModulePaths.orderList.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXOrderListViewModel> {
                let vc = YXOrderListViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                vc.isFromAAStock = navigatable.userInfo?["isFromAAStock"] as? Bool ?? false
                return vc
            }
            return nil
        }
        
        // 全部（港、美、A）订单列表
        navigator.register(YXModulePaths.allOrderList.url) { (url, values, context) -> UIViewController? in

            if let navigatable = context as? YXNavigatable<YXAggregatedOrderListViewModel> {
                let vc = YXAggregatedOrderListViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                vc.viewModel.navigator = navigator
                return vc
            }

            return nil
        }
        
        
        // 债券订单明细
        navigator.register(YXModulePaths.bondOrderDetail.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXBondDetailViewModel> {
                let vc = YXBondDetailViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        //订单详情
        navigator.register(YXModulePaths.orderDetail.url) { (url, values, context) -> UIViewController? in
            if let viewModel = context as? YXOrderDetailViewModel {
                let vc = YXOrderDetailViewController.instantiate(withViewModel: viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 帮助与客服
        navigator.register(YXModulePaths.onlineService.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXOnlineServiceViewModel> {
                let vc = YXOnlineServiceViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 资讯详情
        navigator.register(YXModulePaths.infoDetail.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXInfoDetailViewModel> {
                let vc = YXInfoDetailViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        //个股ETF
        navigator.register(YXModulePaths.stockETF.url) { (url, value, context) -> UIViewController? in
            
            if let dic = context as? [String : Any],
                let name = dic["name"] as? String?,
                let symbol = dic["symbol"] as? String,
                let market = dic["market"] as? String {
                let vc = YXStockETFViewController()
                vc.viewModel.navigator = navigator
                vc.viewModel.name = name
                vc.viewModel.symbol = symbol
                vc.viewModel.market = market
                return vc
            }
            return nil
        }
        
        // 简况所属行业
        navigator.register(YXModulePaths.stockIndustry.url) { (url, values, context) -> UIViewController? in
       
            if let dic = context as? [String : Any],
                let title = dic["title"] as? String?,
                let market = dic["market"] as? String,
                let code = dic["code"] as? String {
                let vc = YXStockDetailIndustryVC()
                vc.viewModel.navigator = navigator
                vc.viewModel.title = title
                vc.viewModel.code = code
                vc.viewModel.market = market
                if let sortType = dic["sortType"] as? YXStockRankSortType, let sortDirection = dic["sortDirection"] as? Int {
                    vc.viewModel.sorttype = sortType
                    vc.viewModel.sortdirection = sortDirection
                }
                if let rankType = dic["rankType"] as? YXRankType {
                    vc.viewModel.rankType = rankType
                }
                return vc
            }
            return nil
        }
        
        // 简况所属行业
         navigator.register(YXModulePaths.stockIndustryLand.url) { (url, values, context) -> UIViewController? in
        
             if let dic = context as? [String : Any],
                 let title = dic["title"] as? String?,
                 let market = dic["market"] as? String,
                 let code = dic["code"] as? String {
                 let vc = YXStockDetailIndustryLandVC()
                 vc.viewModel.navigator = navigator
                 vc.viewModel.title = title
                 vc.viewModel.code = code
                 vc.viewModel.market = market
                 if let isFromBK = dic["isFromBK"] as? Bool {
                    vc.viewModel.isDetailIndustry = isFromBK
                 }

                 if let isShowBMP = dic["isShowBMP"] as? Bool {
                     vc.viewModel.isShowBMP = isShowBMP
                 }
                if let rankType = dic["rankType"] as? YXRankType {
                    vc.viewModel.rankType = rankType
                }
                
                 return vc
             }
             return nil
         }
        
        // 提醒設置
//        navigator.register(YXModulePaths.stockRemindSetting.url) { (url, value, context) -> UIViewController? in
//            if let dic = context as? [String : Any],
//                let symbol = dic["symbol"] as? String,
//                let market = dic["market"] as? String {
//                let vc = YXStockRemindSettingVC()
//                vc.viewModel.navigator = navigator
//                vc.viewModel.symbol = symbol
//                vc.viewModel.market = market
//                if let isFromMyReminder = dic["isFromMyReminder"] as? Bool {
//                    vc.viewModel.isFromMyReminder = isFromMyReminder
//                }
//                return vc
//            }
//            return nil
//        }
        
        // 提醒設置
//        navigator.register(YXModulePaths.myRemind.url) { (url, value, context) -> UIViewController? in
//            let vc = YXStockMyRemindVC()
//            vc.viewModel.navigator = navigator
//            if let dic = context as? [String : Any] {
//                if let market = dic["market"] as? String {
//                    vc.viewModel.market = market
//                }
//
//                if let symbol = dic["symbol"] as? String {
//                    vc.viewModel.symbol = symbol
//                }
//            }
//            return vc
//        }
        
        // 财务
        navigator.register(YXModulePaths.stockFinancial.url) { (url, value, context) -> UIViewController? in
            if let dic = context as? [String : Any],
                let symbol = dic["symbol"] as? String,
                let market = dic["market"] as? String {
                let vc = YXStockDetailFinancialVC()
                vc.viewModel.navigator = navigator
                vc.viewModel.symbol = symbol
                vc.viewModel.market = market
                return vc
            }
            return nil
        }
        
        // 公告
        navigator.register(YXModulePaths.stockAnnounce.url) { (url, value, context) -> UIViewController? in
            if let dic = context as? [String : Any],
                let symbol = dic["symbol"] as? String,
                let market = dic["market"] as? String, let name = dic["name"] as? String {
                let vc = YXStockDetailAnnounceVC()
                vc.viewModel.navigator = navigator
                vc.viewModel.symbol = symbol
                vc.viewModel.market = market
                vc.viewModel.name = name
                return vc  
            }
            return nil
        }
        
        // 股票详情里点击查看更多新闻列表
        navigator.register(YXModulePaths.stockNewsList.url) { (url, value, context) -> UIViewController? in
            if let dic = context as? [String : Any],
                let symbol = dic["symbol"] as? String,
                let market = dic["market"] as? String {
                let vc = YXStockDetailNewsVC()
                vc.viewModel.navigator = navigator
                vc.viewModel.symbol = symbol
                vc.viewModel.market = market
                return vc
            }
            return nil
        }
        // 新闻列表
        navigator.register(YXModulePaths.infomations.url) { (url, value, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXInformationHomeViewModel> {
                let vc = YXInformationHomeViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        // 图片导入自选股
        navigator.register(YXModulePaths.importPic.url) { (url, value, context) -> UIViewController? in
            let vc = YXImportPicViewController()
            vc.viewModel.navigator = navigator
            return vc
        }
        
        // 简况
        navigator.register(YXModulePaths.stockIntroduce.url) { (url, value, context) -> UIViewController? in
            if let dic = context as? [String : Any],
                let symbol = dic["symbol"] as? String,
                let market = dic["market"] as? String {
                let vc = YXStockDetailIntroduceVC()
                vc.viewModel.navigator = navigator
                vc.viewModel.symbol = symbol
                vc.viewModel.market = market
                return vc
            }
            return nil
        }
        
        //新股国际配售签名页
        navigator.register(YXModulePaths.newStockSignature.url) { (url, value, context) -> UIViewController? in
           
            if let params = context as? YXPurchaseDetailParams {
                let vc = YXNewStockECMSignatureVC()
                vc.viewModel.navigator = navigator
                vc.viewModel.sourceParam = params
                return vc
            }
            return nil
        }
      
        //轮证
        navigator.register(YXModulePaths.stockWarrants.url) { (url, value, context) -> UIViewController? in
            
            if let dic = context as? [String : Any],
                let name = dic["name"] as? String?,
                let symbol = dic["symbol"] as? String,
                let market = dic["market"] as? String,
                let change = dic["change"] as? Int64,
                let roc = dic["roc"] as? Int32,
                let now = dic["now"] as? Int64,
                let warrantType = dic["warrantType"] as? YXStockWarrantsType,
                let priceBase = dic["priceBase"] as? UInt32 {
                let vc = YXStockWarrantsViewController()
                vc.viewModel.navigator = navigator
                vc.viewModel.name = name
                vc.viewModel.symbol = symbol
                vc.viewModel.market = market
                vc.viewModel.change = change
                vc.viewModel.roc = roc
                vc.viewModel.now = now
                vc.viewModel.priceBase = priceBase
                vc.viewModel.warrantType = warrantType
                vc.viewModel.pushVC = dic["pushVC"] as? YXStockWarrantsViewController
                vc.updateHeaderViewStock()

                return vc
                
            }else if let dic = context as? [String : Any], let warrantType = dic["warrantType"] as? YXStockWarrantsType {
                let vc = YXStockWarrantsViewController()
                if let ishideLZBButton = dic["ishideLZBButton"] as? Bool {
                    vc.isHideLZBButton = ishideLZBButton
                }
                vc.viewModel.navigator = navigator
                vc.viewModel.warrantType = warrantType
                vc.viewModel.pushVC = dic["pushVC"] as? YXStockWarrantsViewController
                vc.clearAll()
                return vc
            }
            
            return nil
        }
        
        // 横屏个股
        navigator.register(YXModulePaths.landStockDetail.url) { (url, value, context) -> UIViewController? in

            if let params = context as? [String : Any],
                let inputs = params["dataSource"] as? [YXStockInputModel],
                let selectIndex = params["selectIndex"] as? Int {

                let viewModel = YXStockDetailLandViewModel(dataSource: inputs, selectIndex: selectIndex)

                let vc = YXStockDetailLandVC()
                vc.viewModel = viewModel
                vc.viewModel.navigator = navigator
                if let fromLand = params["fromLand"] as? Bool {
                    vc.viewModel.isFromLandVC = fromLand
                }
                if let fromDetail = params["fromDetail"] as? Bool {
                    vc.viewModel.isFromStockDetailVC = fromDetail
                }

                if let selectIndexBlock = params["selectIndexBlock"] as? (Int)->() {
                    vc.viewModel.selectIndexBlock = selectIndexBlock
                }
                
                if let tsType = params["tsType"] as? YXTimeShareLineType {
                    vc.viewModel.selectTsType = tsType
                }

                return vc
            }

            return nil
        }

        // 个人设置
        navigator.register(YXModulePaths.preferenceSetting.url) { (url, value, context) -> UIViewController? in
            
            if let navigatable = context as? YXNavigatable<YXPreferenceSetViewModel> {
                let vc = YXPreferenceSetViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)

                return vc
            }
            return nil
        }
        
        //轮证筛选
        navigator.register(YXModulePaths.stockWarrantsSort.url) { (url, value, context) -> UIViewController? in
            
            if let dic = context as? [String : Any] {
                                
                let vc = YXStockWarrantsSortViewController()
                vc.viewModel.navigator = navigator
                vc.sortView.outstandingPctLow = dic["outstandingPctLow"] as? String ?? ""
                vc.sortView.outstandingPctHeight = dic["outstandingPctHeight"] as? String ?? ""
                vc.sortView.exchangeRatioLow = dic["exchangeRatioLow"] as? String ?? ""
                vc.sortView.exchangeRatioHeight = dic["exchangeRatioHeight"] as? String ?? ""
                vc.sortView.recoveryPriceLow = dic["recoveryPriceLow"] as? String ?? ""
                vc.sortView.recoveryPriceHeight = dic["recoveryPriceHeight"] as? String ?? ""
                vc.sortView.extendedVolatilityLow = dic["extendedVolatilityLow"] as? String ?? ""
                vc.sortView.extendedVolatilityHeight = dic["extendedVolatilityHeight"] as? String ?? ""
                vc.sortView.moneyness = Int(dic["moneyness"] as? String ?? "0") ?? 0
                vc.sortView.leverageRatio = Int(dic["leverageRatio"] as? String ?? "0") ?? 0
                vc.sortView.premium = Int(dic["premium"] as? String ?? "0") ?? 0
                vc.sortView.outstandingRatio = Int(dic["outstandingRatio"] as? String ?? "0") ?? 0
                vc.confirmCallBack = dic["confirmCallBack"] as? ([String : String]) -> Void
                vc.sortView.setAllBtnState()
                return vc
            }
            return nil
        }

        // 报价图表
        navigator.register(YXModulePaths.setStockQuote.url) { (url, value, context) -> UIViewController? in
            
//            if let navigatable = context as? YXNavigatable<YXSetStockQuoteViewModel> {
//                let vc = YXSetStockQuoteViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
//                return vc
//            }
            nil
        }
        
        // 轮证搜索
        navigator.register(YXModulePaths.stockWarrantsSearch.url) { (url, values, context) -> UIViewController? in
            
            if let dic = context as? [String : Any] {
                
                let vc = YXWarrantsSearchViewController.instantiate()
                vc.viewModel = YXWarrantsSearchViewModel()
                vc.viewModel.navigator = navigator

                vc.didTouchedCancel = {[weak vc] in
                    vc?.dismiss(animated: true, completion: nil)
                }
                
                vc.didSelectedItem = dic["didSelectedItem"] as? (YXSearchItem) -> ()
                vc.didSelectedAll = dic["didSearchAll"] as? (Bool) -> ()
                if let warrantType = dic["warrantType"] as? YXStockWarrantsType {
                    vc.viewModel.warrantType = warrantType
                }
                if let isFromBullBearAssetSearch = dic["isFromBullBearAssetSearch"] as? Bool {
                    vc.isFromBullBearAssetSearch = isFromBullBearAssetSearch
                }
                vc.bullBearAssetListViewModel = dic["bullBearAssetViewModel"] as? YXBullBearAssetListViewModel

                if vc.viewModel.warrantType == .optionChain {
                    vc.hidesBottomBarWhenPushed = true
                    if let needPushOptionChain = dic["needPushOptionChain"] as? Bool {
                        vc.viewModel.needPushOptionChain = needPushOptionChain
                    }
                    return vc
                } else {
                    let nv = YXNavigationController(rootViewController: vc)
                    if #available(iOS 11.0, *) {
                        nv.navigationBar.prefersLargeTitles = false
                    }
                    return nv
                }
            }
            
            return nil
        }

        
        // 优惠信息设定
        navigator.register(YXModulePaths.promotionMsg.url) { (url, value, context) -> UIViewController? in
            
            if let navigatable = context as? YXNavigatable<YXPromotionMsgViewModel> {
                let vc = YXPromotionMsgViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }

                
        // 选择区号
        navigator.register(YXModulePaths.areaCodeSelection.url) { (url, value, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXAreaCodeViewModel> {
                let vc = YXAreaCodeViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        
        // 市场
        navigator.register(YXModulePaths.market.url) { (url, value, context) -> UIViewController? in
            let vc = YXMarketViewController()
            vc.viewModel.navigator = navigator
            return vc
        }
        
        // 港股adr
        navigator.register(YXModulePaths.hkADR.url) { (url, value, context) -> UIViewController? in
            if let dic = context as? [String : YXRankType], let rankType = dic["type"] {
                let vm = YXHKADRViewModel.init(type: rankType)
                let vc = YXHKADRViewController.instantiate(withViewModel: vm, andServices: vm.services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.dividends.url) { (url, value, context) -> UIViewController? in
            if let dic = context as? [String : Any] {
                
                let market: String = dic["market"] as? String ?? ""
                let selectYearIndex: Int = dic["selectYearIndex"] as? Int ?? 0
                guard let model: [YXDividendsYears] = dic["model"] as? [YXDividendsYears] else { return nil }
                
                let vm = YXDividendsViewModel.init(rankModels: model, market: market,selectYearIndex:selectYearIndex)
                let vc = YXDividendsViewController.instantiate(withViewModel: vm, andServices: vm.services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 热门行业
        navigator.register(YXModulePaths.hotIndustryList.url) { (url, value, context) -> UIViewController? in
            
            if let dic = context as? [String : Any], let market = dic["market"] as? String, let rankCode = dic["rankCode"] as? String {
                let vc = YXHotIndustryViewController()
                vc.viewModel.navigator = navigator
                vc.viewModel.market = market
                vc.viewModel.rankCode = rankCode
                if let title = dic["title"] as? String {
                    vc.viewModel.title = title
                }
                
                if let showSearch = dic["showSearch"] as? Bool {
                    vc.viewModel.showSearch = showSearch
                }
                return vc
            }
            return nil
        }
        

        navigator.register(YXModulePaths.optionalListLand.url) { (url, values, context) -> UIViewController? in
            
            if
                let dic = context as? [String : Any],
                let secuGroup = dic["secuGroup"] as? YXSecuGroup,
                let dataSource = dic["dataSource"] as? [YXV2Quote],
                let type = dic["quoteType"] as? YXStockRankSortType,
                let sortState = dic["sortState"] as? YXSortState
            {
                let viewModel = YXOptionalListLandViewModel()
                viewModel.dataSource.accept(dataSource)
                viewModel.secuGroup.accept(secuGroup)
                viewModel.sortState.accept(sortState)
                viewModel.quoteType.accept(type)
                
                let vc = YXOptionalListLandVC.instantiate(withViewModel: viewModel, andServices: services, andNavigator: navigator)
                return vc
            }

            return nil
        }
        // 窝轮牛熊和牛熊街货
        navigator.register(YXModulePaths.warrantsAndStreet.url) { (url, value, context) -> UIViewController? in
            let vc = YXWarrantsMainViewController()
            vc.viewModel.navigator = navigator
            
            if let dic = context as? [String : Any],
                let change = dic["change"] as? Int64,
                let roc = dic["roc"] as? Int32,
                let now = dic["now"] as? Int64,
                let priceBase = dic["priceBase"] as? UInt32 {
            
                vc.warrantsViewController.viewModel.change = change
                vc.warrantsViewController.viewModel.roc = roc
                vc.warrantsViewController.viewModel.now = now
                vc.warrantsViewController.viewModel.priceBase = priceBase
                vc.warrantsViewController.viewModel.pushVC = dic["pushVC"] as? YXStockWarrantsViewController
            }
            if let dic = context as? [String : Any],
                let name = dic["name"] as? String?,
                let symbol = dic["symbol"] as? String,
                let market = dic["market"] as? String {
                
                let warrantType = (dic["warrantType"] as? YXStockWarrantsType) ?? .bullBear
                
                if let bullBeartype = dic["bullBeartype"] as? YXBullAndBellType {
                    vc.warrantsViewController.viewModel.type = bullBeartype
                }
                
                vc.warrantsViewController.viewModel.warrantType = warrantType
                vc.warrantsViewController.viewModel.name = name
                vc.warrantsViewController.viewModel.symbol = symbol
                vc.warrantsViewController.viewModel.market = market
                vc.warrantsViewController.isHideLZBButton = false
                vc.warrantsViewController.updateHeaderViewConstraint()
                vc.warrantsViewController.updateHeaderViewStock()
                
                vc.inlineWarrantViewController.viewModel.name = name
                vc.inlineWarrantViewController.viewModel.symbol = symbol
                vc.inlineWarrantViewController.viewModel.market = market
                vc.inlineWarrantViewController.updateHeaderViewConstraint()
                vc.inlineWarrantViewController.updateHeaderViewStock()
                
                if let prcLower = dic["prcLower"] as? String, let prcUpper = dic["prcUpper"] as? String, let bullBearType = dic["bullBearType"] as? YXBullAndBellType {
                    vc.warrantsViewController.setPrcData(low: prcLower, up: prcUpper, type: bullBearType)
                }else {
                    vc.warrantsViewController.loadNewData()
                }
                
                if let isFromFundFlow = dic["isFromFundFlow"] as? Bool {
                    vc.warrantsViewController.viewModel.isFromFundFlow = isFromFundFlow
                }
                
                vc.warrantsStreetViewModel.market = market
                vc.warrantsStreetViewModel.code = symbol
                vc.warrantsStreetViewModel.name = name ?? ""
                //vc.warrantStreetViewController.updateHeaderView()
            }
            
            if let dic = context as? [String : Any], let tabIndex = dic["tabIndex"] as? Int, tabIndex == 1 {
                vc.selectedTab = 1
            }
            
            return vc
        }
        
        // 交易更多
        navigator.register(YXModulePaths.tradeMore.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXTradeMoreViewModel> {
                let vc = YXTradeMoreViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }


        //筹码详情
        navigator.register(YXModulePaths.chipDetail.url) { (url, values, context) -> UIViewController? in
            if let viewModel = context as? YXStockChipDetailViewModel {

                let vc = YXStockChipDetailViewController()
                vc.viewModel = viewModel
                vc.viewModel.navigator = navigator
                return vc
            }
            return nil
        }
        
        //可融资列表
        navigator.register(YXModulePaths.financingList.url) { (url, values, context) -> UIViewController? in
            let vc = YXFinancingViewController()
            if let dic = context as? [String : Any] {
                if let market = dic["market"] as? YXMarketType {
                    vc.viewModel.market = market
                }
                if let rankType = dic["rankType"] as? YXRankType {
                    vc.viewModel.rankType = rankType
                }
                if let uiStyle = dic["uiStyle"] as? YXFinancingUIStyle {
                    vc.viewModel.uiStyle = uiStyle
                }
                if let block = dic["didSelectedSearchItemBlock"] as? ((YXSearchItem) -> Void) {
                    vc.didSelectedSearchResultItem = block
                }
            }
            vc.viewModel.navigator = navigator
            return vc
        }


        //筹码详情
        navigator.register(YXModulePaths.filterIndustry.url) { (url, values, context) -> UIViewController? in
            if let viewModel = context as? YXStockFilterIndustryViewModel {

                let vc = YXStockFilterIndustryViewController()
                vc.viewModel = viewModel
                vc.viewModel.navigator = navigator
                return vc
            }
            return nil
        }

        //K线对比
        navigator.register(YXModulePaths.klineVS.url) { (url, value, context) -> UIViewController? in

            if let dic = context as? [String : Any],
               let name = dic["name"] as? String?,
               let symbol = dic["symbol"] as? String,
               let market = dic["market"] as? String {
                
//                let todayOrderViewModel = YXTodayOrderViewModel(services: navigator, params: [:])
//                return todayOrderViewModel
                let searchViewModel = YXVSSearchViewModel(services: navigator, params: dic)
                let vc = YXVSSearchViewController(viewModel: searchViewModel)
//                vc.viewModel.addDefaultItem(name: name, symbol: symbol, market: market)

                /*
                 YXVSSearchViewModel *searchViewModel = [[YXVSSearchViewModel alloc] initWithServices:self.viewModel.services params:@{@"name" : self.viewModel.name, @"symbol" : self.viewModel.symbol, @"market" : self.viewModel.market, @"isFromStockDetail" : @(YES), @"type1" : @(self.viewModel.quotaModel.type1.value)}];
                 [self.viewModel.services pushViewModel:searchViewModel animated:YES];
                 **/
                
                return vc
            }
            return nil
        }

        navigator.register(YXModulePaths.klineVSLand.url) { (url, value, context) -> UIViewController? in
            let vm = YXKlineVSLandViewModel(services: navigator, params: [:])
            let vc = YXKlineVSLandVC(viewModel: vm)
//            vc.viewModel.navigator = navigator

            /*
             YXKlineVSLandViewModel *searchViewModel = [[YXKlineVSLandViewModel alloc] initWithServices:self.viewModel.services params:nil];
             [self.viewModel.services pushViewModel:searchViewModel animated:YES];
             **/
            
            return vc
        }
        
        //盘前盘后排行
        navigator.register(YXModulePaths.preAfterRank.url) { (url, values, context) -> UIViewController? in
            return YXPreAfterRankViewController()
        }
        
//        navigator.register(YXModulePaths.shortCuts.url) { (url, values, context) -> UIViewController? in
//            return YXShortCutsViewController()
//        }
        
        navigator.register(YXModulePaths.etfrank.url) { (url, values, context) -> UIViewController? in
            let vc = YXEFTRankViewController()
            vc.viewModel.navigator = navigator
            return vc
        }
        
        //注册页
        navigator.register(YXModulePaths.signUp.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXSignUpViewModel> {
                let vc = YXSignUpViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.verifyChange.url) { (url, values, context) -> UIViewController? in
            
            if let navigatable = context as? YXNavigatable<YXChangeVertifViewModel> {
                let vc = YXChangeVerificationVC.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        // 绑定邮箱
        navigator.register(YXModulePaths.bindEmail.url) { (url, values, context) -> UIViewController? in
            
            if let navigatable = context as? YXNavigatable<YXChangeEmailViewModel> {
                let vc = YXBindEmailViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        //设置交易密码
        navigator.register(YXModulePaths.setTradePwd.url) { (url, values, context) -> UIViewController? in
            
            if let navigatable = context as? YXNavigatable<YXSetTradePwdViewModel> {
                let vc = YXSetTradePwdViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        
        // 网页浏览(顶部带行情）
        navigator.register(YXModulePaths.quoteWebView.url) { (url, values, context) -> UIViewController? in
            if let viewModel = context as? YXWebViewModel {
                let vc = YXQuoteWebVC.instantiate(withViewModel: viewModel, andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        //NZ券商设置页
        navigator.register(YXModulePaths.nzSettings.url) { (url, values, context) -> UIViewController? in
            let vc = YXBrokerSettingsViewController()
            vc.viewModel = YXBrokerSetViewModel()
            vc.viewModel.navigator = navigator
            return vc
        }
        //IB账户信息详情
        navigator.register(YXModulePaths.IBAccount.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXIBAcountViewModel> {
                let vc = YXIBAcountViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.brokerLogin.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXBrokerLoginViewModel> {
                let vc = YXBrokerLoginViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        

        //课程详情
        navigator.register(YXModulePaths.courseDetail.url) { (url, values, context) -> UIViewController? in
            var courseId: String?
            var lessonId: String?
            var isUserPayed = true
            if let dict = context as? [String : Any] {
                if let id = dict["courseId"] as? String {
                    courseId = id
                }
                if let id = dict["lessonId"] as? String {
                    lessonId = id
                }
                if let payed = dict["isUserPayed"] as? Bool {
                    isUserPayed = payed
                }
            }
            let vc = YXCourseDetailViewController()
            vc.viewModel.courseId = courseId
            vc.viewModel.isUserPayed = isUserPayed
            vc.viewModel.lessonId = lessonId
            return vc
        }
        
        //课程列表
        navigator.register(YXModulePaths.courseList.url) { (url, values, context) -> UIViewController? in
            let vc = YXCourseViewController()
            return vc
        }
        
        //投教关注的用户主页
        navigator.register(YXModulePaths.kolHome.url) { (url, values, context) -> UIViewController? in
            var kolId: String?
            if let dict = context as? [String : Any] {
                if let id = dict["kolId"] as? String {
                    kolId = id
                }
            }
            let vc = YXKOLHomeViewController()
            vc.kolId = kolId
            return vc
        }
        
        navigator.register(YXModulePaths.doubleLoginSet.url){ (url ,values, context) ->UIViewController? in
            if let navigatable = context as? YXNavigatable<YXDoubleLoginSetViewModel> {
                let vc = YXDoubleLoginAuthSetVC.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }
        
        navigator.register(YXModulePaths.doubelAuthLogin.url){ (url ,values, context) ->UIViewController? in
            if let navigatable = context as? YXNavigatable<YXDoubleAuthLoginViewModel> {
                let vc = YXDoubleAuthLoginViewController.instantiate(withViewModel: navigatable.viewModel , andServices: services, andNavigator: navigator)
                return vc
            }
            return nil
        }

        // 资产更多
        navigator.register(YXModulePaths.moduleMore.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXModuleMoreViewModel> {
                let vc = YXModuleMoreViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                vc.viewModel.navigator = navigator
                return vc
            }

            return nil
        }
        
        //短视频播放
        navigator.register(YXModulePaths.kolShortVideoPlay.url) { (url, values, context) -> UIViewController? in
            var videoId = ""
            if let dict = context as? [String : Any], let id = dict["videoId"] as? String {
                videoId = id
            }
            let vc = YXShortVideoMainViewController()
            vc.businessType = .detail(id: videoId)
            vc.hidesBottomBarWhenPushed = true
            return vc
        }

        //资产详情
        navigator.register(YXModulePaths.myAssetsDetail.url) { (url, values, context) -> UIViewController? in
            if let navigatable = context as? YXNavigatable<YXMyAssetsDetailViewModel> {
                let vc = YXMyAssetsDetailViewController.instantiate(withViewModel: navigatable.viewModel, andServices: services, andNavigator: navigator)
                vc.viewModel.navigator = navigator
                return vc
            }

            return nil
        }

    }
}
