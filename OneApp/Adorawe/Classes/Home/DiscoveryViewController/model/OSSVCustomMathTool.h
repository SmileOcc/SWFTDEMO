//
//  OSSVCustomMathTool.h
//  TestCollectionView
//
//  Created by 10010 on 20/7/29.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  一些简单的计算合计

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OSSVCustomMathTool : NSObject

///从高度集合里面找出最短的那一个
+ (NSUInteger)shortestColumnIndex:(NSArray *)heights;

///从高度集合里面找出最长的那一个
+ (NSUInteger)longestColumnIndex:(NSArray *)heights;

@end
