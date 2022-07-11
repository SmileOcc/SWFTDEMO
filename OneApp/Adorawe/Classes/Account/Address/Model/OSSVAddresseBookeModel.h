//
//  AddressListModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVAddresseBookeModel : NSObject

@property (nonatomic, copy) NSString *addressId;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *countryId;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *street;
@property (nonatomic, copy) NSString *streetMore;
@property (nonatomic, copy) NSString *zipPostNumber; // 邮编
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *district;
@property (nonatomic, copy) NSString *countryCode;  // 手机国家区号
@property (nonatomic, assign) BOOL isDefault;    //是否是默认邮寄地址 [0-否，1-是]
@property (nonatomic, assign) BOOL isPaypal;   //是否通过paypal带过来的地址[0-否，1-是]
@property (nonatomic, copy) NSString *idCard;  //身份证号
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;
@property (nonatomic, copy) NSString  *phoneHead;
@property (nonatomic, copy) NSString  *secondPhoneHead;
@property (nonatomic, copy) NSString  *secondPhone;
@property (nonatomic, strong) NSArray *phoneHeadArr;

@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *stateId;
@property (nonatomic, copy) NSString *addressType;
@property (nonatomic, copy) NSString *country_Code;//国家简码
//自定义 google 国家code
@property (nonatomic, copy) NSString *ISOcountryCode;

@property (nonatomic,assign) BOOL has_citys;
@property (nonatomic, copy) NSString  *user_id;
@property (nonatomic, copy) NSString  *phone_remain_length;
@property (nonatomic, copy) NSString  *area;
@property (nonatomic, copy) NSString  *area_id;

///是否需要
@property (nonatomic,assign) NSInteger need_zip_code;
//是否启用定位
@property (nonatomic,assign) NSInteger map_check;

@end
