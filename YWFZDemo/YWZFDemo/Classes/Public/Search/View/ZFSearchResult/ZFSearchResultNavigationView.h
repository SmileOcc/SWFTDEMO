//
//  ZFSearchResultNavigationView.h
//  ZZZZZ
//
//  Created by YW on 2018/3/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ZFSearchResultBackCompletionHandler)(void);
typedef void(^ZFSearchResultJumpCartCompletionHandler)(void);
typedef void(^ZFSearchResultCancelSearchCompletionHandler)(void);
typedef void(^ZFSearchResultSearchKeyCompletionHandler)(NSString *searchKey);
typedef void(^ZFSearchResultReturnCompletionHandler)(NSString *searchKey);
typedef void(^ZFSearchResultCancelNormalCompletionHandler)(void);

@interface ZFSearchResultNavigationView : UIView

@property (nonatomic, copy) NSString            *searchTitle;
@property (nonatomic, copy) NSString            *badgeCount;

@property (nonatomic, copy) ZFSearchResultBackCompletionHandler             searchResultBackCompletionHandler;
@property (nonatomic, copy) ZFSearchResultJumpCartCompletionHandler         searchResultJumpCartCompletionHandler;
@property (nonatomic, copy) ZFSearchResultCancelSearchCompletionHandler     searchResultCancelSearchCompletionHandler;
@property (nonatomic, copy) ZFSearchResultSearchKeyCompletionHandler        searchResultSearchKeyCompletionHandler;
@property (nonatomic, copy) ZFSearchResultReturnCompletionHandler           searchResultReturnCompletionHandler;
@property (nonatomic, copy) ZFSearchResultCancelNormalCompletionHandler     searchResultCancelNormalCompletionHandler;
- (void)cancelOptionRefreshLayout;

- (void)refreshCartCountAnimation;

- (void)hideBottomSeparateLine;
@end


