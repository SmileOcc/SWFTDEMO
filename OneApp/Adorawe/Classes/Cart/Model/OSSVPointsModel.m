//
//  OSSVPointsModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVPointsModel.h"

@implementation OSSVPointsModel

// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[@"save",@"points"];
}

@end
