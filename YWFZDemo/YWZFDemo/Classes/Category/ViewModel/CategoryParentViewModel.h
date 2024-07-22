//
//  CategoryParentViewModel.h
//  ListPageViewController
//
//  Created by YW on 26/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CategoryParentCell.h"
#import "ZFBannerModel.h"
#import "ZFCategoryParentModel.h"
#import "BaseViewModel.h"

#define kSuperCategoryTableWidth    (104.0f)
#define kImageTitleHeight           (40.0f)
#define kImageMarginSpace           (10.0f)
#define kCollectionViewMargin       (12.0f)

@class ZFCateBranchBanner;
@interface CategoryParentViewModel : BaseViewModel

@property (nonatomic, strong) UIView *loadingView;

@property (nonatomic, strong) NSMutableArray<ZFSubCategorySectionModel *> *subCateSectionModelArray;

@property (nonatomic, copy) void(^subCateRequestHandler)(void);

- (void)requestParentsData:(void (^)(void))completion failure:(void (^)(id obj))failure;

/// Elf新分类导航接口
- (void)requestParentsCategoryData:(id)parmaters
                        completion:(void (^)(NSArray *parentModelArray))completion
                           failure:(void (^)(NSError *error))failure;

/***
 父分类处理
*/
- (NSInteger)superCateCount;
- (NSString *)superCateNameWithIndex:(NSInteger)index;
- (ZFCategoryTabNav *)superCateWithIndex:(NSInteger)index;
- (NSInteger)selectedCateIndex;
- (ZFCategoryTabNav *)getSlectedCategoryTabNav;
- (void)setselectedCateIndex:(NSInteger)index;

/***
 子分类处理
 */
- (CategoryNewModel *)subCateModelWidthIndex:(NSInteger)index;

/***
 统计
 */
- (void)clickCateAdvertisementWithIndex:(NSInteger)index;

- (void)clickBannerAdvertisementWithIndex:(ZFCategoryTabContainer *)bannerModel
                              bannerIndex:(NSInteger)bannerIndex;

@end

