//
//  ZFHomePageViewController.h
//  ZZZZZ
//
//  Created by YW on 10/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "WMPageController.h"
#import "ZFOrderPayTools.h"

@interface ZFHomePageViewController : WMPageController

/**
 * 推送跳转到具体频道页
 */
- (void)scrollToTargetVCWithChannelID:(NSString *)channelID;

// 供昼夜弹框展示使用
@property (nonatomic, strong) ZFOrderPayTools *homePaytools;

@end
