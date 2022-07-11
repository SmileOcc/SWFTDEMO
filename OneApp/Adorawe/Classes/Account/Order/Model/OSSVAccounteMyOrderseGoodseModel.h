//
//  OSSVAccounteMyOrderseGoodseModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVOrdereMoneyeInfoModel.h"

@interface OSSVAccounteMyOrderseGoodseModel : NSObject
@property (nonatomic,copy) NSString *goods_name;
@property (nonatomic,copy) NSString *goods_thumb;
@property (nonatomic,copy) NSString *goods_attr;
@property (nonatomic,copy) NSString *goods_price;
@property (nonatomic,copy) NSString *market_price;
@property (nonatomic,copy) NSString *goods_number;
@property (nonatomic,copy) NSString *goods_id;
@property (nonatomic,copy) NSString *goods_sn;
@property (nonatomic,copy) NSString *cat_name;
@property (nonatomic,copy) NSString *cat_id;

@property (nonatomic, strong) OSSVOrdereMoneyeInfoModel *money_info;

@end

