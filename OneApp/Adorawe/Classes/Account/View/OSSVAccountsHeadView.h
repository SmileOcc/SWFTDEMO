//
//  STLAccountHeaderView.h
// XStarlinkProject
//
//  Created by odd on 2020/8/3.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVAccountsMenuItemsModel.h"
#import "OSSVOrdersStatussModel.h"

#import "OSSVAccountsItemsView.h"
#import "STLRegisterAdvView.h"

#import "Adorawe-Swift.h"

typedef NS_ENUM(NSUInteger, AccountTypeOperate){
    AccountTypeCoupon = 0,
    AccountTypeWishlist,
    AccountTypeHelp,
//    AccountTypeMember,
//    AccountTypeCoins,
};

typedef NS_ENUM(NSUInteger, AccountBindPhoneOperate){
    AccountBindPhoneClose = 0,
    AccountBindPhoneEnterIn,
};

typedef NS_ENUM(NSUInteger, AccountServicesOperate){
//    AccountServicesHelp = 0,
    AccountServicesAddress,
    AccountServicesCurrency,
    AccountServicesLanguage,
    AccountServicesMySize,
};

typedef NS_ENUM(NSUInteger, AccountEventOperate){
    AccountEventSetting = 0,
    AccountEventMessage,
    AccountEventEditUserInfo,
    AccountEventLogin,
    AccountEventLogout,
};

typedef NS_ENUM(NSUInteger, AccountOrderOperate){
    AccountOrderUnpaid = 0,
    AccountOrderProcessing,
    AccountOrderShipped,
    AccountOrderRewiewed,
    AccountOrderAll,
};



@interface OSSVAccountsHeadView : UIView

@property (nonatomic, copy) void (^eventBlock)(AccountEventOperate event);
@property (nonatomic, copy) void (^bindPhoneBlock)(AccountBindPhoneOperate event);
@property (nonatomic, copy) void (^servicesBlock)(AccountServicesOperate service, NSString *title);
@property (nonatomic, copy) void (^typeBlock)(AccountTypeOperate type, NSString *title);
@property (nonatomic, copy) void (^orderBlock)(AccountOrderOperate type, NSString *title);
- (void)reloadUserInfo;
- (void)showHeaderRedDot;
//消息中心红点
- (void)showOrHiddenMessageDot;
- (void)updateFollowingDatas;

+ (CGFloat)topBlackBgHeight;

+ (CGFloat)accountHeaderContentH:(BOOL)showAdvbanner;

@end

