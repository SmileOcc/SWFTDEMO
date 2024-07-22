//
//  ZFTrackingPackageModel.h
//  ZZZZZ
//
//  Created by YW on 4/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFTrackingPackageModel : NSObject


@property (nonatomic, copy) NSString   *order_sn;

/**
 * 物流方式
 */
@property (nonatomic, copy) NSString   *shipping_name;


/**
 * 物流编号
 */
@property (nonatomic, copy) NSString   *shipping_no;


/**
 * 商品列表
 */
@property (nonatomic, strong) NSArray   *track_goods;

/**
 * 物流信息
 */
@property (nonatomic, strong) NSArray   *track_list;

/**
 * 真实物流信息网页地址
 */
@property (nonatomic, copy) NSString *tracking_url;

///物流机构名称
@property (nonatomic, copy) NSString *shipping_company;

@end
