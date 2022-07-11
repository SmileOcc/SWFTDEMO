//
//  OSSVDetailBottomView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"

typedef NS_ENUM(NSInteger, GoodsDetailBottomEvent){
    /** 购物车*/
    GoodsDetailBottomEventCart,
    /** 加入购物车*/
    GoodsDetailBottomEventAddCart,
    /** 客服*/
    GoodsDetailBottomEventChat,
    ///断码订阅
    GoodsDetailBottomEventSubscribeAlert,
};

@protocol OSSVDetailBottomViewDelegate<NSObject>

- (void)goodsDetailBottomEvent:(GoodsDetailBottomEvent)bottomEvent;

@end;

@interface OSSVDetailBottomView : UIView

@property (nonatomic, weak) id<OSSVDetailBottomViewDelegate> delegate;

/** 加入购物车*/
@property (nonatomic, strong) UIButton                       *addBtn;
@property (nonatomic, assign) BOOL                           enableCart;

@property (nonatomic, strong) UIView *verticalLine;
@property (nonatomic, strong) UIView *horizontalLine;

@end
