//
//  OSSVMutilBranchLayoutUtls.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  多分管布局集合工具

#import <Foundation/Foundation.h>
#import "OSSVDiscoverBlocksModel.h"

typedef NS_ENUM(NSInteger) {
    MoreBranchLayout_One = 2,
    MoreBranchLayout_Two = 3,
    MoreBranchLayout_Three = 4,
    MoreBranchLayout_Four = 5,
    MoreBranchLayout_Five = 6,
    MoreBranchLayout_Eight = 9,
    MoreBranchLayout_Sixteen = 18
}MoreBranchLayout;

@interface OSSVMutilBranchLayoutUtls : NSObject

+(NSArray <UICollectionViewLayoutAttributes *> *)moreBranchLayout:(MoreBranchLayout)layout section:(CGFloat)section bottomOffset:(CGFloat)bottomOffset;


+(NSArray <UICollectionViewLayoutAttributes *> *)newMoreBranchLayout:(OSSVDiscoverBlocksModel *)blockModel section:(CGFloat)section bottomOffset:(CGFloat)bottomOffset;


@end
