//
//  CategoryListPageModel.h
//  ListPageViewController
//
//  Created by YW on 24/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFGoodsModel.h"
#import "GoodsDetailModel.h"
#import "ZFBTSDataSetProtocol.h"

/**
 *  原有listPage接口  @"category/get_list"  和  虚拟分类接口  @"category/get_promotion_goods"
 *
 *  共用一个数据模型
 */

@interface CategoryListPageModel : NSObject
<
    YYModel,
    ZFBTSDataSetProtocol
>
/**
 * 商品数据
 */
@property (nonatomic, strong) NSArray<ZFGoodsModel *>          *goods_list;

/**
 * 商品总量
 */
@property (nonatomic, copy) NSString           *result_num;
/**
 * 当前页数
 */
@property (nonatomic, copy) NSString         *cur_page;
/**
 * 总页数
 */
@property (nonatomic, copy) NSString         *total_page;
/**
 * 虚拟分类所有数据
 */
@property (nonatomic, strong) NSArray          *virtualCategorys;
/**
 * deals价格列表
 */
@property (nonatomic, strong) NSArray          *price_list;

@property (nonatomic, strong) NSArray  *guideWords;

@property (nonatomic, strong) AFparams  *af_params;
@property (nonatomic, strong) AFparams  *af_params_color;

@end


