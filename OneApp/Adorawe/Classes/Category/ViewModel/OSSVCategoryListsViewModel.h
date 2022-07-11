//
//  OSSVCategoryListsViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/4.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVCategoryListsModel.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "OSSVCategorysFiltersNewModel.h"

@interface OSSVCategoryListsViewModel : BaseViewModel

@property (nonatomic, strong) NSString                              *childDetailTitle;
@property (nonatomic, strong) NSMutableArray                        *dataArray;
@property (nonatomic, strong) OSSVCategoryListsModel                  *detailListModel;

@property (nonatomic, strong) NSArray<OSSVCategorysFiltersNewModel*>   *categoryFilterDatas;

// 筛选条件集合
//- (NSArray *)filterItems;



- (void)requestFilterNetwork:(id)parmaters
            completion:(void (^)(id))completion
                     failure:(void (^)(id))failure;

@end
