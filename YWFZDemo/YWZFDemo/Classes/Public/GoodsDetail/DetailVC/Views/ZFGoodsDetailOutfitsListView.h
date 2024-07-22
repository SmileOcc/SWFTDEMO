//
//  ZFGoodsDetailOutfitsListView.h
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFGoodsModel;

@interface ZFGoodsDetailOutfitsListView : UIView

@property (nonatomic, copy) void (^outfitsActionBlock)(ZFGoodsModel *goodsModel, NSUInteger actionType);

@property (nonatomic, copy) NSString *tmpShowOutfitsId;

/**
 * 显示穿搭列表
 */
- (void)convertOutfitsListView:(NSArray<ZFGoodsModel *> *)goodsModelArr
                   showOutfits:(BOOL)isShow;

@end
