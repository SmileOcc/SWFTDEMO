//
//  ZFCategoryRefineNewView.h
//  ZZZZZ
//
//  Created by YW on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCategoryRefineColorCCell.h"
#import "ZFCategoryRefinePriceCCell.h"
#import "ZFCategoryRefineNormalCCell.h"
#import "ZFCategoryRefineSpecialCCell.h"

#import "ZFGeshopSectionModel.h"
#import "CategoryRefineSectionModel.h"

typedef void(^HideRefineViewCompletionHandler)(void);

@interface ZFCategoryRefineNewView : UIView

@property (nonatomic, copy) HideRefineViewCompletionHandler         hideRefineViewCompletionHandler;

/// 只是存储请求的数据
@property (nonatomic, strong) CategoryRefineSectionModel            *model;

@property (nonatomic, strong) UIView                                *mainView;
@property (nonatomic, strong) UIView                                *bottomToolView;
@property (nonatomic, strong) UIButton                              *cancelButton;
@property (nonatomic, strong) UIButton                              *confirmButton;
@property (nonatomic, strong) UICollectionView                      *collectView;

/// 原生专题来源数据
@property (nonatomic, strong) NSArray<ZFGeshopSiftItemModel *>       *nativeRefineDataArray;
/// 分类来源数据
@property (nonatomic, strong) NSArray<CategoryRefineDetailModel *>  *categoryRefineDataArray;

@property (nonatomic, copy) NSString *af_page_name;

/// 对应来源返回对应数据：（原生专题选择，分类选择）
@property (nonatomic, copy) void (^confirmBlock)(NSArray <ZFGeshopSiftItemModel*> *nativeResults, NSArray <CategoryRefineCellModel*> *categoryResults, NSDictionary *afParams);


@property (nonatomic, copy) void (^hideCategoryRefineBlock)(void);

@property (nonatomic, copy) void (^clearConditionBlock)(void);


- (void)showRefineInfoViewWithAnimation:(BOOL)animation;
- (void)hideRefineInfoViewViewWithAnimation:(BOOL)animation;


/**
 * 如果是从Deeplink进来需要选中指定的refine
 */
- (void)selectedCustomRefineByDeeplink:(NSString *)selectedCategorys
                              priceMax:(NSString *)priceMax
                              priceMin:(NSString *)priceMin
                              hasCheck:(void(^)(void))hasCheckBlock;
@end

