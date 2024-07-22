//
//  ZFGoodsDetailActivityTimeView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsDetailModel.h"

@interface ZFGoodsDetailActivityTimeView : UIView
@property (nonatomic, strong) GoodsDetailActivityModel   *activityModel; // 秒杀活动
@property (nonatomic, copy) void (^countDownCompleteBlock)(void);//倒计时完成回调
@end
