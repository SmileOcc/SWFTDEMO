//
//  STLBindCountryModel.h
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 "id": "11",
 "code": "61",
 "country_code": "AU",
 "country_name": "Australia",
 "picture": "http://uidesign.yoshop.com/YS/image/app/country/AU.png"
 */
@interface STLBindCountryModel : NSObject <YYModel>
@property (copy,nonatomic) NSString *countryId;
@property (copy,nonatomic) NSString *code;
@property (copy,nonatomic) NSString *country_code;
@property (copy,nonatomic) NSString *country_name;
@property (copy,nonatomic) NSString *picture;
@end


NS_ASSUME_NONNULL_END
