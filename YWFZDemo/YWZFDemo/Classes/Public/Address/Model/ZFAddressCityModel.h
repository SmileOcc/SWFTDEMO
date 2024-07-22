//
//  ZFAddressCityModel.h
//  ZZZZZ
//
//  Created by YW on 2017/9/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAddressBaseModel.h"
#import "ZFAddressTownModel.h"

@interface ZFAddressCityModel : ZFAddressBaseModel

@property (nonatomic, copy) NSString     *cityId;
@property (nonatomic, copy) NSString     *name;
@property (nonatomic, copy) NSString     *province_id;
@property (nonatomic, strong) NSArray<ZFAddressTownModel *>   *town_list;

@end


//智能搜索
@interface ZFAddressHintCityModel : NSObject

@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *postcode;

@end
