//
//  CategoryRefineInfoView.h
//  ListPageViewController
//
//  Created by YW on 30/6/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryRefineSectionModel;

typedef void(^ApplyRefineSelectInfoCompletionHandler)(NSDictionary *parms,NSDictionary *afParams);

typedef void(^CategoryRefineSelectIconCompletionHandler)(BOOL select);

@interface CategoryRefineInfoView : UIView

@property (nonatomic, strong) CategoryRefineSectionModel   *model;

@property (nonatomic, copy) ApplyRefineSelectInfoCompletionHandler      applyRefineSelectInfoCompletionHandler;

@property (nonatomic, copy) CategoryRefineSelectIconCompletionHandler   categoryRefineSelectIconCompletionHandler;

/**
 * 如果是从Deeplink进来需要选中指定的refine
 */
- (void)shouldSelectedCustomRefineByDeeplink:(NSArray<NSString *> *)categoryTypeArr
                                    priceMax:(NSString *)priceMax
                                    priceMin:(NSString *)priceMin
                                    hasCheck:(void(^)(void))hasCheckHandle;

- (void)clearRequestParmaters;

@end
