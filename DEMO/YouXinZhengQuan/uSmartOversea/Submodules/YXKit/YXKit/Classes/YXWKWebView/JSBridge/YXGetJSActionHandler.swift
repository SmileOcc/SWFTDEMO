//
//  YXGetJSActionHandler.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/11/20.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import UIKit
import WebKit

class YXGetJSActionHandler: YXBaseJSActionHandler {
    override func handlerAction(withWebview webview:WKWebView, actionEvent: String, paramsJsonValue: Dictionary<String, Any>?, successCallback: String?, errorCallback: String?) {
        super.handlerAction(withWebview: webview, actionEvent: actionEvent, paramsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
        switch actionEvent {
        case GET_USER_INFO:
            if let webview = webview as? YXWKWebView {
                webview.jsDelegate?.onGetUserInfo?(withParamsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
            }
        case GET_TRADE_ACCOUNT_INFO:
            log(.info, tag: kOther, content: "GET_TRADE_ACCOUNT_INFO")
        case GET_DEVICE_INFO:
            log(.info, tag: kOther, content: "GET_DEVICE_INFO")
        case GET_LOCATION:
            log(.info, tag: kOther, content: "GET_LOCATION")
        case GET_ALL_OPTIONAL_STOCK:
            log(.info, tag: kOther, content: "GET_ALL_OPTIONAL_STOCK")
        case GET_IDCARD_IMAGE_SIDE_FRONT:
            if let webview = webview as? YXWKWebView {
                webview.jsDelegate?.onGetIDCardImageSideFront?(withParamsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
            }
        case GET_IDCARD_IMAGE_SIDE_BACK:
            if let webview = webview as? YXWKWebView {
                webview.jsDelegate?.onGetIDCardImageSideBack?(withParamsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
            }
        case GET_MEGLIVE_DATA:
            if let webview = webview as? YXWKWebView {
                webview.jsDelegate?.onGetMegLiveData?(withParamsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
            }
        case GET_PASSIVE_MEGLIVE_DATA:
            if let webview = webview as? YXWKWebView {
                webview.jsDelegate?.onGetPassiveMegLiveData?(withParamsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
            }
        case GET_IMAGE_FROM_CAMERA_OR_ALBUM:
            if let webview = webview as? YXWKWebView {
                webview.jsDelegate?.onGetImageFromCameraOrAlbum?(withParamsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
            }
        case GET_IMAGE_OR_FILE_FROM_CAMERA_OR_ALBUM_OR_FILEMANAGER:
            if let webview = webview as? YXWKWebView {
                webview.jsDelegate?.onGetImageOrFileFromCameraOrAlbumOrFileManager?(withParamsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
            }
        case GET_NOTIFICATION_STATUS:
            if let webview = webview as? YXWKWebView {
                webview.jsDelegate?.onGetNotificationStatus?(withParamsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
            }
        case GET_APP_CONNECT_ENVIRONMENT:
            if let webview = webview as? YXWKWebView {
                webview.jsDelegate?.onGetAppConnectEnvironment?(withParamsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
            }
        case GET_HTTP_SIGN:
            if let webview = webview as? YXWKWebView {
                webview.jsDelegate?.onGetHttpSign?(withParamsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
            }
        case GET_NFC_RECOGNITION_AVAILABILITY:
            if let webview = webview as? YXWKWebView {
                webview.jsDelegate?.onGetNFCRecognitionAvailability?(withParamsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
            }
        case GET_SUBSCRIBED_STOCK:
            if let webview = webview as? YXWKWebView {
                webview.jsDelegate?.onGetSubscribedStock?(withParamsJsonValue: paramsJsonValue, successCallback: successCallback, errorCallback: errorCallback)
            }
        default:
            log(.error, tag: kOther, content: "no matched get action")
        }
    }
}
