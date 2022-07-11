//
//  YXKlineSubIndexViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2019/12/17.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"
#import "YXKlineSettingModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXKlineSubIndexViewModel : YXTableViewModel

@property (nonatomic, assign) NSInteger indexType;

@property (nonatomic, strong) YXKlineSettingModel *model;

- (void)resetData;

@end

NS_ASSUME_NONNULL_END
