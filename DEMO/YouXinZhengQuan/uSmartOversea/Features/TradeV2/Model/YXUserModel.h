//
//  YXUserModel.h
//  YouXinZhengQuan
//
//  Created by JC_Mac on 2018/10/22.
//  Copyright © 2018 RenRenDai. All rights reserved.
// 用户模型

#import "YXModel.h"
//
//typedef NS_OPTIONS(NSUInteger, YXLoginBindType) {
//    YXLoginBindTypePhone   =  1 << 0,
//    YXLoginBindTypeWechat  =  1 << 1,
//    YXLoginBindTypeWeibo    =  1 << 2,
//    YXLoginBindTypeAli      =  1 << 9,
//    YXLoginBindTypeApple    =  1 << 10,
//};
//
typedef NS_OPTIONS(NSUInteger, YXExtendBindType) {
    YXExtendBindTypePwd           =  1 << 0,   //密码
    YXExtendBindTypeAccess        =  1 << 1,   //行情权限
    YXExtendBindTypeDerivatives   =  1 << 2,   //衍生品
    YXExtendBindTypeBondSigned    =  1 << 3,   //债券签名
    YXExtendBindTypeFund          =  1 << 4,   //基金
    YXExtendBindTypePrivately     =  1 << 5,   //暗盘
};
//
//typedef NS_OPTIONS(NSUInteger, YXGrayStatusType) {
//    YXGrayStatusTypeFund      =  1 << 0,   //基金
//    YXGrayStatusTypePrivately =  1 << 1,   //暗盘
//    YXGrayStatusTypeBond      =  1 << 2,   //债券
//    YXGrayStatusTypeMargin    =  1 << 6,   //保证金账户
//};
//
//
//
//typedef NS_OPTIONS(NSUInteger, YXMarketBitType) {
//    YXMarketBitTypeHK         =  1 << 0,   //港股
//    YXMarketBitTypeUS         =  1 << 1,   //美股
//    YXMarketBitTypeHS         =  1 << 2,   //A股通
//};
//
//typedef NS_ENUM(NSInteger, YXIdentifyType) {
//    YXIdentifyTypeMainLandId            = 1,     //大陆身份证
//    YXIdentifyTypeHKId                  = 2,     //香港身份证
//    YXIdentifyTypePassport              = 3,     //护照
//    YXIdentifyTypeHKPermanentResident   = 4,     //香港永久居民身份证
//};
//
//NS_ASSUME_NONNULL_BEGIN
//
//@class YXUserQuotationModel;
//@interface userQuotationVOList : YXModel
//
//@property (nonatomic, assign) NSInteger attribution;
//@property (nonatomic, assign) NSInteger location; //1.国内 2境外
//@property (nonatomic, assign) NSInteger realAttribution; //1大陆 2香港
//@property (nonatomic, strong) YXUserQuotationModel *hk;
//@property (nonatomic, strong) YXUserQuotationModel *usa;
//@property (nonatomic, strong) YXUserQuotationModel *zht;
//
//@end
//
//@interface YXUserModel : YXModel
//
//@property (nonatomic, copy) NSString *phoneNumber; //手机号码
//@property (nonatomic, copy) NSString *email; //邮箱
//@property (nonatomic, copy) NSString *areaCode; //区号
//@property (nonatomic, copy) NSString *nickname;
//@property (nonatomic, copy) NSString *avatar;
//@property (nonatomic, assign) BOOL tradePassword; //是否设置过交易密码
//@property (nonatomic, assign) BOOL openedAccount; //是否开户
//@property (nonatomic, assign) NSInteger fundAccount; //资金账号
//@property (nonatomic, assign) BOOL finishedAmount; //是否入金
//@property (nonatomic, copy) NSString *invitationCode;  //邀请码
//@property (nonatomic, copy) NSString *clientId;  //客户号
//@property (nonatomic, assign) YXLoginBindType thirdBindBit; //绑定位
//@property (nonatomic, assign) YXExtendBindType extendStatusBit; //绑定位
//@property (nonatomic, assign) YXGrayStatusType grayStatusBit; //灰度权限
//@property (nonatomic, assign) YXMarketBitType marketBit; //交易市场权限
//@property (nonatomic, strong) userQuotationVOList *userQuotationVOList; //行情权限
//@property (nonatomic, assign) NSInteger majorStatus; // 专业投资者 PRO 标签
//@property (nonatomic, assign) NSInteger userRoleType; //1, "普通账户" 2, "高级账户-大陆" 3, "高级账户-香港"
//@property (nonatomic, assign) NSInteger languageCn;
//@property (nonatomic, assign) NSInteger languageHk;
//@property (nonatomic, assign) NSInteger lineColorHk;
//@property (nonatomic, assign) NSInteger accountType;
//@property (nonatomic, assign) NSInteger identifyCountryCode;
//@property (nonatomic, assign) YXIdentifyType identifyType;
//
//@property (nonatomic, assign) BOOL orgEmailLoginFlag;  //是否是机构用户
//@property (nonatomic, assign) NSInteger orgUserStatus;  //机构用户状态  1.未提交资料 2.审核中 3.驳回待处理 4完成
//
//@property (nonatomic, copy) NSString * _Nullable token; //用户鉴权token
//@property (nonatomic, assign) UInt64 uuid;
//@property (nonatomic, assign) BOOL appfirstLogin;//是否首次登陆app
//@property (nonatomic, assign) UInt64 expiration; //token失效时间
//@property (nonatomic, strong) NSString *userAutograph;
//
//@end



//NS_ASSUME_NONNULL_END
