//
//  ZFSearchResultSortView.h
//  ZZZZZ
//
//  Created by YW on 2018/3/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ZFSearchResultSortType) {
    ZFSearchResultSortTypeRecommend = 0,
    ZFSearchResultSortTypeNewArrival,
    ZFSearchResultSortTypeHighToLow,
    ZFSearchResultSortTypeLowToHigh,
};

typedef void(^ZFSearchResultSortCompletionHandler)(ZFSearchResultSortType type);

@interface ZFSearchResultSortView : UIView

@property (nonatomic, assign) ZFSearchResultSortType                    selectType;

@property (nonatomic, copy) ZFSearchResultSortCompletionHandler         searchResultSortCompletionHandler;

@end
