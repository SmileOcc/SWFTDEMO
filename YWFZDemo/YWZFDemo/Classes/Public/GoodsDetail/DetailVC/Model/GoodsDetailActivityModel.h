//
//  GoodsDetailActivityModel.h
//  ZZZZZ
//
//  Created by YW on 15/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

// 商详页活动类型
typedef NS_ENUM(NSUInteger, GoodsDetailActivityType){
    // 无浮窗
    GoodsDetailActivityTypeNormal      = 0,
    // 秒杀进行时
    GoodsDetailActivityTypeFlashing    = 1,
    // 秒杀预告
    GoodsDetailActivityTypeFlashNotice = 2,
    // 新人专享价
    GoodsDetailActivityTypeNewMember   = 3,
    // 拼团 V4.5.1
    GoodsDetailActivityTypeGroupBuy    = 4
};

@interface GoodsDetailActivityModel : NSObject
/**
 * 秒杀预告时间
 */
@property (nonatomic, copy) NSString   *beginTime;
/**
 * 秒杀倒计时
 */
@property (nonatomic, copy) NSString   *countDownTime;
/**
 * 开启秒杀倒计时key
 */
@property (nonatomic, copy) NSString   *countDownTimerKey;
/**
 * 秒杀价
 */
@property (nonatomic, copy) NSString   *price;
/**
 * 秒杀件数
 */
@property (nonatomic, copy) NSString  *total;

/**
 * 秒杀件数 (非服务端返回)
 */
@property (nonatomic, strong) NSAttributedString  *flashingTotalText;

/**
 * 活动类型
 */
@property (nonatomic, assign) GoodsDetailActivityType   type;


@end
