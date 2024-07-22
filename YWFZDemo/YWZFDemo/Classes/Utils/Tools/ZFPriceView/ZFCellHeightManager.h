//
//  ZFCellHeightManager.h
//  ZZZZZ
//
//  Created by YW on 27/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZFGoodsModel.h"

@class ZFGoodsTagModel;

@interface ZFCellHeightManager : NSObject

+ (instancetype)shareManager;

/**
 * 根据model hash 获取cache中的高度,如果无则返回-1
 */
- (CGFloat)queryHeightWithModelHash:(NSUInteger)hash;

/**
 * 计算cell高度并保存
 */
- (CGFloat)calculateCellHeightWithTagsArrayModel:(ZFGoodsModel *)goodsModel;


/**
 * 判断是否需要换行
 */
- (BOOL)isNewLineWithModelHash:(NSUInteger)hash;

/**
 * 清空cache
 */
- (void)clearCaches;

/**
 * 判断是否为首页推荐商品cell
 */
@property (nonatomic, assign) BOOL   isRecomendCell;

@end
