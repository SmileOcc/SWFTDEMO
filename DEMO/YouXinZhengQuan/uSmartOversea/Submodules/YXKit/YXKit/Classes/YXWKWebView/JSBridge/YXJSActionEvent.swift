//
//  YXJSActionEvent.swift
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2018/11/21.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

import Foundation

/**==============================================================================================================
 *  所有的Event 当执行失败的时候都有 onErrorCallback调用 并带json参数 paramsJsonValue {"code":"400", "desc":"错误描述"}
 *===============================================================================================================*/

let JS_ACTION_GET_PREFIX = "get_";
let JS_ACTION_COMMAND_PREFIX = "command_";

//MARK: - get_
/**
 * 跳转到native模块
 * paramsJsonValue 如：{"url":"yxzq_goto://stock_quote?market=sh&code=600837"}
 */
let GOTO_NATIVE_MOUDLE = "goto_native_module";


/**
 * 获取用户账户信息
 * 成功：data:{"userId":"112233445", "userName":"xxxxx", "userToken":"xxxx-xxxx-xxxx-xxx","phoneNum":"18877776666","trade_Token":"xxxx-xxxx-xxxx-xxx"}
 */
let GET_USER_INFO = JS_ACTION_GET_PREFIX + "user_info";

/**
 * 获取交易账户信息
 * 成功：data: {"tradeAccount":"22335566", "tradePassword":"sjdfkjeo6732##@#"}
 */
let GET_TRADE_ACCOUNT_INFO = JS_ACTION_GET_PREFIX + "trade_account_info";

/**
 * 获取设备信息
 * 成功: data:{"deviceId":"xxxxxx","platform":"android","appId":"com.yxzq.stock"
 *                                    "appVersion":"1.0.0.0", "systemVersion":"5.1", "channel":"baidu",
 *                                    "networkType":"4g","sp":"中国移动"}
 *
 */
let GET_DEVICE_INFO = JS_ACTION_GET_PREFIX + "device_info";

/**
 * 获取位置信息
 * 成功：data:{"longitude":"112.00", "latitude":"221.00"}
 */
let GET_LOCATION = JS_ACTION_GET_PREFIX + "location";

/**
 * 获取全部自选
 * data:[{"stockMarket":"hk","stockCode":"00700"},{"stockMarket":"sh","stockCode":"600837"},......]}
 */
let GET_ALL_OPTIONAL_STOCK = JS_ACTION_GET_PREFIX + "all_optional_stock";

/**
 * 获取身份证人物照片
 * {"code":0, "desc":"success"，"data": 图片base64编码的String}
 */
let GET_IDCARD_IMAGE_SIDE_FRONT = JS_ACTION_GET_PREFIX + "idcard_image_side_front"

/**
 * 获取身份证国徽照片
 * {"code":0, "desc":"success"，"data": 图片base64编码的String}
 */
let GET_IDCARD_IMAGE_SIDE_BACK = JS_ACTION_GET_PREFIX + "idcard_image_side_back"

/**
 * 获取活体识别数据
 * {"code":0,"desc":"success"，"data": {"sign": "sign str","sign_version": "sign_version str","biz_token":"token str","meglive_data":"meglive_data str"}}
 */
let GET_MEGLIVE_DATA = JS_ACTION_GET_PREFIX + "meglive_data"

/**
 * 获取人脸识别数据（无源识别）
 * {"code":0,"desc":"success"，"data": {"sign": "sign str","sign_version": "sign_version str","biz_token":"token str","meglive_data":"meglive_data str"}}
 */
let GET_PASSIVE_MEGLIVE_DATA = JS_ACTION_GET_PREFIX + "passive_meglive_data"

/**
 * 获取图片，从相机或者相册
 * {"code":0, "desc":"success"，"data": 图片base64编码的String}
 */
let GET_IMAGE_FROM_CAMERA_OR_ALBUM = JS_ACTION_GET_PREFIX + "image_from_camera_or_album"

/**
 * 获取图片或文件，从相机，或相册或文件管理器
 * {"code":0, "desc":"success"，"data": {"fileData": 图片或文件的base64编码的String, "fileName":""}}
 */
let GET_IMAGE_OR_FILE_FROM_CAMERA_OR_ALBUM_OR_FILEMANAGER = JS_ACTION_GET_PREFIX + "image_or_file_from_camera_or_album_or_filemanager"

/**
 * 获取图片，从相机或者相册
 * {"code":0, "desc":"success"，"data": {"status" : "true"}}
 */
let GET_NOTIFICATION_STATUS = JS_ACTION_GET_PREFIX + "notification_status"

/**
 * 获取当前App链接环境
 * {"code":0, "desc":"success"，"data": {"value" : "dev"}}
 */
let GET_APP_CONNECT_ENVIRONMENT = JS_ACTION_GET_PREFIX + "app_connect_environment"

