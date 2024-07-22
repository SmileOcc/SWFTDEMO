//
//  ZFCommunityOutfitSelectItemViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/5/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryListPageModel.h"

/**
 穿搭选项VM
 */
@interface ZFCommunityOutfitSelectItemViewModel : NSObject

// ==================== 新 =================== //

@property (nonatomic, strong) CategoryListPageModel   *model;

/**
 * 是否为虚拟分类
 */
@property (nonatomic, assign) BOOL                    isVirtual;
@property (nonatomic, copy) NSString                  *cateName;
@property (nonatomic, strong) NSMutableArray          *goodsList;

- (void)requestSelectCategoryListData:(id)parmaters
                     completion:(void (^)(CategoryListPageModel *loadingModel,id pageData, BOOL requestState))completion;



/**
 * 请求Refine数据
 */
- (void)requestRefineDataWithCatID:(NSDictionary *)params
                        completion:(void (^)(id obj))completion
                           failure:(void (^)(id obj))failure;
@end
