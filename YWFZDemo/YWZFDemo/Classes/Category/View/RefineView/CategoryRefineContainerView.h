//
//  CategoryRefineView.h
//  ListPageViewController
//
//  Created by YW on 29/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryRefineSectionModel;

typedef void(^HideRefineViewCompletionHandler)(void);

typedef void(^ApplyRefineContainerViewInfoCompletionHandler)(NSDictionary *parms,NSDictionary *afParams);

typedef void(^CategoryRefineSelectIconCompletionHandler)(BOOL selelct);

@interface CategoryRefineContainerView : UIView

@property (nonatomic, copy) HideRefineViewCompletionHandler   hideRefineViewCompletionHandler;

@property (nonatomic, copy) ApplyRefineContainerViewInfoCompletionHandler   applyRefineContainerViewInfoCompletionHandler;

@property (nonatomic, copy) CategoryRefineSelectIconCompletionHandler       categoryRefineSelectIconCompletionHandler;

@property (nonatomic, strong) CategoryRefineSectionModel   *model;

/**
 * 如果是从Deeplink进来需要选中指定的refine
 */
- (void)selectedCustomRefineByDeeplink:(NSString *)selectedCategorys
                              priceMax:(NSString *)priceMax
                              priceMin:(NSString *)priceMin
                              hasCheck:(void(^)(void))hasCheckBlock;

- (void)showRefineInfoViewWithAnimation:(BOOL)animation;

- (void)hideRefineInfoViewViewWithAnimation:(BOOL)animation;

- (void)clearRefineInfoViewData;

@end