/**
 * 获取Http请求签名
 * {"code":0, "desc":"success"，"data": {"xToken" : "xxxxx"}}
 */
let GET_HTTP_SIGN = JS_ACTION_GET_PREFIX + "http_sign"

/**
 * 是否支持NFC识别
 * {"code":0, "desc":"success"，"data": {"availability" : true, "is_open":false}}
 */
let GET_NFC_RECOGNITION_AVAILABILITY = JS_ACTION_GET_PREFIX + "nfc_recognition_availability"

/**
 *  获取自选股
 */
let GET_SUBSCRIBED_STOCK = JS_ACTION_GET_PREFIX + "subscribed_stock"


//MARK: - command_

/**
 * 注销用户账户
 */
let COMMAND_LOGOUT_USER_ACCOUNT = JS_ACTION_COMMAND_PREFIX + "logout_user_account";

/**
 * 注销交易账户
 */
let COMMAND_LOGOUT_TRADE_ACCOUNT = JS_ACTION_COMMAND_PREFIX + "logout_trade_account";

/**
 * 调用原生分享接口
 * paramsJsonValue {"title":"分享title", "desc":"分享内容描述", "pageUrl":"分享页面url", "thumbUrl":"小图片url"}
 */
let COMMAND_SHARE = JS_ACTION_COMMAND_PREFIX + "share";

/**
* 查询第三方客户端安装状态
* paramsJsonValue {"clients":["wechat", "facebook", "twitter", "messenger"]}
*/
let COMMAND_CHECK_CLIENT_INSTALL_STATUS = JS_ACTION_COMMAND_PREFIX + "check_client_install_status"

/**
 * 关闭当前webview
 */
let COMMAND_CLOSE_WEBVIEW = JS_ACTION_COMMAND_PREFIX + "close_webview";

/**
 * 当前webview的栈页面返回，如果栈中没有页面了则关闭webview所在页面
 */
let COMMAND_GO_BACK = JS_ACTION_COMMAND_PREFIX + "go_back";

/**
 * 隐藏当前webview的titlebar
 */
let COMMAND_HIDE_TITLEBAR = JS_ACTION_COMMAND_PREFIX + "hide_titlebar";

/**
 * 显示当前webview的titlebar
 */
let COMMAND_SHOW_TITLEBAR = JS_ACTION_COMMAND_PREFIX + "show_titlebar";

/**
 * 设置当前webview的title
 * paramsJsonValue {"title":"title文字"}
 */
let COMMAND_SET_TITLE = JS_ACTION_COMMAND_PREFIX + "set_title";


/**
 * 监听客户端网络
 * callback
 * 成功：data:{"networkType":"wifi/gprs/none"}
 */
let COMMAND_WATCH_NETWORK = JS_ACTION_COMMAND_PREFIX + "watch_network";

/**
 * 监听当前页面前后台状态
 * 成功："data":{"status": "visible/invisible"}
 */
let COMMAND_WATCH_ACTVITY_STATUS = JS_ACTION_COMMAND_PREFIX + "watch_activity_status";

/**
 * 添加一个自选股
 * paramsJsonValue {"stock_market":"hk", "stock_code":"00700"}
 */
let COMMAND_ADD_OPTIONAL_STOCK_EVENT = JS_ACTION_COMMAND_PREFIX + "add_optional_stock";

/**
 * 复制到剪贴板
 * paramsJsonValue {"content":"需要复制的文字"}
 */
let COMMAND_COPY_TO_PASTEBOARD = JS_ACTION_COMMAND_PREFIX + "copy_to_pasteboard";

/**
 * 用户登录
 */
let COMMAND_USER_LOGIN = JS_ACTION_COMMAND_PREFIX + "user_login";

/**
 * 绑定手机
 */
let COMMAND_BIND_MOBILE_PHONE = JS_ACTION_COMMAND_PREFIX + "bind_mobile_phone";

/**
 * 请求开启通知
 */
let COMMAND_OPEN_NOTIFICATION = JS_ACTION_COMMAND_PREFIX + "open_notification";

/**
 * 交易登录
 */
let COMMAND_TRADE_LOGIN = JS_ACTION_COMMAND_PREFIX + "trade_login";

/**
 * 设置title Button
 */
let COMMAND_SET_TITLEBAR_BUTTON = JS_ACTION_COMMAND_PREFIX + "set_titlebar_button";

/**
 * web页面截屏并分享
 */
let COMMAND_SCREENSHOT_SHARE_SAVE = JS_ACTION_COMMAND_PREFIX + "screenshot_share_save";

/**
 * 跳转联系客服
 */
let COMMAND_CONTACT_SERVICE = JS_ACTION_COMMAND_PREFIX + "contact_service";

/**
 * 保存图片
 */
let COMMAND_SAVE_PICTURE = JS_ACTION_COMMAND_PREFIX + "save_picture";

/**
 * 設置當前消息均為已讀狀態
 */
