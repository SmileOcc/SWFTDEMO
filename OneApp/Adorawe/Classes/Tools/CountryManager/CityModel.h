//
//  CityModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/2/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLVillageModel.h"
@interface CityModel : NSObject

@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *cityId;
@property (nonatomic, copy) NSString *provinceId;

@property (nonatomic, strong) NSArray <STLVillageModel *> *area;

@end
