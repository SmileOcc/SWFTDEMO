//
//  OSSVOrdersWarnsCountrysInfoModel.h
// OSSVOrdersWarnsCountrysInfoModel
//
//  Created by 10010 on 20/10/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVOrdersWarnsCountrysInfoModel : NSObject

/** 编码 */
@property (nonatomic, strong) NSString *countryCode;
/** 名称 */
@property (nonatomic, strong) NSString *countryName;
/** 图片 */
@property (nonatomic, strong) NSString *picture;
/** ID */
@property (nonatomic, strong) NSString *countryId;

@end
