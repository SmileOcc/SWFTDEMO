//
//  ZFCheckShippingAddressModel.h
//  ZZZZZ
//
//  Created by YW on 2018/12/22.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

//纠错地址数据
@interface ZFCheckShippingAddressItemModel : NSObject

@property (nonatomic, copy) NSString *addressline1;
@property (nonatomic, copy) NSString *addressline2;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *region_code;
@property (nonatomic, copy) NSString *region_id;
@property (nonatomic, copy) NSString *zipcode;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *province_id;
@property (nonatomic, copy) NSString *code; //电话区号
@property (nonatomic, copy) NSString *highlight_address; //高亮地址


//自定义
@property (nonatomic, assign) BOOL   isMark;

@end

//地址纠错数据
@interface ZFCheckShippingAddressModel : NSObject

@property (nonatomic, strong) ZFCheckShippingAddressItemModel   *original_address;
@property (nonatomic, strong) ZFCheckShippingAddressItemModel   *suggested_address;
@end

