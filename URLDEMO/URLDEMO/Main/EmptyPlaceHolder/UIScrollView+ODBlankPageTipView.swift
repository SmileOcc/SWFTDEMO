//
//  UIScrollView+ODBlankPageTipView.swift
//  URLDEMO
//
//  Created by odd on 7/16/22.
//

import UIKit

enum OBBlankPageStatus {
    case normal
    case emptyData
    case fail
    case noNetwork
}

let kNetworkConnectDefaultFailTips: String = "There is no internet connection. Please check your network."
/** 刷新提示文案 */
let kAgainRequestDefaultTipString: String  = "Loading failed, please try again later."

/** 请求失败默认提示文案 */
let kReqFailDefaultTipText: String = "Loading failed, please try again later."
/** 请求空数据默认提示文案 */
let kEmptyDataDefaultTipText: String =   "Oops,no data displayed"

let kEmptyDataDefaultRefreshButton: String  = "Retry"

extension UIScrollView {
    
    private struct OBEmptyKey {
        static var emptyDataTitle = "OBEmptyDataTitle"
        static var emptyDataSubTitle = "OBEmptyDataSubTitle"
        static var emptyDataImage = "OBEmptyDataImage"
        static var emptyDataButtonTitle = "OBEmptyDataButtonTitle"
        static var requestFailTitle = "OBRequestFailTitle"
        static var requestFailImage = "OBRequestFailImage"
        static var requestFailButtonTitle = "OBRequestFailButtonTitle"
        static var networkErrorTitle = "OBNetworkErrorTitle"
        static var networkErrorImage = "OBNetworkErrorImage"
        static var networkErrorButtonTitle = "OBNetworkErrorButtonTitle"

        static var blankActionBlock = "OBBlankActionBlock"
        static var blankPageViewCenter = "OBBlankPageViewCenter"
        static var blankPageImageTopDistance = "OBBlankPageImageTopDistance"
        static var blankPageTipViewTopDistance = "OBBlankPageTipViewTopDistance"
        static var blankPageTipViewOffsetY = "OBBlankPageTipViewOffsetY"
        static var ignoreHeaderOrFooter = "OBIgnoreHeaderOrFooter"
        static var showDropBanner = "OBShowDropBanner"

    }
    
    // ==================== 请求空数据标题 ====================

    var emptyDataTitle: String {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.emptyDataTitle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &OBEmptyKey.emptyDataTitle) as? String ?? kEmptyDataDefaultTipText)
        }
    }
    
    // ==================== 请求空数据副标题 ====================

    var emptyDataSubTitle: String {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.emptyDataSubTitle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &OBEmptyKey.emptyDataSubTitle) as? String ?? "")
        }
    }
    
    // ==================== 请求空数据图片 ====================
    var emptyDataImage: UIImage? {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.emptyDataImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &OBEmptyKey.emptyDataImage) as? UIImage ?? UIImage(named: "recently_data_bank"))
        }
    }
    
    // ==================== 空数按钮点标题 ====================
    var emptyDataButtonTitle: String {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.emptyDataButtonTitle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &OBEmptyKey.emptyDataButtonTitle) as? String ?? "")
        }
    }
    
    // ==================== 请求失败提示 ====================

    var requestFailTitle: String {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.requestFailTitle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &OBEmptyKey.requestFailTitle) as? String ?? kNetworkConnectDefaultFailTips)
        }
    }
    
    // ==================== 请求失败图片 ====================
    var requestFailImage: UIImage? {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.requestFailImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &OBEmptyKey.requestFailImage) as? UIImage ?? UIImage(named: "recently_data_bank"))
        }
    }
    
    // ==================== 请求失败按钮点标题 ====================
    var requestFailButtonTitle: String {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.requestFailButtonTitle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &OBEmptyKey.requestFailButtonTitle) as? String ?? "")
        }
    }
    
    // ==================== 网络错误提示 ====================
    var networkErrorTitle: String {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.networkErrorTitle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &OBEmptyKey.networkErrorTitle) as? String ?? kNetworkConnectDefaultFailTips)
        }
    }
    
    // ==================== 网络错误图片 ====================
    var networkErrorImage: UIImage? {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.networkErrorImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &OBEmptyKey.networkErrorImage) as? UIImage ?? UIImage(named: "recently_data_bank"))
        }
    }
    
    // ==================== 网络失败按钮点标题 ====================
    var networkErrorButtonTitle: String {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.networkErrorButtonTitle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &OBEmptyKey.networkErrorButtonTitle) as? String ?? "")
        }
    }
    
    // ==================== 网络连接按钮点击事件回调 ====================
    var blankPageActionBlock: ((OBBlankPageStatus) -> Void)? {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.blankActionBlock, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return (objc_getAssociatedObject(self, &OBEmptyKey.blankActionBlock) as? (OBBlankPageStatus) -> Void)
        }
    }
    
    // ==================== 提示View的中心位置 ====================
    var blankPageViewCenter: CGPoint {
        set {
            let centerObj = "\(newValue)"
            objc_setAssociatedObject(self, &OBEmptyKey.blankPageViewCenter, centerObj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            if let tipView = self.viewWithTag(kBlankTipViewTag) as? ODBlankPageTipView {
                tipView.center = blankPageViewCenter
            }

        }
        get {
            let centerObj = objc_getAssociatedObject(self, &OBEmptyKey.blankPageViewCenter) as? String ?? "(0,0)"
            return NSCoder.cgPoint(for: centerObj)
        }
    }
    
    // ==================== 外部可控制内容提示tipView的距离顶部距离 ====================
    var blankPageImageTopDistance: Float {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.blankPageImageTopDistance, "\(newValue)", .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        }
        get {
            let centerObj = objc_getAssociatedObject(self, &OBEmptyKey.blankPageImageTopDistance) as? String ?? "0"
            return Float(centerObj) ?? 0
        }
    }
    
    var blankPageTipViewTopDistance: Float {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.blankPageTipViewTopDistance, "\(newValue)", .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        }
        get {
            let centerObj = objc_getAssociatedObject(self, &OBEmptyKey.blankPageTipViewTopDistance) as? String ?? "0"
            return Float(centerObj) ?? 0
        }
    }
    
    // ==================== 外部可控制内容提示tipView的中心上移距离 ====================

    var blankPageTipViewOffsetY: Float {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.blankPageTipViewOffsetY, "\(newValue)", .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        }
        get {
            let centerObj = objc_getAssociatedObject(self, &OBEmptyKey.blankPageTipViewOffsetY) as? String ?? "0"
            return Float(centerObj) ?? 0
        }
    }
    
    // ==================== 是否忽略头尾 ====================

    var isIgnoreHeaderOrFooter: Bool {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.ignoreHeaderOrFooter, "\(newValue)", .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        }
        get {
            let centerObj = objc_getAssociatedObject(self, &OBEmptyKey.ignoreHeaderOrFooter) as? String ?? "0"
            return Bool(centerObj) ?? false
        }
    }
    
    // ==================== 显示全屏下拉banner ====================

    var showDropBanner: Bool {
        set {
            objc_setAssociatedObject(self, &OBEmptyKey.showDropBanner, "\(newValue)", .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        }
        get {
            let centerObj = objc_getAssociatedObject(self, &OBEmptyKey.showDropBanner) as? String ?? "0"
            return Bool(centerObj) ?? false
        }
    }
    
    //待完成
}
