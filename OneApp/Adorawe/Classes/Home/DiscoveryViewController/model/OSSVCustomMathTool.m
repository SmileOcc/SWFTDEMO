//
//  OSSVCustomMathTool.m
//  TestCollectionView
//
//  Created by 10010 on 20/7/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCustomMathTool.h"

@implementation OSSVCustomMathTool

+ (NSUInteger)shortestColumnIndex:(NSArray *)heights {
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;

    [heights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height < shortestHeight) {
            shortestHeight = height;
            index = idx;
        }
    }];
    
    return index;
}

+ (NSUInteger)longestColumnIndex:(NSArray *)heights {
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;
    
    [heights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat height = [obj floatValue];
        if (height > longestHeight) {
            longestHeight = height;
            index = idx;
        }
    }];
    
    return index;
}

@end
