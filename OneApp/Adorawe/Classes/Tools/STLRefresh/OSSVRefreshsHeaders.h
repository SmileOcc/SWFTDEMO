//
//  OSSVRefreshsHeaders.h
// XStarlinkProject
//
//  Created by odd on 2020/9/24.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "MJRefreshHeader.h"
#import "OSSVAdvsEventsModel.h"
#import "MJRefresh.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MJRefreshDropBannerBlock)(void);
typedef void(^MJRefreshDropPullingBlock)(void);

@interface OSSVRefreshsHeaders : MJRefreshHeader

@property (nonatomic, strong) OSSVAdvsEventsModel *bannerModel;

@property (nonatomic, assign) BOOL isCommunityRefresh;

@property (nonatomic, copy) MJRefreshDropBannerBlock   refreshDropBannerBlock;

///正在下拉触发的block
@property (nonatomic, copy) MJRefreshDropPullingBlock  refreshDropPullingBlock;

///下拉显示的转圈logo的偏移量
@property (nonatomic, assign) CGFloat startViewOffsetY;

@end

NS_ASSUME_NONNULL_END
