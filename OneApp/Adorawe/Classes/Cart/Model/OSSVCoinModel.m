//
//  OSSVCoinModel.m
// XStarlinkProject
//
//  Created by Kevin on 2021/3/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCoinModel.h"

@implementation OSSVCoinModel
// 如果实现了该方法，则处理过程中不会处理该列表外的属性。
+ (NSArray *)modelPropertyWhitelist {
    return @[@"save",@"coins",@"coinText1",@"coinText2"];
}

@end