let COMMAND_ALL_MSG_READ = JS_ACTION_COMMAND_PREFIX + "all_msg_read";

/**
 * token失效
 */
let COMMAND_TOKEN_FAILURE = JS_ACTION_COMMAND_PREFIX + "token_failure";

/**
 * 美股行情权限声明的确认
 */
let COMMAND_CONFIRM_US_QUOTE_STATEMENT = JS_ACTION_COMMAND_PREFIX + "confirm_us_quote_statement";

/**
 * web端ELK日志上传
 */
let COMMAND_UPLOAD_ELK_LOG = JS_ACTION_COMMAND_PREFIX + "upload_elk_log";

/**
 * 设置是否允许下拉刷新
 */
let COMMAND_ENABLE_PULL_REFRESH = JS_ACTION_COMMAND_PREFIX + "enable_pull_refresh";

/**
* 刷新用户信息
*/
let COMMAND_REFRESH_USER_INFO = JS_ACTION_COMMAND_PREFIX + "refresh_user_info"

/**
* 打开NFC识别护照
*/
let COMMAND_NFC_RECOGNIZE_PASSPORT = JS_ACTION_COMMAND_PREFIX + "nfc_recognize_passport"

/**
* appsflyer事件上传
*/
let COMMAND_UPLOAD_APPSFLYER_EVENT = JS_ACTION_COMMAND_PREFIX + "upload_appsflyer_event"

/**
* 购买商品
*/
let COMMAND_BUY_IN_APP_PRODUCT = JS_ACTION_COMMAND_PREFIX + "buy_in_app_product"

/**
* 通知App商品消耗结果
*/
let COMMAND_PRODUCT_CONSUME_RESULT = JS_ACTION_COMMAND_PREFIX + "product_consume_result"

/**
 * 设置屏幕方向
 */
let COMMAND_SET_SCREEN_ORIENTATION = JS_ACTION_COMMAND_PREFIX + "set_screen_orientation";

/**
 * 开启Jumio识别
 */
let COMMAND_JUMIO_RECOGNIZE = JS_ACTION_COMMAND_PREFIX + "jumio_recognize";
/**
 * 显示浮窗音频
 */
let COMMAND_SHOW_FLOATINGVIEW = JS_ACTION_COMMAND_PREFIX + "show_floatingView";

/**
 * 关闭浮窗音频
 */
let COMMAND_DISMISS_FLOATINGVIEW = JS_ACTION_COMMAND_PREFIX + "dismiss_floatingView";

/**
 *  检查股票是否是自选股
 */
let COMMAND_CHECK_OPTIONAL_STOCK = JS_ACTION_COMMAND_PREFIX + "check_optional_stock";

/**
 *  添加自选股
 */
let COMMAND_ADD_OPTIONAL_STOCK = JS_ACTION_COMMAND_PREFIX + "add_optional_stock";

/**
 *  删除自选股
 */
let COMMAND_REMOVE_OPTIONAL_STOCK = JS_ACTION_COMMAND_PREFIX + "remove_optional_stock";

/**
 *  创建讨论
 */
let COMMAND_CREATE_POST = JS_ACTION_COMMAND_PREFIX + "create_post";

/**
 *  创建评论回复
 */
let COMMAND_REPLY_COMMENT = JS_ACTION_COMMAND_PREFIX + "reply_comment";

/**
 *  绑定邮箱
 */
let COMMAND_BIND_EMAIL = JS_ACTION_COMMAND_PREFIX + "bind_email";
/**
 *  页面刷新
 */
let COMMAND_REFRESH = JS_ACTION_COMMAND_PREFIX + "refresh_data";
/**
 *  券商登陆
 */
let COMMAND_LOGIN_BROKER = JS_ACTION_COMMAND_PREFIX + "broker_login";
/**
 *  设置交易密码
 */
let COMMAND_SET_TRADE_PASSWORD = JS_ACTION_COMMAND_PREFIX + "set_trade_password";

/**
 * 搜索股票
 */
let COMMAND_SEARCH = JS_ACTION_COMMAND_PREFIX + "search";

/**
 * 跳转Beerich
 */
let COMMAND_GOTO_BEERICH = JS_ACTION_COMMAND_PREFIX + "goto_beerich";

/**
 * 问股WEB选择地区
 */
let COMMAND_ASK_STOCK_LOCATION = JS_ACTION_COMMAND_PREFIX + "ask_stock_location";

/**
 * app open url
 */
let COMMAND_APP_OPEN_URL = JS_ACTION_COMMAND_PREFIX + "app_open_explorer";


/**
 *  获取Face++人脸识别校验返回的状态以及文件解密key
 */
let COMMAND_FACEID_VERIFY_RESULT = JS_ACTION_COMMAND_PREFIX + "faceid_verify_result"

/**
 *  调起Onfido SDK, 返回token
 */
let COMMAND_START_ONFIDO = JS_ACTION_COMMAND_PREFIX + "start_onfido"
