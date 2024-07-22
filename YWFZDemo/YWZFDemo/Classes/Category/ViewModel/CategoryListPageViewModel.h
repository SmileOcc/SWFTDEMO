//
//  CategoryListPageViewModel.h
//  ListPageViewController
//
//  Created by YW on 16/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CategoryListPageModel.h"
#import "CategoryPriceListModel.h"
#import "ZFCategoryListAnalyticsAOP.h"
#import "BaseViewModel.h"
#import "CategoryNewModel.h"

typedef void(^ListpageCompletionHandler)(ZFGoodsModel *model, UIImageView *imageView);

@interface CategoryListPageViewModel : BaseViewModel <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UIScrollViewDelegate>

@property (nonatomic, copy) ListpageCompletionHandler   handler;

@property (nonatomic, copy) void (^scrollListViewBlock)(BOOL show);

@property (nonatomic, strong) NSMutableArray          *goodsArray;

@property (nonatomic, copy) NSString                  *lastCategoryID;

@property (nonatomic, copy) NSString                  *cateName;
/**
 * 是否为虚拟分类
 */
@property (nonatomic, assign) BOOL                    isVirtual;
/**
 * 判断虚拟分类从哪个入口加载
 */
@property (nonatomic, assign) BOOL                    isFromHome;

//@property (nonatomic, weak) UIViewController          *viewController;

@property (nonatomic, strong) CategoryListPageModel   *model;

@property (nonatomic, strong) NSArray <CategoryNewModel *> *categoryModelList;

@property (nonatomic, copy) NSString *analyticsSort;
/**
 * coupon使用入口带过来的参数 v4.5.5
 */
@property (nonatomic, copy) NSString   *coupon;

- (void)requestCategoryListDataWithParams:(NSDictionary *)parmaters
                              loadingView:(UIView *)loadingView
                               completion:(void (^)(CategoryListPageModel *loadingModel, NSInteger nextPageIndex,id pageData, BOOL isSucess))completion;

/**
 * 请求实体分类数据
 */
- (void)requestCategoryListData:(id)parmaters
                     completion:(void (^)(CategoryListPageModel *loadingModel, NSInteger nextPageIndex,id pageData))completion;

/**
 * 请求Refine数据
 */
- (void)requestRefineDataWithCatID:(NSDictionary *)params completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

@end

