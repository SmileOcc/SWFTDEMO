//
//  OSSVHotsSearchWordsModel.m
// OSSVHotsSearchWordsModel
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHotsSearchWordsModel.h"

@implementation OSSVHotsSearchWordsModel

+ (NSDictionary *)modelCustomPropertyMapper {
    
    return @{
             @"iD"     : @"id",
             @"trendsId" : @"TrendsId"
             };
}



@end
