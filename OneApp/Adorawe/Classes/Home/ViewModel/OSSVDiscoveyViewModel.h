//
//  DiscoveryViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "OSSVThemesMainLayout.h"
#import "OSSVHomeMainAnalyseAP.h"
#import "WMMenuView.h"
#import "OSSVHomeChannelCCellModel.h"

#import "UIColor+Extend.h"

typedef void (^UpdateHeaderHeightBlock)(CGFloat height);


@protocol DiscoveryViewModelDataSource <NSObject>

@optional

- (UICollectionView *)stl_DiscoveryCollectionView;
- (OSSVThemesMainLayout *)stl_DiscoveryLayout;

@end

@protocol DiscoveryViewModelDelegate <NSObject>

@optional

- (void)stl_DiscoveryScrollViewDidScroll:(UIScrollView *)scrollView;

- (void)stl_DiscoveryScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

- (void)stl_DiscoveryScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;

- (void)stl_DiscoveryScrollViewWillBeginDragging:(UIScrollView *)scrollView;

- (void)stl_DiscoveryScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;

@end

@interface OSSVDiscoveyViewModel : BaseViewModel<CHTCollectionViewDelegateWaterfallLayout,UICollectionViewDelegate,UICollectionViewDataSource, CustomerLayoutDatasource,CustomerLayoutDelegate,WMMenuViewDelegate,
WMMenuViewDataSource>

- (void)requestBannerDatas:(id)parmaters completion:(void (^)(id result, BOOL isCache))completion failure:(void (^)(id))failure;
- (void)requestMenuCategory:(id)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

- (void)loadMenuData:(BOOL)isLaodMore;

@property (nonatomic, weak) id<DiscoveryViewModelDataSource> dataDelegate;
@property (nonatomic, weak) id<DiscoveryViewModelDelegate> discoverDelegate;

@property (nonatomic, weak) UIViewController            *controller;

@property (nonatomic, copy) NSString                    *channelName;
@property (nonatomic, copy) NSString                    *channelName_en;
@property (nonatomic, copy) NSString                    *channel_id;
@property (nonatomic, assign) BOOL                      isCache;
@property (nonatomic, strong) NSMutableDictionary       *analyticsDic;
@property (nonatomic, copy) UpdateHeaderHeightBlock     updateHeaderHeightBlock;

@property (nonatomic, strong) NSMutableArray<id<CustomerLayoutSectionModuleProtocol>> *dataSourceList;



@end
