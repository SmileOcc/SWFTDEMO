//
//  OSSVDetailHeaderCoinView.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/8.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVDetailsBaseInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVDetailHeaderCoinView : UIView

@property (nonatomic, copy) void(^coinBlock)(void);
- (void)configBaseInfoModel:(OSSVDetailsBaseInfoModel *)baseInfoModel;

@end

NS_ASSUME_NONNULL_END
