//
//  ZFCommunityHomeCMSView.h
//  ZZZZZ
//
//  Created by YW on 2019/5/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZFAppsflyerAnalytics.h"
#import "ZFCMSManagerView.h"

@interface ZFCommunityHomeCMSView : UIView

@property (nonatomic, assign) ZFAppsflyerInSourceType     afSourceType;
@property (nonatomic, strong) ZFCMSManagerView            *cmsManagerView;

@property (nonatomic, assign) NSInteger                   selectIndex;

@property (nonatomic, copy) void (^menuTopBlock)(BOOL isTop);
@property (nonatomic, copy) void (^scrollDirectionUpBlock)(BOOL directionUp);



- (ZFBTSModel *)communityHomeBts;

/** 更新历史浏览记录 */
- (void)updateCMSHistoryGoods;

- (void)zf_viewDidShow;

- (void)scrollToTopOrRefresh;

@end

