//
//  ZFGameSelectLoginView.h
//  ZZZZZ
//
//  Created by YW on 2019/6/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZFGameSelectLoginViewDelegate <NSObject>

///点击关闭按钮
- (void)ZFGameSelectLoginViewDidClickCloseButton;

///使用邮箱登录
- (void)ZFGameSelectLoginViewUseEmailLogin;

///游客登录
- (void)ZFGameSelectLoginViewGuestLogin;

@end

@interface ZFGameSelectLoginView : UIView

@property (nonatomic, weak) id<ZFGameSelectLoginViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
