//
//  YXBrokerDetailLongPressView.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/2/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXBrokerLineView.h"

@class YXBrokerDetailSubModel;

NS_ASSUME_NONNULL_BEGIN

@interface YXBrokerDetailLongPressView : UIView

@property (nonatomic, assign) NSInteger priceBase;

@property (nonatomic, strong) YXBrokerDetailSubModel *subModel;

- (instancetype)initWithFrame:(CGRect)frame andType:(YXBrokerLineType)type;

@end

NS_ASSUME_NONNULL_END
