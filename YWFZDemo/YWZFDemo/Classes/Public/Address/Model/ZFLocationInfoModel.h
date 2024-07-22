//
//  ZFLocationInfoModel.h
//  ZZZZZ
//
//  Created by YW on 2017/12/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

@class ZFAddressLocationComponentsModel;

@interface ZFLocationInfoModel : NSObject <YYModel>

@property (nonatomic, copy) NSString            *cid;
@property (nonatomic, copy) NSString            *pid;
@property (nonatomic, copy) NSString            *name;
@property (nonatomic, copy) NSString            *code;
@property (nonatomic, copy) NSString            *type;
@property (nonatomic, copy) NSString            *name_ar;

@end


// ZF 经纬度定位信息
@interface ZFAddressLocationInfoModel : NSObject

@property (nonatomic, copy) NSString                                    *place_id;
@property (nonatomic, copy) NSString                                    *formatted_address;
@property (nonatomic, strong) ZFAddressLocationComponentsModel          *address_components;

@end


@interface ZFAddressLocationComponentsModel : NSObject

/**国家简码*/
@property (nonatomic, copy) NSString            *country_code;
@property (nonatomic, copy) NSString            *country;
@property (nonatomic, copy) NSString            *state;
@property (nonatomic, copy) NSString            *state_code;
@property (nonatomic, copy) NSString            *city;
@property (nonatomic, copy) NSString            *city_code;
@property (nonatomic, copy) NSString            *addressline1;
@property (nonatomic, copy) NSString            *addressline2;
@property (nonatomic, copy) NSString            *postcode;
@end
