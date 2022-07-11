//
//  YXStockDetailBrokerView.h
//  YouXinZhengQuan
//
//  Created by chenmingmao on 2019/9/29.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <ReactiveObjC/ReactiveObjC.h>
#import "uSmartOversea-Swift.h"
@class PosBroker;
NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailBrokerView : UIView
@property (nonatomic, strong) RACCommand *gradeTypeShiftCommand;

@property (nonatomic, strong) PosBroker *posBroker;

- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
