//
//  ZFNewPushAllowView.h
//  ZZZZZ
//
//  Created by YW on 2018/8/17.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//
// 条件:没有开启推送, 需求: 在支付状态失败, 物流页面, 订单列表页面需要弹框

#import <UIKit/UIKit.h>
#import "ZFPushManager.h"

typedef NS_ENUM(NSInteger) {
    /**提示*/
    PushAllowViewType_Msg,
    /**订单成功*/
    PushAllowViewType_OrderSuccess,
    /**订单失败*/
    PushAllowViewType_OrderFail,
}PushAllowViewType;

@interface ZFNewPushAllowView : UIView

//+ (instancetype)shareInstance;

/**有时间限制*/
-(void)limitShow:(PushAllowViewType)type operateBlock:(void(^)(BOOL flag))operateBlock;
/**直接显示*/
-(void)noLimitShow:(PushAllowViewType)type operateBlock:(void(^)(BOOL flag))operateBlock;

- (void)hidden;


@end
