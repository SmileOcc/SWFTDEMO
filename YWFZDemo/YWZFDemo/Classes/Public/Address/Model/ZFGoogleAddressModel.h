//
//  ZFGoogleAddressModel.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZFGoogleHighlightModel : NSObject
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) NSInteger offset;
@end

@interface ZFGoogleStructuredModel : NSObject
@property (nonatomic, strong) NSString *main_text;
@property (nonatomic, strong) NSString *secondary_text;
@end

@interface ZFGoogleAddressModel : NSObject
@property (nonatomic, strong) NSString *place_id;
@property (nonatomic, strong) NSString *main_text;
@property (nonatomic, strong) NSString *secondary_text;
@property (nonatomic, strong) NSArray<ZFGoogleHighlightModel *> *highlight;
@property (nonatomic, strong) ZFGoogleStructuredModel *structured_formatting;
@end



@interface ZFGoogleAddressComponentsModel : NSObject
@property (nonatomic, strong) NSString *addressline1;
@property (nonatomic, strong) NSString *addressline2;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *country_code;
@property (nonatomic, strong) NSString *country_id;
@property (nonatomic, strong) NSString *postcode;
@property (nonatomic, strong) NSString *provice_num;
@property (nonatomic, strong) NSString *state;
@end

@interface ZFGoogleDetailAddressModel : NSObject
@property (nonatomic, strong) NSString *formatted_address;
@property (nonatomic, strong) NSString *place_id;
@property (nonatomic, strong) ZFGoogleAddressComponentsModel *address_components;
@end
