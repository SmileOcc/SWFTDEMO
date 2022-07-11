//
//  OSSVHomeOrdersWarnModel.h
// OSSVHomeOrdersWarnModel
//
//  Created by 10010 on 20/10/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
@class OSSVOrdersWarnsGoodInfoModel;
@class OSSVOrdersWarnsCountrysInfoModel;

@interface OSSVHomeOrdersWarnModel : NSObject <YYModel>

/** 显示开关 */
@property (nonatomic, strong) NSString *status;
/** 用户名 */
@property (nonatomic, strong) NSString *nickName;
/** 订单状态 */
@property (nonatomic, strong) NSString *orderStstu;
/** 商品信息 */
@property (nonatomic, strong) OSSVOrdersWarnsGoodInfoModel *goodsInfo;
/** 国家信息 */
@property (nonatomic, strong) OSSVOrdersWarnsCountrysInfoModel *countryInfo;

@end

