//
//  CategoryRefineModel.m
//  ListPageViewController
//
//  Created by YW on 1/7/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CategoryRefineSectionModel.h"

@implementation CategoryRefineSectionModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"refine_list"   : [CategoryRefineDetailModel class] };
    
}
@end
