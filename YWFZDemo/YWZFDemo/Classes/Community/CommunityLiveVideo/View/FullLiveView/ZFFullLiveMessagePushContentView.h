//
//  ZFFullLiveMessagePushContentView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFZegoMessageInfo.h"
#import "ZFVideoLiveCommentUtils.h"
NS_ASSUME_NONNULL_BEGIN
/// 直播聊天推流加购、下单、支付提示显示区域

@interface ZFFullLiveMessagePushContentView : UIView

- (void)pushMessageInfo:(ZFZegoMessageInfo *)messageInfo;

@property (nonatomic, assign) BOOL              isNoNeedTimer;

@end

NS_ASSUME_NONNULL_END
