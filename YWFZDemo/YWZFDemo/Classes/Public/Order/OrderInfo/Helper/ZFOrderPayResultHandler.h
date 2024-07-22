//
//  ZFOrderPayResultHandler.h
//  ZZZZZ
//
//  Created by YW on 2019/9/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  处理支付完成后多处视图跳转

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFBaseOrderModel.h"
#import "ZFOrderPayResultModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger) {
    ZFOrderPayResultSource_OrderInfo,
    ZFOrderPayResultSource_OrderList,
    ZFOrderPayResultSource_OrderDetail,
    ZFOrderPayResultSource_Other //包括购物车购买，首页弹窗购买
}ZFOrderPayResultSource;

typedef void(^OrderPayResultDismissSucessVCBlock)(void);

@interface ZFOrderPayResultHandler : NSObject

+ (instancetype)handler;

@property (nonatomic, weak) UIViewController *zfParentViewController;

//释放成功页后的回调
@property (nonatomic, copy) OrderPayResultDismissSucessVCBlock dismissSuccessVCBlock;

//支付成功后的操作
- (void)orderPaySuccess:(ZFOrderPayResultSource)source
         baseOrderModel:(ZFBaseOrderModel *)orderModel
            resultModel:(ZFOrderPayResultModel *)resultModel;

@end

NS_ASSUME_NONNULL_END
