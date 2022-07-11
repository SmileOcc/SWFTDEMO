//
//  YXTodayGreyStockViewModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/4/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXTodayGreyStockViewModel : YXTableViewModel

@property (nonatomic, strong) RACSubject *loadGreyDataSubject;

@end

NS_ASSUME_NONNULL_END
