//
//  ZFSearchResultPriceSortView.h
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFSearchResultPriceSortType) {
    ZFSearchResultPriceSortTypeHighToLow = 0,
    ZFSearchResultPriceSortTypeLowToHigh,
    ZFSearchResultPriceSortTypeNormal,
};

typedef void(^ZFSearchResultPriceSortCompletionHandler)(ZFSearchResultPriceSortType type);

@interface ZFSearchResultPriceSortView : UIView

@property (nonatomic, assign) ZFSearchResultPriceSortType           sortType;

@property (nonatomic, copy) ZFSearchResultPriceSortCompletionHandler        searchResultPriceSortCompletionHandler;

@end
