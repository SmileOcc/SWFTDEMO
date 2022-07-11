//
//  YXTodayGreyStockCell.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/4/13.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YXV2Quote;

NS_ASSUME_NONNULL_BEGIN

@interface YXTodayGreyStockCell : UITableViewCell

@property (nonatomic, strong) YXV2Quote *quote;

@property (nonatomic, copy) void (^orderCallBack)(YXV2Quote *quote);

@end

NS_ASSUME_NONNULL_END
