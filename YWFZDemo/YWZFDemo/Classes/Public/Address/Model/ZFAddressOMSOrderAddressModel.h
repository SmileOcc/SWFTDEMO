//
//  ZFAddressOMSOrderAddressModel.h
//  ZZZZZ
//
//  Created by YW on 2019/6/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZFAddressOMSOrderAddressDataModel;

NS_ASSUME_NONNULL_BEGIN

@interface ZFAddressOMSOrderAddressModel : NSObject

@property (nonatomic, assign) NSInteger status;
@property (nonatomic, copy) NSString *country;
@property (nonatomic, copy) NSString *country_code;
@property (nonatomic, copy) NSString *country_id;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *barangay;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *address2;
@property (nonatomic, copy) NSString *zipcode;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, strong) ZFAddressOMSOrderAddressDataModel *data;

@end


@interface ZFAddressOMSOrderAddressDataModel : NSObject

@property (nonatomic, assign) BOOL is_cod;
@property (nonatomic, copy) NSString *code;
@property (nonatomic, assign) BOOL support_zip_code;
@property (nonatomic, assign) BOOL ownState;
@property (nonatomic, assign) BOOL ownCity;
@property (nonatomic, assign) BOOL ownBarangay;
@property (nonatomic, assign) BOOL showFourLevel;

@end

NS_ASSUME_NONNULL_END
