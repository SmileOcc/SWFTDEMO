//
//  OSSVCategoryRefinesNewView.h
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCategorysSectionsModel.h"
#import "OSSVCategorysFiltersNewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^HideRefineViewCompletionHandler)(void);


@interface OSSVCategoryRefinesNewView : UIView

@property (nonatomic, copy) HideRefineViewCompletionHandler         hideRefineViewCompletionHandler;

///// 只是存储请求的数据
//@property (nonatomic, strong) OSSVCategorysSectionsModel              *model;

@property (nonatomic, strong) UIView                                *mainView;
@property (nonatomic, strong) UIView                                *bottomToolView;
@property (nonatomic, strong) UIButton                              *cancelButton;
@property (nonatomic, strong) UIButton                              *confirmButton;
@property (nonatomic, strong) UIView                                *lineView;
@property (nonatomic, strong) UICollectionView                      *collectView;

/// 分类来源数据
@property (nonatomic, strong) NSArray<OSSVCategorysFiltersNewModel *>  *categoryRefineDataArray;

@property (nonatomic, copy) NSString *af_page_name;
@property (nonatomic, copy) NSString *sourceKey;

/// 对应来源返回对应数据：（原生专题选择，分类选择）
@property (nonatomic, copy) void (^confirmBlock)(NSArray <OSSVCategroySubsFilterModel*> *nativeResults, NSArray <STLCategoryFilterValueModel*> *categoryResults, NSDictionary *afParams);


@property (nonatomic, copy) void (^hideCategoryRefineBlock)(void);

@property (nonatomic, copy) void (^clearConditionBlock)(void);


- (void)showRefineInfoViewWithAnimation:(BOOL)animation;
- (void)hideRefineInfoViewViewWithAnimation:(BOOL)animation;

- (NSString *)filterPriceCondition;
- (NSDictionary *)filterItemIDs;
/**
 * 如果是从Deeplink进来需要选中指定的refine
 */
- (void)selectedCustomRefineByDeeplink:(NSString *)selectedCategorys
                              priceMax:(NSString *)priceMax
                              priceMin:(NSString *)priceMin
                              hasCheck:(void(^)(void))hasCheckBlock;

@end

NS_ASSUME_NONNULL_END
