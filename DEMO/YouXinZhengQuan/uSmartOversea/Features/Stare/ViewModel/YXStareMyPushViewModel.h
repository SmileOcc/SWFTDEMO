//
//  YXStareMyPushViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/6.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStareMyPushViewModel : YXTableViewModel

@property (nonatomic, strong) NSArray *list;

// 更新推送
@property (nonatomic, strong) RACCommand *updatePushSettingListRequestCommand;

@end

NS_ASSUME_NONNULL_END
