//
//  OSSVDetailsViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVDetailCollectionLayout.h"
// Model
#import "OSSVCartCheckModel.h"
#import "OSSVDetailsBaseInfoModel.h"
#import "OSSVRecommendArrayModel.h"
#import "OSSVDetailHeaderReviewModel.h"

#import "OSSVGoodsListModel.h"
#import "OSSVDetailsListModel.h"
//#import "CHTCollectionViewWaterfallLayout.h"

#import "OSSVDetailReviewCell.h"
#import "OSSVDetailRecommendHeaderCell.h"
#import "OSSVDetailReviewStarCell.h"
#import "OSSVDetailAdvertiseViewCell.h"

#import "OSSVDetailInfoCell.h"
#import "OSSVDetailServicesCell.h"
#import "OSSVDetailSizeDescCell.h"
#import "OSSVDetailActivityCell.h"
#import "OSSVDetailReviewNewCell.h"
#import "STLGoodsDetailActionSheet.h"
#import "OSSVDetailBottomView.h"
#import "OSSVDetailAnalyticsAOP.h"


@class OSSVDetailsBaseInfoModel;
@class OSSVDetailsViewModel;

typedef NS_ENUM(NSInteger,OSSVDetailsViewModelEvent) {
    /*刷新*/
    OSSVDetailsViewModelEventCollect = 1,
    /*选择商品规格Block*/
    OSSVDetailsViewModelEventSelect,
    /*商品 选择商品服务Block*/
    OSSVDetailsViewModelEventService,
    /*重新操作立即购买功能*/
    OSSVDetailsViewModelEventBuy,
    
    /*商品 选择商品运输时间弹窗*/
    OSSVDetailsViewModelEventTransportTime,
    /**商品 评论列表*/
    OSSVDetailsViewModelEventReview,
    /**商品 Size Chart*/
    OSSVDetailsViewModelEventSizeChart,
    /**商品 Description*/
    OSSVDetailsViewModelEventDescription,
    /**商品 Coins*/
    OSSVDetailsViewModelEventCoins,
    /**商品 满减活动*/
    OSSVDetailsViewModelEventActivityBuy,
    /**商品 闪购活动*/
    OSSVDetailsViewModelEventActivityFlash,
    /**商品 title showAll*/
    OSSVDetailsViewModelEventTitleAll,
};

@protocol OSSVDetailsViewModelDelegate<NSObject>

- (void)STL_OSSVDetailsViewModel:(OSSVDetailsViewModel *)model event:(OSSVDetailsViewModelEvent)event;

-(void)STL_GoodsDetailsHeaderSelectSizeGoodId:(NSString *)goodsId wid:(NSString *)wid selectAttribute:(OSSVAttributeItemModel *)attributeItemModel;

@optional

- (void)STL_GoodsDetailsOperate:(OSSVDetailsViewModel *)model event:(OSSVDetailsViewModelEvent)event content:(id)content;


@end

//@interface OSSVDetailsViewModel : BaseViewModel<CHTCollectionViewDelegateWaterfallLayout,UICollectionViewDataSource>

@interface OSSVDetailsViewModel : BaseViewModel<UICollectionViewDelegate, UICollectionViewDataSource,OSSVDetailCollectionLayoutDatasource >

/////商品列表获取商品详细数据
- (void)requestGoodsListBaseInfo:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

///立即购买
//- (void)requestGoodsCheckNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

/////商品详情推送商品数据
- (void)requestGoodsRecommendsList:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

///买了又买
- (void)requestGoodsBuyAndBuyList:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;

///购物车里面是否有0元商品
- (void)requestCartExit:(NSDictionary *)parmaters completion:(void (^)(BOOL))completion failure:(void (^)(BOOL))failure;


///收藏
- (void)requestCollectAddNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

- (void)requestCollectDelNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure;

///只拿数据
- (void)requestNetworkOnly:(NSDictionary *)parmaters completion:(void (^)(id))completion failure:(void (^)(id))failure;
//评论数据请求
- (void)requestReveiwData;

- (void)configureData:(OSSVDetailsListModel *)model;

@property (nonatomic, strong) NSMutableArray<OSSVGoodsListModel*>  *recommendGoodsArray;
@property (nonatomic, strong) OSSVDetailsListModel                        *detailModel;
@property (nonatomic, weak) id<OSSVDetailsViewModelDelegate>   delegate;
@property (nonatomic, copy) NSString                            *coverImgaeUrl;
@property (nonatomic, weak) STLBaseCtrl                    *controller;
@property (nonatomic, weak) UICollectionView               *weakCollectionView;
@property (nonatomic, weak) OSSVDetailCollectionLayout *weakCollectLayout;

@property (nonatomic, weak) OSSVDetailRecommendHeaderCell *recommendHeaderCell;
@property (nonatomic,weak) OSSVDetailAdvertiseViewCell *advcertiseCell;

///是否已经选择过尺码，
@property (nonatomic, assign) BOOL                              hadManualSelectSize;
@property (nonatomic, assign) NSInteger                         detailSourceType;

@property (nonatomic, strong) NSMutableDictionary               *analyticsDic;
//收藏和取消收藏的回调
@property (nonatomic, copy) void (^collectionBlock)(NSString *isCollection, NSString *goodsId);

@property (nonatomic, assign) BOOL                              isTapSize;// 是否点击了尺码

- (void)scrollRecommendPosition;

- (NSMutableArray <id<OSSVCollectionSectionProtocol>> *)cellSourceDatas;

- (void)callTheCustomToShare;

- (void)addCartEventSuccess:(OSSVDetailsBaseInfoModel *)viewModel status:(BOOL)flag;

-(void)clearRecommendSection;


///外露
@property (nonatomic, strong) OSSVReviewsModel            *detailsReviewsModel;
-(void)reloadReviewsWithoutReques;

@property (weak,nonatomic) STLGoodsDetailActionSheet *detailSizeSheet;

@property (weak,nonatomic) OSSVDetailBottomView *bottomView;

@property (nonatomic, strong) OSSVDetailAnalyticsAOP          *goodsDetailAnalyticsManager;

@end
