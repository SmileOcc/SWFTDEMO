//
//  ZFCommunityHomeViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/7/5.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"
#import "ZFCommunityChannelModel.h"

@interface ZFCommunityHomeViewModel : BaseViewModel


//获取社区首页菜单
- (void)requestDiscoverChannelCompletion:(void (^)(ZFCommunityChannelModel *channelModel))completion;

/** 判断Follow界面是否有新内容,为了导航栏上显示message的右角图片 */
- (void)requestFollowHaveNewMessageCompletion:(void (^)(BOOL isNewMessage))completion;

@end
