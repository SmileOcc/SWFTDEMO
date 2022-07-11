//
//  CartAddApi.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVBasesRequests.h"

@interface CartAddApi : OSSVBasesRequests

@property (nonatomic,copy) NSString* size_country_code;

//购物车新增一个参数 flash_sale_active_id 来区分是否闪购商品
// 加购新增一个替换0元商品的字段 replace_free_goods
- (instancetype)initWithWid:(NSString *)wid goodsId:(NSString *)goodsId goodsNum:(NSInteger)goodsNum isChecked:(NSInteger)checked flag:(NSInteger)flag specialId:(NSString *)specialId activeId:(NSString *)activeId;

- (instancetype)initWithWid:(NSString *)wid goodsId:(NSString *)goodsId goodsNum:(NSInteger)goodsNum isChecked:(NSInteger)checked flag:(NSInteger)flag specialId:(NSString *)specialId activeId:(NSString *)activeId replace_free:(NSInteger)replace_free;

@end
