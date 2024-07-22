//
//  ZFPriceView.h
//  ZZZZZ
//
//  Created by YW on 14/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZFBaseGoodsModel,ZFGoodsModel;

typedef void(^CollectCompletionHandler)(BOOL collect);
typedef void(^ColorBlockClickBlock)(NSInteger index);

@interface ZFPriceView : UIView

@property (nonatomic, strong) ZFBaseGoodsModel   *model;
@property (nonatomic, strong) ZFGoodsModel       *goodsModel;  // 用于保存列表中选中

@property (nonatomic, copy) CollectCompletionHandler         CollectCompletionHandler;
@property (nonatomic, copy) ColorBlockClickBlock             colorBlockClick;

@property (nonatomic, assign) BOOL isInvalidGoods; //是否为失效商品,要显示slod out 标签

// V440 活动商品价格高亮
@property (nonatomic, assign) BOOL isPriceHighlight;

- (void)clearAllData;

@end

