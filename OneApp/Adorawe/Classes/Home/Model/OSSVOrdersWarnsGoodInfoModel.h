//
//  OrderWarnGoodsInfoModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/10/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVOrdersWarnsGoodInfoModel : NSObject

/** ID */
@property (nonatomic, strong) NSString *wid;
/** 图片 */
@property (nonatomic, strong) NSString *goodsThumb;
/** 商品ID */
@property (nonatomic, strong) NSString *goodsId;

@end

