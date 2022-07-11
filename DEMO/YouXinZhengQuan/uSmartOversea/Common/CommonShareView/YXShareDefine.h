//
//  YXShareDefine.h
//  YouXinZhengQuan
//
//  Created by youxin on 2021/9/23.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#ifndef YXShareDefine_h
#define YXShareDefine_h

typedef NS_ENUM(NSUInteger, YXSharePlatform) {
    YXSharePlatformUnKnown,
    YXSharePlatformWhatsApp,
    YXSharePlatformFacebook,
    YXSharePlatformWechat,
    YXSharePlatformWechatFriend,
    YXSharePlatformFacebookMessenger,
    YXSharePlatformTwitter,
    YXSharePlatformSms,
    YXSharePlatformAliSocial,
    YXSharePlatformDingTalk,
    YXSharePlatformSave,
    YXSharePlatformCopy,
    YXSharePlatformMore,
    YXSharePlatformWXMiniProgram,
    YXSharePlatformQQ,
    YXSharePlatformSinaweibo,
    YXSharePlatformUSmartSocial,
    YXSharePlatformInstagram,
    YXSharePlatformLine,
    YXSharePlatformTelegram,
};


typedef NS_ENUM(NSUInteger, YXShareType) {
    YXShareTypeLink,            //链接分享
    YXShareTypeImage,           //图片分享
};

typedef NS_ENUM(NSUInteger, YXShareImageType) {
    YXShareImageTypeDefault,         //默认样式
    YXShareImageTypeStockDetail,     //个股详情
    YXShareImageTypeFastNews,        //快讯
    YXShareImageTypeDiscuss,         //讨论
    YXShareImageTypeAccount,         //账户持仓
    YXShareImageTypeWebScreen,       //网页全屏视图, 网页传过来的图片可能已经拼接过二维码
};

#endif /* YXShareDefine_h */
