//
//  ZFNewUserCouponsView.h
//  ZZZZZ
//
//  Created by mac on 2019/1/9.
//  Copyright © 2019年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFNewUserHeckReceivingStatusModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^SuccessSignBlock)(void);

@interface ZFNewUserCouponsView : UIView

@property (nonatomic, copy) SuccessSignBlock successBlock;

@property (nonatomic, strong) ZFNewUserHeckReceivingStatusModel *heckReceivingStatusModel;

@end

NS_ASSUME_NONNULL_END
