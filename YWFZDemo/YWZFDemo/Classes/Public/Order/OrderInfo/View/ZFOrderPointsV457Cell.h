//
//  ZFOrderPointsV457Cell.h
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  新版本积分cell v457

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^orderPointsSwitchBlock)(BOOL isOn);

@class PointModel;
@interface ZFOrderPointsV457Cell : UITableViewCell

@property (nonatomic, strong) PointModel            *pointModel;
@property (nonatomic, assign) BOOL                  isCod;
@property (nonatomic, assign) BOOL                  isChoose;
@property (nonatomic, copy) orderPointsSwitchBlock  pointSwitchHandler;

+ (NSString *)queryReuseIdentifier;

@end

NS_ASSUME_NONNULL_END
