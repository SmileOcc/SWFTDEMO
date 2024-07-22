//
//  ZFAccountHeaderCReusableView.h
//  ZZZZZ
//
//  Created by YW on 2019/6/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  个人中心头部视图

#import <UIKit/UIKit.h>

@class ZFMyOrderListTopMessageView;

typedef NS_ENUM(NSInteger, ZFNewAccountInfoStatusType) {
    ZFNewAccountInfoStatusTypeLogin = 0,
    ZFNewAccountInfoStatusTypeUnLogin,
    ZFNewAccountInfoStatusTypeNormal,
    ZFNewAccountInfoStatusNeedReload
};

typedef void(^HeaderPushOpenBlock)(void);
typedef void(^HeaderPushCloseBlock)(void);

@protocol ZFAccountHeaderCReusableViewDelegate <NSObject>

- (void)ZFAccountHeaderCReusableViewDidClickLogin;

- (void)ZFAccountHeaderCReusableViewDidClickZ_ME;

- (void)ZFAccountHeaderCReusableViewDidClickEditProfile;

- (void)ZFAccountHeaderCReusableViewDidClickChangeHeadPhoto;

@end

@interface ZFAccountHeaderCReusableView : UICollectionReusableView

//显示状态类型
@property (nonatomic, assign) ZFNewAccountInfoStatusType   showType;

//头像
@property (nonatomic, strong) UIImageView           *avatorView;

@property (nonatomic, weak) id<ZFAccountHeaderCReusableViewDelegate>delegate;

@property (nonatomic, copy) HeaderPushOpenBlock openBlock;

@property (nonatomic, copy) HeaderPushCloseBlock closeBlock;

@property (nonatomic, strong) ZFMyOrderListTopMessageView   *topMessageView;

///修改头部皮肤
- (void)changeAccountHeadInfoViewSkin;

@end
