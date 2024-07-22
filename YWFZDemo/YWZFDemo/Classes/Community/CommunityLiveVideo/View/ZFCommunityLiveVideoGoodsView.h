//
//  ZFCommunityLiveVideoGoodsView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"
#import "ZFGoodsDetailCouponModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveVideoGoodsView : UIView

- (instancetype)initWithFrame:(CGRect)frame cateName:(NSString *)cateName cateID:(NSString *)cateID skus:(NSString *)skus;

@property (nonatomic, copy) void (^selectBlock)(ZFGoodsModel *goodModel);
@property (nonatomic, copy) void (^cartGoodsBlock)(ZFGoodsModel *goodModel);
@property (nonatomic, copy) void (^similarGoodsBlock)(ZFGoodsModel *goodModel);
@property (nonatomic, copy) void (^goodsArrayBlock)(NSMutableArray<ZFGoodsModel *> *goodsArray);


- (void)zfViewWillAppear;

- (NSMutableArray<ZFGoodsModel *> *)currentGoodsArray;

- (void)fullScreen:(id)isFull;
@end

NS_ASSUME_NONNULL_END
