//
//  ZFFullLiveLiveMessagePushView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+ZFViewCategorySet.h"
#import "ZFZegoMessageInfo.h"
NS_ASSUME_NONNULL_BEGIN

/// 直播聊天推流过来的加购、下单、支付提示
@interface ZFFullLiveLiveMessagePushView : UIView

- (void)configWithMessageInfo:(ZFZegoMessageInfo *)messageInfo;

@property (nonatomic, assign) CGFloat currentH;


/// 是否正在消失
@property (nonatomic, assign) BOOL dismissing;

- (CGFloat)configContentHeight;
@end

NS_ASSUME_NONNULL_END
