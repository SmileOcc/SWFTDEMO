//
//  CountryModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ProvinceModel;
@interface CountryModel : NSObject<NSCoding>
@property (nonatomic,copy) NSString                    *country_code; //国家简码
@property (nonatomic,copy) NSString                    *countryId;
@property (nonatomic,copy) NSString                    *countryName;
@property (nonatomic,copy) NSString                    *picture;
@property (nonatomic,copy) NSString                    *countryCode;
//这个需要更改为跟google地图返回的CountryCode是一致,android返回的是数字字符串,如“70101”
@property (nonatomic,copy) NSString                    *androidCode;
//这个也是需要跟google地图返回的CountryCode是一致，ios返回的是字符串，如“US”
@property (nonatomic,copy) NSString                    *iosCodeName;

@property (nonatomic,strong) NSArray                   *phoneHeadArr;
@property (nonatomic,copy) NSString                    *phoneRemainLength;
@property (nonatomic,strong) NSArray<ProvinceModel *>  *provinceList;

///1.3.4 国旗URL
@property (nonatomic,copy) NSString                    *flagURL;
@end
