//
//  YXBrokerDetailCell.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/26.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXBaseStockListCell.h"
#import "YXTableViewCell.h"
@class YXBrokerDetailSubModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXBrokerDetailCell : YXTableViewCell

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) NSInteger priceBase;

@property (nonatomic, strong) YXBrokerDetailSubModel *subModel;

@end

NS_ASSUME_NONNULL_END
