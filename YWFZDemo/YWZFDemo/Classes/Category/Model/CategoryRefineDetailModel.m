//
//  CategoryRefineDetailModel.m
//  ListPageViewController
//
//  Created by YW on 1/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryRefineDetailModel.h"
#import "CategoryRefineCellModel.h"
#import "YWCFunctionTool.h"

@implementation CategoryRefineDetailModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"childArray"   : @"child" };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"childArray"   : [CategoryRefineCellModel class] };
    
}

/// 类型 v540 (service,color,size,price,clothing length,collar,pattern type,material,style)
- (NSString *)af_refineKeyForkType {
    if (ZFIsEmptyString(self.type)) {
        return @"";
    }
    
    if ([self.type isEqualToString:@"service"]) {
        return @"service";
    } else if([self.type isEqualToString:@"color"]) {
        return @"color";
    } else if([self.type isEqualToString:@"size"]) {
           return @"size";
    } else if([self.type isEqualToString:@"price"]) {
           return @"af_pricerange";
    } else if([self.type isEqualToString:@"style"]) {
           return @"af_style";
    } else if([self.type isEqualToString:@"collar"]) {
           return @"af_collar";
    } else if([self.type isEqualToString:@"material"]) {
           return @"af_material";
    } else if([self.type isEqualToString:@"clothing length"]) {
           return @"af_length";
    } else if([self.type isEqualToString:@"pattern type"]) {
            return @"af_patterntype";
    }
    
    //af_waist,af_swimweartype,af_sleevelength,af_silhouette,af_dresslength
    return @"";
}
@end
