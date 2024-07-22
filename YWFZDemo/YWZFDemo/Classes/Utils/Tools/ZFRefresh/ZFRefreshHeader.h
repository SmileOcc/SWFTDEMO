//
//  ZFRefreshHeader.h
//  ZZZZZ
//
//  Created by YW on 23/3/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "MJRefreshHeader.h"
#import "ZFBannerModel.h"
#import "MJRefresh.h"

typedef void(^MJRefreshDropBannerBlock)(void);
typedef void(^MJRefreshDropPullingBlock)(void);

@interface ZFRefreshHeader : MJRefreshHeader

@property (nonatomic, strong) ZFBannerModel *bannerModel;

@property (nonatomic, assign) BOOL isCommunityRefresh;

@property (nonatomic, copy) MJRefreshDropBannerBlock   refreshDropBannerBlock;

///正在下拉触发的block
@property (nonatomic, copy) MJRefreshDropPullingBlock  refreshDropPullingBlock;

///下拉显示的转圈logo的偏移量
@property (nonatomic, assign) CGFloat startViewOffsetY;

@end
