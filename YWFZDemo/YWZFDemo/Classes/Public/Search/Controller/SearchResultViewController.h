//
//  SearchResultViewController.h
//  Dezzal
//
//  Created by YW on 18/8/10.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "ZFAppsflyerAnalytics.h"

typedef void(^SearchResultLoadHistoryCompletionHandler)(void);

@interface SearchResultViewController : ZFBaseViewController

@property (nonatomic, copy) NSString                         *searchString;

@property (nonatomic, copy) NSString                         *featuring;

@property (nonatomic, copy) SearchResultLoadHistoryCompletionHandler        searchResultLoadHistoryCompletionHandler;

@property (nonatomic, assign) ZFAppsflyerInSourceType sourceType;

@end
