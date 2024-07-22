//
//  ZFFullLiveGoodsListView.h
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"
#import "ZFGoodsDetailCouponModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFFullLiveGoodsListView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, copy) void (^selectBlock)(ZFGoodsModel *goodModel);
@property (nonatomic, copy) void (^cartGoodsBlock)(ZFGoodsModel *goodModel);
@property (nonatomic, copy) void (^similarGoodsBlock)(ZFGoodsModel *goodModel);
@property (nonatomic, copy) void (^goodsArrayBlock)(NSMutableArray<ZFGoodsModel *> *goodsArray);

@property (nonatomic, copy) NSString *recommendGoodsId;


- (void)cateName:(NSString *)cateName cateID:(NSString *)cateID skus:(NSString *)skus;
- (void)zfViewWillAppear;

- (NSMutableArray<ZFGoodsModel *> *)currentGoodsArray;

@end

NS_ASSUME_NONNULL_END
