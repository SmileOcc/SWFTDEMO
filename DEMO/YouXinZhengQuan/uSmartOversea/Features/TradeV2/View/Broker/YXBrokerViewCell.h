//
//  YXBrokerViewCell.h
//  YouXinZhengQuan
//
//  Created by 井超 on 2020/3/28.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXStockDetailBrokerView.h"
#import "YXTableViewCell.h"

#import "uSmartOversea-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXBrokerViewCell : YXTableViewCell

@property (nonatomic, strong) YXStockDetailBrokerView *brokerView;

@end

NS_ASSUME_NONNULL_END
