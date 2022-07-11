//
//  YXWKWebView.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/12/5.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import WebKit

@objc public protocol YXWKWebViewDelegate: AnyObject {
    // JS收到分享的命令后的回调
    //MARK: - onGet
    @objc optional func onGetIDCardImageSideFront(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetIDCardImageSideBack(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetMegLiveData(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetPassiveMegLiveData(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetImageFromCameraOrAlbum(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetImageOrFileFromCameraOrAlbumOrFileManager(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetUserInfo(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetDeviceInfo(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetAllOptionalStock(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetNotificationStatus(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetAppConnectEnvironment(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetHttpSign(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetNFCRecognitionAvailability(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onGetSubscribedStock(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)

    
    //MARK: - onCommand
    @objc optional func onCommandShare(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) -> Void
    @objc optional func onCommandCheckClientInstallStatus(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) -> Void
    @objc optional func onCommandCloseWebView(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandGoBack(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandBindMobilePhone(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandUserLogout(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandUserLogin(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandTradeLogin(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandSetTitle(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandWatchNetwork(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandDeleteOptionalStock(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandCopyToPasteboard(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandOpenNotification(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandSetTitlebarButton(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandScreenshotShareSave(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandContactService(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandSavePicture(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandTokenFailure(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandAllMsgRead(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandConfirmUSQuoteStatement(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandUploadElkLog(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandEnablePullRefresh(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandRefreshUserInfo(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandNFCRecognizePassport(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandUploadAppsflyerEvent(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandBuyInAppProductEvent(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandProductConsumeResult(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandHideTitlebar(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandShowTitlebar(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandSetScreenOrientation(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandJumioRecognize(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandShowFloatingView(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandDismissFloatingView(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandCreatePost(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandReplyComment(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandCheckOptionalStock(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandAddOptionalStock(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandRemoveOptionalStock(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandBindEmail(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandRefreshData(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandLoginBroker(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandSetTraderPassword(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandAppSearch(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandGotoBeerich(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandSetAskStockLocation(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandAppOpenUrl(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandFaceidVerifyResult(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)
    @objc optional func onCommandStartOnfido(withParamsJsonValue paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?)

}

@objc open class YXWKWebView: WKWebView {
    @objc open weak var jsDelegate: YXWKWebViewDelegate?
}
