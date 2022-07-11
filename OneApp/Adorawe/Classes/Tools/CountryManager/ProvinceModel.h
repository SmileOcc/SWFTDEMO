//
//  ProvinceModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProvinceModel : NSObject<NSCoding>
@property (nonatomic,copy) NSString *provinceId;
@property (nonatomic,copy) NSString *provinceName;
@property (nonatomic,assign) BOOL isHasCity;
@end
