//
//  GoodsDetailsViewController.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVDetailsVC.h"
#import "STLWKWebCtrl.h"
#import "OSSVGoodsReviewVC.h"
#import "OSSVFlashSaleMainVC.h"
#import "OSSVMyHelpVC.h"
#import "OSSVWishListVC.h"
#import "STLActivityWWebCtrl.h"
#import "OSSVSearchVC.h"
#import "OSSVCartVC.h"

// View
#import "STLActionSheet.h"
#import "STLGoodsDetailActionSheet.h"
#import "OSSVDetailBottomView.h"
#import "OSSVDetailTopBarView.h"
#import "OSSVDetailServiceDescView.h"
#import "OSSVDetailsHeaderView.h"
#import "OSSVDetailTransportTimePopView.h"
#import "OSSVDetailReviewCell.h"
#import "OSSVDetailRecommendHeaderCell.h"
#import "OSSVDetailReviewStarCell.h"
#import "OSSVDetailRecommendCell.h"
#import "OSSVDetailAdvertiseViewCell.h"
#import "OSSVBuyAndBuyTabView.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "OSSVDetailFastAddCCell.h"
#import "OSSVDetailInfoCell.h"
#import "OSSVDetailServicesCell.h"
#import "OSSVDetailSizeDescCell.h"
#import "OSSVDetailActivityCell.h"
#import "OSSVDetailReviewNewCell.h"
#import "OSSVDetailLoadView.h"
#import "STLAlertMenuView.h"


#import "OSSVDetailCollectionLayout.h"

// ViewModel
#import "OSSVDetailsViewModel.h"
#import "OSSVDetailPictureArrayModel.h"

// Model
#import "CommendModel.h"
#import "OSSVDetailsBaseInfoModel.h"
#import "STLPreference.h"
#import <JHChainableAnimations.h>
#import "STLPopCartAnimation.h"
#import "OSSVSearchingModel.h"

//#ifdef AppsFlyerAnalyticsEnabled
//#import <AppsFlyerLib/AppsFlyerTracker.h>
//#endif
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "OSSVAnalyticsTool.h"
#import "Adorawe-Swift.h"


@interface OSSVDetailsVC ()<OSSVDetailTopBarViewDelegate,OSSVDetailBottomViewDelegate,OSSVDetailsViewModelDelegate>

@property (nonatomic, strong) UIView                               *transformView; //主要是为了上拉选择规格窗口的时候后面的窗口能进行缩放的效果
@property (nonatomic, strong) OSSVDetailTopBarView                *topBarView;
@property (nonatomic, strong) UICollectionView                     *collectionView;
@property (nonatomic, strong) OSSVDetailCollectionLayout       *detailLayout;
@property (nonatomic, strong) OSSVDetailBottomView                *bottomView;
@property (nonatomic, strong) UIButton                             *backToTopBtn; // 置顶按钮
@property (nonatomic, strong) STLGoodsDetailActionSheet            *detailSheet; // 属性选择弹窗
@property (nonatomic, strong) OSSVDetailServiceDescView        *serviceDescView;
@property (nonatomic, strong) OSSVDetailTransportTimePopView   *transportPopView;
//闪购商品信息提示-----底部加购View上面
@property (nonatomic, strong) UILabel                              *bottomLabel;
// ViewModel and Model
@property (nonatomic, strong) OSSVDetailsViewModel                *viewModel;
@property (nonatomic, strong) OSSVDetailsBaseInfoModel      *detailModel;
@property (nonatomic, assign) BOOL                                 hasFirtFlash;
@property (nonatomic, assign) NSInteger                            isCartExit;
@property (nonatomic, strong) NSTimer                              *timer;
@property (nonatomic, assign) NSUInteger                           timeCount;
// GA统计
@property (nonatomic, assign) long long int beginTime;
@property (nonatomic, assign) long long int endTime;
@property (nonatomic, weak) OSSVBuyAndBuyTabView                    *buyAndBuyTabView;
@property (assign,nonatomic) NSInteger                             bottomRequestType;
@property (assign,nonatomic) BOOL                                  isLoadMoreData;
@property (nonatomic, copy) NSString                               *sourceGoodsId;
@property (assign,nonatomic) CGRect                                prevRecommendHeaderFrame;
@property (nonatomic, strong) OSSVDetailLoadView               *detailLoadView;

@property (nonatomic,strong) PrivacySheet              *privacySheet;
@end


typedef struct Test
{
    int a;
    int b;
}Test;

/**
 * 切换上拉属性窗口动画效果 ->0 类似淘宝效果 1 平滑效果
 */
#define CHANGE_ANIMATIONS 1

@implementation OSSVDetailsVC

-(instancetype)init{
    self = [super init];
    self.searchKey = nil;
    self.searchPositionNum = 0;
    return self;
}

#pragma mark - Dealloc
- (void)dealloc {
    [_collectionView removeObserver:self forKeyPath:kColletionContentOffsetName];
    [_collectionView removeFromSuperview];
    for (UIView *view in _collectionView.subviews) {
        [view removeFromSuperview];
    }

    _detailLayout = nil;
    _collectionView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    self.timer = nil;
    STLPreference.isFirstIntoDetails = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.firstEnter) {
        self.firstEnter = YES;
    }
    /*获取View将要出现时的时间戳*/
    [self hitsAnalyticsBegin];
    
    ///1.4.6 隐私
    if (![[STLPreference objectForKey:@"noNeedShowPrivacy"] boolValue] && [OSSVAccountsManager sharedManager].sysIniModel.is_show_privacy) {
        [self.privacySheet showInParentView:self.view bottomAncher:self.bottomView offset:@12];
    }

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    ///1.3.8 埋点 进入页面会默认展示推荐列表
    NSString *pageName = [UIViewController currentTopViewControllerPageName];
    NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                 @"attr_node_1":@"other",
                                 @"attr_node_2": @"you_may_also_like",
    };
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDic];
    
    //数据GA埋点曝光 广告点击
                        
                        // item
                        NSMutableDictionary *item = [@{
                    //          kFIRParameterItemID: $itemId,
                    //          kFIRParameterItemName: $itemName,
                    //          kFIRParameterItemCategory: $itemCategory,
                    //          kFIRParameterItemVariant: $itemVariant,
                    //          kFIRParameterItemBrand: $itemBrand,
                    //          kFIRParameterPrice: $price,
                    //          kFIRParameterCurrency: $currency
                        } mutableCopy];


                        // Prepare promotion parameters
                        NSMutableDictionary *promoParams = [@{
                    //          kFIRParameterPromotionID: $promotionId,
                    //          kFIRParameterPromotionName:$promotionName,
                    //          kFIRParameterCreativeName: $creativeName,
                    //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                    //          @"screen_group":@"Home"
                        } mutableCopy];

                        // Add items
                        promoParams[kFIRParameterItems] = @[item];
                        
                    //        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [STLAlertMenuView removeMenueView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [OSSVThemesColors col_F5F5F5];
    self.fd_prefersNavigationBarHidden = YES;
    self.viewModel.coverImgaeUrl = self.coverImageUrl;
    
    self.detailLoadView.imagUrl = self.coverImageUrl;
    [self requestHotSearchWords];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGoodDetailData) name:kNotif_GoodsDetailReloadData object:Nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeTapUpdateGoodDetailData:) name:kNotif_GoodsDetailSizeTap object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorTapUpdateGoodDetailData:) name:kNotif_GoodsDetailColorTap object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeValue:) name:kNotif_CartBadge object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateGoodDetailData) name:kNotif_Login object:nil];

    self.sourceGoodsId = self.goodsId;
    [self initView];
    self.topBarView.cartNumber = [[OSSVCartsOperateManager sharedManager] cartValidGoodsAllCount];
    [self requesData:self.goodsId wid:self.wid recommend:YES];
    
    if (@available(iOS 11.0, *)) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:kGoodsDetailTime];
    [defaults synchronize];
    
    self.isLoadMoreData = YES;
    
}

#pragma mark ---请求热搜词， 用于顶部搜索框文案滚动
- (void)requestHotSearchWords {
    
    NSString *groupId = @"index";
    OSSVHotsSearchsWordsAip *api = [[OSSVHotsSearchsWordsAip alloc] initWithGroupId:groupId cateId:@""];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        
        if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200){
            
            self.topBarView.eventView.hotWordsArray = [NSArray yy_modelArrayWithClass:[OSSVHotsSearchWordsModel class] json:requestJSON[kResult]];

        }else{
            
            [HUDManager showHUDWithMessage:requestJSON[@"message"]];
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkNotAvailable", nil)];
    }];
}

#pragma mark - MakeUI
- (void)initView {
    /*底层缩放效果展示*/
    [self.view addSubview:self.transformView];
    [self.view addSubview:self.detailLoadView];
    [self.view addSubview:self.topBarView];
    [self.view addSubview:self.backToTopBtn];
    [self.view bringSubviewToFront:self.backToTopBtn];
    [self.view addSubview:self.serviceDescView];
    [self.view addSubview:self.transportPopView];
    
    [self.transformView addSubview:self.collectionView];
    [self.transformView addSubview:self.bottomView];
    [self.transformView addSubview:self.bottomLabel];

    [self.detailLoadView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE == 3) {
            make.leading.trailing.bottom.equalTo(0);
            make.top.equalTo(self.view.mas_topMargin);
        }else{
            make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
        }
        
    }];
    
    
    [self.transformView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.transformView.mas_bottom).mas_offset(0);
        make.leading.trailing.mas_equalTo(self.transformView);
        make.height.mas_equalTo(kIS_IPHONEX ? 60 + 37 : 60);
    }];
    [self.bottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.transformView);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
        make.height.mas_equalTo(32);
    }];
    
    [self.topBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.height.mas_equalTo(kIS_IPHONEX ? (40 + 45) : (40 + 20));
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE == 3) {
            make.top.equalTo(self.view.mas_topMargin);
        }else{
            make.top.equalTo(self.view);
        }
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];
    
    
    [self.backToTopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(kIS_IPHONEX ? 90 : 80);
        make.trailing.mas_equalTo(-10);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    OSSVBuyAndBuyTabView *recommendTabView = [[OSSVBuyAndBuyTabView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:recommendTabView];
    recommendTabView.backgroundColor = [UIColor whiteColor];
    recommendTabView.alpha = 0.0;
    _buyAndBuyTabView = recommendTabView;
    [recommendTabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topBarView.mas_bottom);
        make.height.mas_equalTo(44);
        make.leading.trailing.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.detailSheet];
        
    @weakify(self)
    [[NSNotificationCenter defaultCenter] addObserverForName:STLBuyAndBuySwitchNotifiName object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(self)
        OSSVBuyAndBuyTabView *srcTabView = note.object;
        NSInteger index = [note.userInfo[@"index"] integerValue];
        if (srcTabView != self.buyAndBuyTabView) {
            self.buyAndBuyTabView.currentIndex = index;
        }
        
        if (index == self.bottomRequestType) {
            return;
        }
        ///清理原数据
        [self.viewModel clearRecommendSection];
        ///切换tab 切换数据源
        self.bottomRequestType = index;
        self.isLoadMoreData = NO;
        [self.collectionView.mj_footer beginRefreshingWithCompletionBlock:^{
            self.isLoadMoreData = YES;
        }];
        
        CGRect recommendHeaderFrame = [self.collectionView convertRect:self.viewModel.recommendHeaderCell.frame toView:self.collectionView.superview];
        CGFloat topMargin = kIS_IPHONEX ? 84 : 60;
        if (recommendHeaderFrame.origin.y < topMargin) {
            CGRect target = CGRectOffset(self.viewModel.recommendHeaderCell.frame, 0, -topMargin);
            [self.collectionView scrollRectToVisible:target animated:YES];
        }else{
            
        }
        
        ///1.3.8 埋点
        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                     @"attr_node_1":@"other",
                                     @"attr_node_2": index == 0 ? @"you_may_also_like" : @"often_bought_with",
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDic];
        
        [GATools logListNavigationWithNavigation:index == 0 ? @"you_may_also_like" : @"often_bought_with"
                                     screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsTitle)]
                                        position:@"ProductDetail_Recommend"];
        
        //数据GA埋点曝光 广告点击
                            
                            // item
                            NSMutableDictionary *item = [@{
                        //          kFIRParameterItemID: $itemId,
                        //          kFIRParameterItemName: $itemName,
                        //          kFIRParameterItemCategory: $itemCategory,
                        //          kFIRParameterItemVariant: $itemVariant,
                        //          kFIRParameterItemBrand: $itemBrand,
                        //          kFIRParameterPrice: $price,
                        //          kFIRParameterCurrency: $currency
                            } mutableCopy];


                            // Prepare promotion parameters
                            NSMutableDictionary *promoParams = [@{
                        //          kFIRParameterPromotionID: $promotionId,
                        //          kFIRParameterPromotionName:$promotionName,
                        //          kFIRParameterCreativeName: $creativeName,
                        //          kFIRParameterCreativeSlot: @"Top Banner_"+$index,
                        //          @"screen_group":@"Home"
                            } mutableCopy];

                            // Add items
                            promoParams[kFIRParameterItems] = @[item];
                            
                        //        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
        
    }];
}


#pragma mark - Request----请求商品详情数据
//1,请求是否存在0元商品
- (void)requesData:(NSString*)goodsId wid:(NSString*)wid recommend:(BOOL)recommend {
    @weakify(self)
    [self.viewModel requestCartExit:@{@"wid":STLToString(wid),@"goods_id":STLToString(goodsId)} completion:^(BOOL isExit) {
        @strongify(self)
        self.isCartExit = isExit;
        [self requesDetailData:goodsId wid:wid recommend:recommend];
    } failure:^(BOOL isExit) {
        @strongify(self)
        self.isCartExit = isExit;
        [self requesDetailData:goodsId wid:wid recommend:recommend];
    }];
}

//2,请求详情数据
- (void)requesDetailData:(NSString*)goodsId wid:(NSString*)wid recommend:(BOOL)recommend {
    self.viewModel.goodsDetailAnalyticsManager.needLogGoodsImpression = NO;
    @weakify(self)
    NSDictionary *dic = dic = @{@"goods_id":STLToString(goodsId),
                                @"loadState":STLRefresh,
                                @"wid":STLToString(wid),
                                @"specialId":STLToString(self.specialId)};
    self.viewModel.detailSourceType = self.sourceType;
    
    [self.viewModel requestNetwork:dic completion:^(OSSVDetailsBaseInfoModel *obj) {
        @strongify(self)
        self.detailLoadView.hidden = YES;
        if (!self.viewModel.weakCollectionView) {
            self.viewModel.weakCollectionView = self.collectionView;
            self.viewModel.weakCollectLayout = self.detailLayout;
        }
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            
           
            
            [GATools logGoodsViewItemWithScreenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(obj.goodsTitle)]
                                               value:obj.shop_price
                                               items:@[
                
                [[GAEventItems alloc] initWithItem_id:STLToString(obj.goodsId)
                                            item_name:STLToString(obj.goodsTitle)
                                           item_brand:[OSSVLocaslHosstManager appName]
                                        item_category:STLToString(obj.cat_name)
                                         item_variant:@"" price:STLToString(obj.shop_price)
                                             quantity:@(1)
                                             currency:@"USD" index:nil]
                ]
            ];
            
            self.goodsId = obj.goodsId;
            self.wid = obj.goodsWid;
            
            //后面对标题进行了处理
            if (STLIsEmptyString(self.specialId)) {
                [self saveCommend:obj];
            }
            
            //v1.4.4这个不需要了，在请求viewmodel里处理，需要的是sku了
//            NSMutableDictionary *dic = @{kAnalyticsAOPSourceID:STLToString(self.goodsId)}.mutableCopy;
//            [dic addEntriesFromDictionary:self.transmitMutDic];
//            self.viewModel.analyticsDic = dic;

            self.detailModel = obj;
            self.currentPageCode = STLToString(obj.goods_sn);
            
            if (STLJudgeNSArray(obj.GoodsSpecs)) {
                for (OSSVSpecsModel *specsModel in obj.GoodsSpecs) {
                    if ([specsModel.spec_type integerValue] == 1 && specsModel.brothers.count > 0) {
                        obj.isHasColorItem = YES;
                    }
                    if ([specsModel.spec_type integerValue] == 2 && specsModel.brothers.count > 0) {
                        obj.isHasSizeItem = YES;
                    }
                }
            }
            for (OSSVSpecsModel *specsModel in obj.GoodsSpecs) {
                if (!obj.isHasColorItem || !obj.isHasSizeItem) {
                    specsModel.isSelectSize = YES;
//                    self.viewModel.isTapSize = YES;
                }else{
                    specsModel.isSelectSize = self.viewModel.isTapSize;
                }
            }
            
            // 0 > 闪购 > 满减
            if (STLIsEmptyString(self.detailModel.specialId) && self.detailModel.flash_sale && !STLIsEmptyString(self.detailModel.flash_sale.active_discount) && [self.detailModel.flash_sale.active_discount floatValue] > 0) {
                if (!self.hasFirtFlash) {
                    self.hasFirtFlash = YES;
                }
            }
            if (![OSSVNSStringTool isEmptyString:self.specialId] && [self.detailModel.shop_price integerValue] == 0) {
                self.detailModel.cart_exists = self.isCartExit;
                self.detailSheet.cart_exits = self.detailModel.cart_exists;
            }else{
                self.detailModel.cart_exists = 0;
                self.detailSheet.cart_exits = 0;
            }
            
//            self.detailSheet.cart_exits = self.detailModel.cart_exists;
            self.detailSheet.hasFirtFlash = self.hasFirtFlash;
            self.detailSheet.analyticsDic = self.viewModel.analyticsDic;
            self.detailSheet.baseInfoModel = obj;
            [self.viewModel configureData:self.viewModel.detailModel];
            [self.collectionView reloadData];
            [self updateTopBarGoodsImg];
          
            
            /*请求成功数据才让按钮可点击*/
            self.bottomLabel.hidden = YES;
            self.bottomView.enableCart = YES;
            if ([obj.shield_status integerValue] == 1) {
                self.bottomView.enableCart = NO;
            } else if (!STLIsEmptyString(obj.spuOnSale) && obj.spuOnSale.intValue == 0 && self.viewModel.isTapSize) {
                self.bottomView.enableCart = NO;
                self.bottomLabel.hidden = NO;
                self.bottomLabel.text = STLLocalizedString_(@"supNotOnSale", nil);
            } else if (!STLIsEmptyString(obj.spuGoodsNumber) && obj.spuGoodsNumber.intValue == 0 && self.viewModel.isTapSize) {
                self.bottomView.enableCart = NO;
                self.bottomLabel.hidden = NO;
                self.bottomLabel.text = STLLocalizedString_(@"spuSaleOut", nil);
            }else if (!STLIsEmptyString(obj.goodsNumber) && obj.goodsNumber.intValue == 0 && self.viewModel.isTapSize){
                self.bottomView.enableCart = NO;
                self.bottomLabel.hidden = NO;
                self.bottomLabel.text = STLLocalizedString_(@"spuSaleOut", nil);
            }
            
            if (!obj.isOnSale) {
                self.bottomView.enableCart = NO;
            }
            
            if([obj.goodsNumber isEqualToString:@"0"]){
                self.bottomView.enableCart = NO;
            }
            
            if (STLIsEmptyString(self.specialId) && obj.flash_sale && [obj.flash_sale.active_status integerValue] == 1 && ![obj.flash_sale.is_can_buy isEqualToString:@"1"] && !STLIsEmptyString(obj.flash_sale.buy_notice)) {
                self.bottomLabel.hidden = YES;
            }
            
            self.bottomView.hidden = NO;
            
            //商详页 服务信息以及 运输时间赋值
            [self.serviceDescView updateServices:obj];
            [self.transportPopView updateTransportTimeList:obj];
            
            
            
            self.collectionView.mj_footer.hidden = NO;
            if (self.viewModel.recommendGoodsArray.count % 10) {
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
            //评论数据请求
            ///1.4.6 只请求一次
            if (self.viewModel.detailsReviewsModel == nil) {
                [self.viewModel requestReveiwData];
            }else{
                [self.viewModel reloadReviewsWithoutReques];
            }
            
            if (recommend) {
                [self requestCommendData:NO];
            }
        }
        
        self.bottomView.userInteractionEnabled = YES;
    } failure:^(id obj) {
        self.detailLoadView.hidden = YES;
        self.collectionView.mj_footer.hidden = YES;
        self.bottomView.userInteractionEnabled = YES;
    }];
}

#pragma mark ----底部商品加载更多
- (void)requestCommendData:(BOOL)isLoadMore {
    @weakify(self)
    NSDictionary *dic = @{@"goods_id":STLToString(self.detailModel.goodsId),
                          @"loadState":isLoadMore ? STLLoadMore : STLRefresh,
                                @"wid":STLToString(self.detailModel.goodsWid),
                                @"specialId":STLToString(self.specialId)};
    
   
    [self.viewModel requestGoodsRecommendsList:dic completion:^(OSSVDetailsListModel *obj) {
        @strongify(self)
        
        [self.collectionView.mj_footer endRefreshing];
        if (obj && [obj isKindOfClass:[OSSVDetailsListModel class]]) {
            self.viewModel.goodsDetailAnalyticsManager.needLogGoodsImpression = YES;
            [self.collectionView reloadData];
            
            OSSVDetailsListModel *goodsListModel = (OSSVDetailsListModel *)obj;
            if (goodsListModel.recommend.goodList.count >= goodsListModel.recommend.totalCount) {
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        
    } failure:^(id obj) {
        @strongify(self)
//        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
        [self.collectionView.mj_footer endRefreshing];
    }];
}

#pragma mark ----底部商品加载更多 买了又买
- (void)requestBuyAndBuyData:(BOOL)isLoadMore {
    @weakify(self)
    NSDictionary *dic = @{@"sku":STLToString(self.detailModel.goods_sn),
                          @"loadState":isLoadMore ? STLLoadMore : STLRefresh,
                        };
    
    
    [self.viewModel requestGoodsBuyAndBuyList:dic completion:^(id obj) {
        @strongify(self)
        
        [self.collectionView.mj_footer endRefreshing];
        NSArray *goodList = (NSArray *)(obj[@"arr"]);
        NSInteger total = [obj[@"total"] integerValue];
        if (goodList) {
            [self.collectionView reloadData];
            if (goodList.count >= total) {
                [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        
    } failure:^(id obj) {
        @strongify(self)
        [self.collectionView.mj_footer endRefreshing];
//        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    }];
}

#pragma mark - Action

#pragma mark 返回

- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 分享

- (void)shareGoods {
    if (![OSSVAccountsManager sharedManager].isSignIn) {
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.modalBlock = ^{
            @strongify(self)
            [self.viewModel callTheCustomToShare];
        };
        [self presentViewController:signVC animated:YES completion:nil];

    } else {
        [self.viewModel callTheCustomToShare];
    }
    
}
#pragma mark 首页

- (void)showMoreMenu {
    [GATools logGoodsDetailSimpleEventWithEventName:@"go_to_otherScreen"
                                        screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsTitle)]
                                         buttonName:@"ScreenFold"];
    
    CGRect soureceRect = [STLAlertMenuView sourceViewFrameToWindow:self.topBarView.eventView.moreButton];
    STLAlertMenuView *menuView = [[STLAlertMenuView alloc] initTipArrowOffset:soureceRect.size.width / 2.0
                                                                       direct:[OSSVSystemsConfigsUtils isRightToLeftShow] ? STLMenuArrowDirectUpLeft : STLMenuArrowDirectUpRight
                                                                       images:@[@"more_home",@"more_collect",@"more_help"]
                                                                       titles:@[STLLocalizedString_(@"Homepage", nil),STLLocalizedString_(@"My_WishList", nil),STLLocalizedString_(@"Help", nil)]];
    
    @weakify(self)
    menuView.selectBlock = ^(NSInteger index) {
        @strongify(self);
        if (index == 0) {
            [GATools logGoodsDetailSimpleEventWithEventName:@"go_to_otherScreen"
                                                screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsTitle)]
                                                 buttonName:@"Homepage"];
            [self goHome];
        } else if(index == 1) {
            [GATools logGoodsDetailSimpleEventWithEventName:@"go_to_otherScreen"
                                                screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsTitle)]
                                                 buttonName:@"WishList"];
            [self actionCollect];
        } else if(index == 2) {
            [GATools logGoodsDetailSimpleEventWithEventName:@"go_to_otherScreen"
                                                screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsTitle)]
                                                 buttonName:@"Help"];
            [self actionHelp];
        }
    };
    
    [menuView showSourceView:self.topBarView.eventView.moreButton];
}

//帮助中心
- (void)actionHelp {
    OSSVMyHelpVC *helpVC = [[OSSVMyHelpVC alloc] init];
    [self.navigationController pushViewController:helpVC animated:YES];
}
//收藏
- (void)actionCollect {
    if (![OSSVAccountsManager sharedManager].isSignIn) {
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.modalBlock = ^{
            @strongify(self)
            [self jumpToWishListVc];
        };
        [self presentViewController:signVC animated:YES completion:nil];
        
    } else {
        [self jumpToWishListVc];
    }
}
-(void)jumpToWishListVc {

    OSSVWishListVC *couponVC = [[OSSVWishListVC alloc] init];
    [self.navigationController pushViewController:couponVC animated:YES];

}
- (void)goHome {
    OSSVTabBarVC *tabbar = (OSSVTabBarVC *)self.tabBarController;
    [tabbar setModel:STLMainMoudleHome];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark 客服
- (void)connectChat {
}

#pragma mark 回到顶部
- (void)scrollerToTop {
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
}

#pragma mark 进入购物车

- (void)goToCart {
    [GATools logJumpToBagWithScreenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsTitle)]];
    OSSVCartVC *cartView = [OSSVCartVC new];
    [self.navigationController pushViewController:cartView animated:YES];
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
           @"screen_group":[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsTitle)],
           @"button_name":@"Cart"}];
}

#pragma mark 加入购物车----弹窗

- (void)showTheSelectedView:(NSInteger) type {
    
    [self.detailSheet addCartAnimationTop:0 moveLocation:CGRectZero showAnimation:NO];
#if CHANGE_ANIMATIONS
    [UIView animateWithDuration: 0.25 animations: ^{
//        self.transformView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.85, 0.85);
        [_detailSheet shouAttribute];
        _detailSheet.type = type;
    } completion: nil];
#else
    [UIView animateWithDuration:0.2 animations:^{
        self.transformView.layer.transform = [self firstStepTransform];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.transformView.layer.transform = [self secondStepTransform];
            [_detailSheet show];
            _detailSheet.type = type;
        }];
    }];
#endif
}

#pragma mark 隐藏属性弹窗

-(void)restoreTransform {
    
#if CHANGE_ANIMATIONS
//    [UIView animateWithDuration: 0.25 animations: ^{
//        self.transformView.transform = CGAffineTransformIdentity;
//    } completion: nil];
#else
    [UIView animateWithDuration:0.3 animations:^{
        self.view.layer.transform = [self firstStepTransform];
//        self.transformView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
        }];
    }];
#endif
}

#pragma mark - 弹出和隐藏 服务信息

- (void)showServiceView{
    
#if CHANGE_ANIMATIONS
    [UIView animateWithDuration: 0.25 animations: ^{
//        self.transformView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.85, 0.85);
        [_serviceDescView show];
    } completion: nil];
#else
    [UIView animateWithDuration:0.2 animations:^{
        self.transformView.layer.transform = [self firstStepTransform];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.transformView.layer.transform = [self secondStepTransform];
            [_serviceDescView show];
        }];
    }];
#endif
}

-(void)hideServiceTransform {
    
}

#pragma mark - 弹出和隐藏 运输时长popView
- (void)showTransportTimePopView {
    
#if CHANGE_ANIMATIONS
    [UIView animateWithDuration: 0.25 animations: ^{
//        self.transformView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.85, 0.85);
        [self.transportPopView show];
    } completion: nil];
#else
    [UIView animateWithDuration:0.2 animations:^{
        self.transformView.layer.transform = [self firstStepTransform];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self.transformView.layer.transform = [self secondStepTransform];
            [self.transportPopView show];
        }];
    }];
#endif
}

- (void)dismissTransportTimeView {
#if CHANGE_ANIMATIONS
//    [UIView animateWithDuration: 0.25 animations: ^{
//        self.transformView.transform = CGAffineTransformIdentity;
//    } completion: nil];
#else
    [UIView animateWithDuration:0.3 animations:^{
        self.view.layer.transform = [self firstStepTransform];
        self.transportPopView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
        }];
    }];
#endif
}


- (void)closeAddCartSuccessPopView {
    
#if CHANGE_ANIMATIONS
//    [UIView animateWithDuration: 0.25 animations: ^{
//        self.transformView.transform = CGAffineTransformIdentity;
//    } completion: nil];
    //弹窗关闭时候  释放计时器
    [self.timer invalidate];
#else
    [UIView animateWithDuration:0.3 animations:^{
        self.view.layer.transform = [self firstStepTransform];
        self.successPopView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.view.layer.transform = CATransform3DIdentity;
        } completion:^(BOOL finished) {
        }];
    }];
    
#endif
}
// animation
- (CATransform3D)firstStepTransform {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 1.0 / -500.0;
    transform = CATransform3DScale(transform, 0.98, 0.98, 1.0);
    transform = CATransform3DRotate(transform, 5.0 * M_PI / 180.0, 1, 0, 0);
    transform = CATransform3DTranslate(transform, 0, 0, -30.0);
    return transform;
}

- (CATransform3D)secondStepTransform {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = [self firstStepTransform].m34;
    transform = CATransform3DTranslate(transform, 0, SCREEN_HEIGHT * -0.08, 0);
    transform = CATransform3DScale(transform, 0.8, 0.8, 1.0);
    return transform;
}

#pragma mark 保存足迹

- (void)saveCommend:(OSSVDetailsBaseInfoModel *)obj{
    CommendModel *commendModel = [CommendModel new];
    commendModel.goodsId = obj.goodsId;
    commendModel.goodsSn = obj.goods_sn;
    commendModel.goodsGroupId = obj.goodsGroupId;
    commendModel.goodsTitle = obj.goodsTitle;
    commendModel.shop_price = obj.shop_price_origin;
    commendModel.goodsPrice = obj.goodsMarketPrice;
//    commendModel.goodsAttr = obj.goodsAttr;
    commendModel.goodsThumb = obj.goodsImg;
    commendModel.coverImgUrl = _coverImageUrl;
    commendModel.goodsBigImg = obj.goodsBigImg;
    //仓库
//    commendModel.warehouseCode = obj.warehouseCode;
    commendModel.wid = obj.goodsWid;
    commendModel.cat_id = obj.cat_id;
    commendModel.cat_name = obj.cat_name;
    commendModel.shop_price_converted = STLToString(obj.shop_price_converted);
    commendModel.market_price_converted = STLToString(obj.market_price_converted);
    BOOL result = [[OSSVCartsOperateManager sharedManager] saveCommend:commendModel];
    if (result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_GoodsDetailCommend object:nil];
    }
}

#pragma mark - Notifications
- (void)changeValue:(NSNotification *)notify {
    self.topBarView.cartNumber = [[OSSVCartsOperateManager sharedManager] cartValidGoodsAllCount];
}

#pragma mark - OSSVDetailTopBarViewDelegate

- (void)OSSVDetailTopBarViewEvent:(GoodsDetailTopBarEvent)topEvent {
    if (topEvent == GoodsDetailTopBarEventBack) {
        [self goBack];
    } else if (topEvent == GoodsDetailTopBarEventCart) {
//        [self shareGoods];
        [self goToCart];
    } else if (topEvent == GoodsDetailTopBarEventMore) {
        [self showMoreMenu];
    }
}

#pragma mark - OSSVDetailBottomViewDelegate------底部视图代理方法（加入购物车和 进入购物车）

- (void)goodsDetailBottomEvent:(GoodsDetailBottomEvent)bottomEvent {
    OSSVDetailsBaseInfoModel *baseInfoModel = self.viewModel.detailModel.goodsBaseInfo;
    if (bottomEvent == GoodsDetailBottomEventCart) {
        [self goToCart];
        
    } else if (bottomEvent == GoodsDetailBottomEventAddCart) {
        
        [GATools logEventWithGoodsListWithEventName:@"add_to_cart"
                                        screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsTitle)]
                                           position:@"Product Detail_Button"
                                              value:STLToString(self.detailModel.shop_price)
                                              items:@[
            [[GAEventItems alloc] initWithItem_id:STLToString(self.detailModel.goodsId)
                                        item_name:STLToString(self.detailModel.goodsTitle)
                                       item_brand:[OSSVLocaslHosstManager appName]
                                    item_category:STLToString(self.detailModel.cat_name)
                                     item_variant:@""
                                            price:STLToString(self.detailModel.shop_price)
                                         quantity:@(1) currency:@"USD" index:nil]
        ]];
        
        //加入购物车
        @weakify(self)
        self.collectionView.userInteractionEnabled = NO;
        [self.viewModel requestCartExit:@{@"wid":STLToString(self.wid),@"goods_id":STLToString(self.goodsId)} completion:^(BOOL isExit) {
            @strongify(self)
            self.collectionView.userInteractionEnabled = YES;
            self.isCartExit = isExit;
            [self addToBagJudgeActionWithModel:baseInfoModel];
        } failure:^(BOOL isExit) {
            @strongify(self)
            self.collectionView.userInteractionEnabled = YES;
            self.isCartExit = isExit;
            [self addToBagJudgeActionWithModel:baseInfoModel];
        }];
        
    } else if (bottomEvent == GoodsDetailBottomEventChat) {
        [self connectChat];
    }else if(bottomEvent == GoodsDetailBottomEventSubscribeAlert){
        [ArrivalSubScribManager.shared showArrivalAlertWithGoodsInfo:baseInfoModel];
    }
}

// 加入购物车逻辑

- (void)addToBagJudgeActionWithModel:(OSSVDetailsBaseInfoModel *)baseInfoModel{
//    self.isCartExit = baseInfoModel.cart_exists;
    NSArray *upperTitle = @[STLLocalizedString_(@"no",nil).uppercaseString,STLLocalizedString_(@"yes", nil).uppercaseString];
    NSArray *lowserTitle = @[STLLocalizedString_(@"no",nil),STLLocalizedString_(@"yes", nil)];

    if (self.viewModel.hadManualSelectSize || self.viewModel.isTapSize) {///手动选择后

        if (baseInfoModel.specialId && [baseInfoModel.shop_price integerValue] == 0 && self.isCartExit) {
            NSString *msg = STLLocalizedString_(@"switchFreeItem", nil);
            [STLALertTitleMessageView alertWithAlerTitle:@"" alerMessage:STLToString(msg) otherBtnTitles:APP_TYPE == 3 ? lowserTitle : upperTitle otherBtnAttributes:nil alertCallBlock:^(NSInteger buttonIndex, NSString *title) {
                if (buttonIndex == 1) {
                    [self actionAddCart];
                }
            }];
            return;
        }
        [self actionAddCart];
    }else if(!baseInfoModel.isHasColorItem && !baseInfoModel.isHasSizeItem){///没有颜色且没有尺码
        if (baseInfoModel.specialId && [baseInfoModel.shop_price integerValue] == 0 && self.isCartExit) {
            NSString *msg = STLLocalizedString_(@"switchFreeItem", nil);
            [STLALertTitleMessageView alertWithAlerTitle:@"" alerMessage:STLToString(msg) otherBtnTitles:APP_TYPE == 3 ? lowserTitle : upperTitle otherBtnAttributes:nil alertCallBlock:^(NSInteger buttonIndex, NSString *title) {
                if (buttonIndex == 1) {
                    [self actionAddCart];
                }
            }];
            return;
        }
        [self actionAddCart];
    }else if(baseInfoModel.isHasColorItem && !baseInfoModel.isHasSizeItem){ ///有颜色没有尺码
        [self actionAddCart];
    }
    else {
    
//        1.2.8之后 不弹出属性弹窗
        [self showTheSelectedView:DetailSheetEnumType];
    }
}

#pragma mark - OSSVDetailsViewModelDelegate

#pragma mark - OSSVDetailBaseCellDelegate

- (void)STL_GoodsDetailsOperate:(OSSVDetailsViewModel *)model event:(OSSVDetailsViewModelEvent)event content:(id)content {
    
    if (event == OSSVDetailsViewModelEventTitleAll) {
        [self goodsOperate:model titleShowAll:[content boolValue]];
        
    } else if(event == OSSVDetailsViewModelEventReview) {
        [self goodsOperate:model review:YES];
        
    } else if(event == OSSVDetailsViewModelEventCoins) {
        [self goodsOperate:model coinsTip:YES];
    }
    else if(event == OSSVDetailsViewModelEventActivityFlash) {
        [GATools logGoodsActivityActionWithEventName:@"promotion_entrance"
                                              action:[NSString stringWithFormat:@"Promotion_%@",STLToString(self.detailModel.flash_sale.label)]
                                         screenGroup:[NSString stringWithFormat:@"ProductDetail_%@",STLToString(self.detailModel.goodsTitle)]];
        OSSVFlashSaleMainVC *flashSaleVc = [[OSSVFlashSaleMainVC alloc] init];
        flashSaleVc.channelId = content;
        [self.navigationController pushViewController:flashSaleVc animated:YES];
        
    } else if(event == OSSVDetailsViewModelEventActivityBuy) {
        
        [self goodsOperate:model activityBuy:content];
        
    } else if(event == OSSVDetailsViewModelEventTransportTime) {
        [self showTransportTimePopView];
        
    } else if (event == OSSVDetailsViewModelEventCollect) {
        self.detailSheet.baseInfoModel = self.viewModel.detailModel.goodsBaseInfo;
        [self.collectionView reloadData];
        
    } else if (event == OSSVDetailsViewModelEventService) {
        [self showServiceView];
        
   } else if (event == OSSVDetailsViewModelEventBuy) {
       [self.detailSheet buyItNow];
       
   } else if (event == OSSVDetailsViewModelEventDescription) {
       [self goodsOperate:model description:content];
       
   } else if (event == OSSVDetailsViewModelEventSizeChart) {
       [self goodsOperate:model sizeChart:content];
   }
    
}

- (void)goodsOperate:(OSSVDetailsViewModel *)model sizeChart:(OSSVSpecsModel *)sizeModel {
    
    STLActivityWWebCtrl *webViewController = [STLActivityWWebCtrl new];
    webViewController.strUrl = STLToString(sizeModel.size_chart_url);
    webViewController.isIgnoreWebTitle = YES;
    webViewController.isModalPresent = YES;
    webViewController.title = STLToString(sizeModel.size_chart_title);
    webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    
    OSSVNavigationVC *nav = [[OSSVNavigationVC alloc] initWithRootViewController:webViewController];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
}


- (void)goodsOperate:(OSSVDetailsViewModel *)model description:(NSString *)url {
    
    STLActivityWWebCtrl *webViewController = [STLActivityWWebCtrl new];
    webViewController.strUrl = url;
    webViewController.title = STLLocalizedString_(@"description",nil);
    webViewController.isModalPresent = YES;
    WINDOW.backgroundColor = [OSSVThemesColors stlBlackColor];
    
    OSSVNavigationVC *nav = [[OSSVNavigationVC alloc] initWithRootViewController:webViewController];
    nav.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)goodsOperate:(OSSVDetailsViewModel *)model review:(BOOL)flag{
    //评论列表
    OSSVGoodsReviewVC *reviewsViewController = [OSSVGoodsReviewVC new];
    reviewsViewController.sku = model.detailModel.goodsBaseInfo.goods_sn;
    reviewsViewController.goodsId = model.detailModel.goodsBaseInfo.goodsId;
    reviewsViewController.spu = model.detailModel.goodsBaseInfo.virtual_spu;
    [self.navigationController pushViewController:reviewsViewController animated:YES];
}

- (void)goodsOperate:(OSSVDetailsViewModel *)model activityBuy:(OSSVBundleActivityModel *)activityModel {
    //满减活动
    if (activityModel && [activityModel isKindOfClass:[OSSVBundleActivityModel class]]) {
        
        OSSVBundleActivityModel *model = (OSSVBundleActivityModel *)activityModel;
        OSSVAdvsEventsModel *advEventModel = [[OSSVAdvsEventsModel alloc] init];
        advEventModel.actionType =  AdvEventTypeNativeCustom;
        advEventModel.url = STLToString(model.activeId);
        advEventModel.name = STLToString(model.activeName);
        if ([advEventModel.url intValue] > 0) { //新增判断，activeId > 0 才能跳转
            [OSSVAdvsEventsManager advEventTarget:self withEventModel:advEventModel];
        }
    }
    
}

- (void)goodsOperate:(OSSVDetailsViewModel *)model titleShowAll:(BOOL )showAll {
    //标题显示更多
    if (model.detailModel.goodsBaseInfo.isShowTitleMore) {
        model.detailModel.goodsBaseInfo.isShowLess = showAll;
        [self.collectionView reloadData];
    }
   
}
- (void)goodsOperate:(OSSVDetailsViewModel *)model coinsTip:(BOOL)flag {
    //金币提示
    OSSVDetailsBaseInfoModel *baseInfoModel = model.detailModel.goodsBaseInfo;
    
    if (baseInfoModel) {
        [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentLeft isAr:YES showHeightIndex:0 title:@"" message:[NSString cashBackHeadline] buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"confirm",nil)]: @[STLLocalizedString_(@"confirm",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
        }];
    }
}


#pragma mark
- (void)actionAddCart {
    
    OSSVDetailsBaseInfoModel *baseInfoModel = self.viewModel.detailModel.goodsBaseInfo;
    CartModel *cartModel = [CartModel new];
    cartModel.goodsId = baseInfoModel.goodsId;
    cartModel.goods_sn = baseInfoModel.goods_sn;
    cartModel.cat_name = baseInfoModel.cat_name;
    cartModel.marketPrice = baseInfoModel.goodsMarketPrice;
    cartModel.goodsName = baseInfoModel.goodsTitle;
    cartModel.goodsThumb = baseInfoModel.goodsSmallImg;
    cartModel.goodsNumber = 1;
    cartModel.goodsPrice = baseInfoModel.shop_price;
    cartModel.isFavorite = baseInfoModel.isCollect;
    cartModel.wid = baseInfoModel.goodsWid;
//            cartModel.warehouseCode = self.baseInfoModel.warehouseCode;
    cartModel.stateType = CartGoodsOperateTypeAdd;
//            cartModel.goodsAttr = self.baseInfoModel.goodsAttr;
//            cartModel.warehouseName = self.baseInfoModel.warehouseName;
    cartModel.goodsStock = baseInfoModel.goodsNumber;
    cartModel.isOnSale = baseInfoModel.isOnSale;
    cartModel.isChecked = YES;
    cartModel.specialId = STLToString(baseInfoModel.specialId);
    cartModel.mediasource = self.sourceType;
    cartModel.reviewsId = self.reviewsId;
    cartModel.cart_exits = baseInfoModel.cart_exists;
    
    // 0 > 闪购 > 满减
    if (STLIsEmptyString(baseInfoModel.specialId)) {
        cartModel.activeId = baseInfoModel.flash_sale.active_id;
        cartModel.flash_sale = baseInfoModel.flash_sale;
    }
    [[OSSVCartsOperateManager sharedManager] saveCart:cartModel completion:^(id obj) {
        
        //和鲍勇再次确认完全可以拿着is_can_buy 字段来判断用户能否按照闪购价继续购买，以及闪购背景置灰和 价格不为红色
        //GA
        CGFloat price = [cartModel.goodsPrice floatValue];
        NSString *skuType = @"normal";
        if (!STLIsEmptyString(self.specialId) && ![STLToString(self.specialId) isEqualToString:@"0"]) {//0元
            skuType = @"free";
        }
        if (obj && [obj isKindOfClass:[STLCartModel class]]) {
            obj = (STLCartModel *)obj;

            [obj handleCartGoodsCount];
            //[[OSSVCartsOperateManager sharedManager] cartSaveValidGoodsCount:allGoods.count];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Cart object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_CartBadge object:nil];
            
            //谷歌统计
            [OSSVAnalyticsTool appsFlyerAddToCartWithProduct:cartModel fromProduct:YES];
            
            
            // 0 > 闪购 > 满减
            if (!STLIsEmptyString(cartModel.specialId)) {//0元
                price = [cartModel.goodsPrice floatValue];
                
            } else if (STLIsEmptyString(cartModel.specialId) && baseInfoModel.flash_sale &&  [baseInfoModel.flash_sale.is_can_buy isEqualToString:@"1"] && [baseInfoModel.flash_sale.active_status isEqualToString:@"1"]) {//闪购
                price = [baseInfoModel.flash_sale.active_price floatValue];
            }
            CGFloat allPrice = cartModel.goodsNumber * price;


            //数据GA埋点曝光 加购事件
            NSDictionary *items = @{
                kFIRParameterItemID: STLToString(cartModel.goods_sn),
                kFIRParameterItemName: STLToString(cartModel.goodsName),
                kFIRParameterItemCategory: STLToString(cartModel.cat_name),
                kFIRParameterPrice: @(price),
                kFIRParameterQuantity: @(cartModel.goodsNumber),
                //产品规格
                kFIRParameterItemVariant: @"",
                kFIRParameterItemBrand: @"",
                kFIRParameterCurrency: @"USD",

            };
            
            NSDictionary *itemsDic = @{kFIRParameterItems:@[items],
                                       kFIRParameterCurrency: @"USD",
                                       kFIRParameterValue: @(allPrice),
                                       @"screen_group":[NSString stringWithFormat:@"ProductDetail_+%@",STLToString(cartModel.goods_sn)],
                                       @"position":@"Product Detail_Button",
            };
            
            [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventAddToCart parameters:itemsDic];
            
            
            NSDictionary *sensorsDic = @{@"referrer":[UIViewController currentTopViewControllerPageName],
                                         @"goods_sn":STLToString(cartModel.goods_sn),
                                         @"goods_name":STLToString(cartModel.goodsName),
                                         @"cat_id":STLToString(cartModel.cat_id),
                                         @"cat_name":STLToString(cartModel.cat_name),
                                         @"item_type":skuType,
                                         @"original_price":@([STLToString(baseInfoModel.goodsMarketPrice) floatValue]),
                                         @"present_price":@(price),
                                         @"goods_quantity":@(cartModel.goodsNumber),
                                         @"currency":@"USD",
                                         @"shoppingcart_entrance":@"addcart_goods",
                                         @"goods_attr":STLToString(cartModel.goodsAttr),
                                         @"is_success"     : @(YES),
                                         kAnalyticsThirdPartId      :   STLToString(self.viewModel.analyticsDic[kAnalyticsThirdPartId]),
                                         kAnalyticsPositionNumber   :   @([self.viewModel.analyticsDic[kAnalyticsPositionNumber] integerValue]),
                                         kAnalyticsKeyWord          :   STLToString(self.viewModel.analyticsDic[kAnalyticsKeyWord]),
                                         kAnalyticsRecommendPartId  :    STLToString(self.viewModel.analyticsDic[kAnalyticsRequestId]),
            };
                                         
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"AddToCart" parameters:sensorsDic];
            [OSSVAnalyticsTool analyticsSensorsEventFlush];
            
            if (self.searchKey && self.searchPositionNum > 0) {
                [ABTestTools.shared addToCartWithKeyWord:STLToString(self.searchKey)
                                             positionNum:self.searchPositionNum
                                                 goodsSn:STLToString(cartModel.goods_sn)
                                               goodsName:STLToString(cartModel.goodsName)
                                                   catId:STLToString(cartModel.cat_id)
                                                 catName:STLToString(cartModel.cat_name)
                                             originPrice:[STLToString(baseInfoModel.goodsMarketPrice) floatValue]
                                            presentPrice:price];
                
                [BytemCallBackApi sendCallBackWithApiKey:STLToString(self.searchModel.btm_apikey) index:STLToString(self.searchModel.btm_index) sid:STLToString(self.searchModel.btm_sid) pid:STLToString(baseInfoModel.spu) skuid:STLToString(cartModel.goods_sn) action:1 searchEngine:STLToString(self.searchModel.search_engine)];

            }
            
            ///branch 埋点
            [OSSVBrancshToolss logAddToCart:sensorsDic];
            

            [DotApi addToCart];
        
            //加了弹窗，就不需要加购成功的提示了
            
//            [HUDManager showHUD:MBProgressHUDModeText onTarget:nil hide:YES afterDelay:1 enabled:NO message:STLLocalizedString_(@"addToCartSuccess", nil) customView:nil contentBgColor:nil textColor:nil margin:10 completionBlock:nil];
            
          //加购成功后弹出视图------1.2.8 又去掉了
//            [self showAddCartSuccessPopView:baseInfoModel];

            
            [self.viewModel addCartEventSuccess:self.detailModel status:YES];
            ///切换tab
            [self.buyAndBuyTabView setCurrentIndex:0];
            [self showAddCarAnimation];
        } else {
//            NSString *msg = STLLocalizedString_(@"noInventory", nil);
            NSString *msg = @"";

            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                if ([obj[kStatusCode] integerValue] == 20002) {//无库存
                    msg = obj[@"message"];
                    
                }
            }
//            [HUDManager showHUDWithMessage:[OSSVNSStringTool isEmptyString:msg] ? STLLocalizedString_(@"noInventory", nil) : msg];
            if (msg.length) {
                [HUDManager showHUDWithMessage:msg];
            }
            
            NSDictionary *sensorsDic = @{@"referrer":[UIViewController currentTopViewControllerPageName],
                                         @"goods_sn":STLToString(baseInfoModel.goods_sn),
                                         @"goods_name":STLToString(baseInfoModel.goodsTitle),
                                         @"cat_id":STLToString(baseInfoModel.cat_id),
                                         @"cat_name":STLToString(baseInfoModel.cat_name),
                                         @"item_type":skuType,
                                         @"original_price":@([STLToString(baseInfoModel.goodsMarketPrice) floatValue]),
                                         @"present_price":@(price),
                                         @"goods_quantity":@(cartModel.goodsNumber),
                                         @"currency":@"USD",
                                         @"shoppingcart_entrance":@"addcart_goods",
                                         @"is_success"     : @(NO),
                                         kAnalyticsThirdPartId      :   STLToString(self.viewModel.analyticsDic[kAnalyticsThirdPartId]),
                                         kAnalyticsPositionNumber   :   @([self.viewModel.analyticsDic[kAnalyticsPositionNumber] integerValue]),
                                         kAnalyticsKeyWord          :   STLToString(self.viewModel.analyticsDic[kAnalyticsKeyWord]),
                                         kAnalyticsRecommendPartId  :    STLToString(self.viewModel.analyticsDic[kAnalyticsRequestId]),
            };
                                         
            [OSSVAnalyticsTool analyticsSensorsEventWithName:@"AddToCart" parameters:sensorsDic];
            [OSSVAnalyticsTool analyticsSensorsEventFlush];
            
            ///branch 埋点
            [OSSVBrancshToolss logAddToCart:sensorsDic];
        }
    } failure:^(id obj) {
        
    }];
}

-(void)STL_GoodsDetailsHeaderSelectSizeGoodId:(NSString *)goodsId wid:(NSString *)wid selectAttribute:(OSSVAttributeItemModel *)attributeItemModel {
    if (attributeItemModel) {
        BOOL isRecommend = [attributeItemModel.type isEqualToString:@"0"];
        [self requesData:STLToString(goodsId) wid:STLToString(wid) recommend:isRecommend];
    }
}


#pragma mark - 滑动contentoffset观察者
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:kColletionContentOffsetName]) {
        CGFloat offset = self.collectionView.contentOffset.y;
        
        CGFloat bottom_space = offset > STL_COLLECTION_MOVECONTENT_HEIGHT ? (kIS_IPHONEX ? -90 : -80) : (kIS_IPHONEX ? 90 : 80);
        CGFloat btn_alpha = offset > STL_COLLECTION_MOVECONTENT_HEIGHT ? 1.0 : 0;
        
        [UIView animateWithDuration: 0.8 delay: 0.4 options: UIViewAnimationOptionCurveEaseInOut animations: ^{
            [self.backToTopBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(@(bottom_space));
            }];
        } completion: ^(BOOL finished) {
            [UIView animateWithDuration: 0.4 animations: ^{
                self.backToTopBtn.alpha = btn_alpha;
            }];
        }];
        
        CGFloat sectionHeaderHeight = 120;
        //图片暂时屏蔽
//        if (!self.topBarView.imgUrl) {
//            OSSVDetailPictureArrayModel *pictureModel = self.detailModel.pictureListArray.firstObject;
//            self.topBarView.imgUrl = pictureModel.goodsBigImg;
//        }
        [self.topBarView updateItemAlpha:(offset / sectionHeaderHeight)];
        
        if (self.viewModel.recommendHeaderCell) {
            CGRect recommendHeaderFrame = [self.collectionView convertRect:self.viewModel.recommendHeaderCell.frame toView:self.collectionView.superview];
            NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:self.viewModel.recommendHeaderCell.center];
//            NSLog(@"--------===%@---%@---%@",NSStringFromCGRect(recommendHeaderFrame),indexPath,self.viewModel.recommendHeaderCell);
            _prevRecommendHeaderFrame = recommendHeaderFrame;
            CGFloat topMargin = kIS_IPHONEX ? 84 : 60;
            if (recommendHeaderFrame.origin.y < topMargin && indexPath && self.viewModel.recommendHeaderCell) {
                self.buyAndBuyTabView.alpha = 1;
            }else{
                self.buyAndBuyTabView.alpha = 0;
            }
        }
        
    }
}

//选择属性更改图片
- (void)updateTopBarGoodsImg {
    OSSVDetailPictureArrayModel *pictureModel = self.detailModel.pictureListArray.firstObject;
    if (pictureModel.goodsBigImg) {
        if (![self.topBarView.imgUrl isEqualToString:pictureModel.goodsBigImg]) {
            self.topBarView.imgUrl = pictureModel.goodsBigImg;
        }
    }
}

- (void)hitsAnalyticsBegin {
    self.beginTime = (long long int)[[NSDate date] timeIntervalSince1970];
}


-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [[YYWebImageManager sharedManager].cache.memoryCache removeAllObjects];
}




#pragma mark - LazyLoad

- (void)setCoverImageUrl:(NSString *)coverImageUrl {
    if (!_coverImageUrl) {
        _coverImageUrl = coverImageUrl;
    }
}
- (OSSVDetailsViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVDetailsViewModel alloc] init];
        _viewModel.controller = self;
        _viewModel.delegate = self;
        _viewModel.detailSizeSheet = self.detailSheet;
        _viewModel.bottomView = self.bottomView;
        NSMutableDictionary *dic = @{kAnalyticsAOPSourceID:STLToString(self.goodsId)}.mutableCopy;
        [dic addEntriesFromDictionary:self.transmitMutDic];
        _viewModel.analyticsDic = dic;
        
        @weakify(self)
        _viewModel.collectionBlock = ^(NSString *isCollection, NSString *goodsId) {
            @strongify(self)
            if (self.collectionBlock) {
                self.collectionBlock(isCollection, goodsId);
            }
        };
    }
    return _viewModel;
}

- (UIView *)transformView {
    if (!_transformView) {
        _transformView = [[UIView alloc] init];
    }
    return _transformView;
}

- (OSSVDetailLoadView *)detailLoadView {
    if (!_detailLoadView) {
        _detailLoadView = [[OSSVDetailLoadView alloc] initWithFrame:self.view.bounds];
    }
    return _detailLoadView;
}

- (OSSVDetailTopBarView *)topBarView {
    if (!_topBarView) {
        _topBarView = [[OSSVDetailTopBarView alloc] initWithFrame:CGRectZero];
        _topBarView.delegate = self;
        @weakify(self)
        _topBarView.eventView.searchBlock = ^(NSString *searchKey) {
            @strongify(self)
            [self jumpIntoSearchViewControllerWithSearchKey:searchKey];
            NSLog(@"点击了：%@", searchKey);
        };
    }
    return _topBarView;
}

#pragma mark ---点击搜索内容跳转到搜索页面
- (void)jumpIntoSearchViewControllerWithSearchKey:(NSString *)searchKey {
    OSSVSearchVC *searchVc = [[OSSVSearchVC alloc] initWithNibName:nil bundle:nil];
    searchVc.enterName = @"Home";
    searchVc.searchTitle = searchKey;
    [self.navigationController pushViewController:searchVc animated:true];
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
           @"screen_group":@"GoodDetail",
           @"button_name":@"Search_box"}];

}
- (OSSVDetailCollectionLayout *)detailLayout {
    if (!_detailLayout) {
        _detailLayout = [[OSSVDetailCollectionLayout alloc] init];
        _detailLayout.dataSource = self.viewModel;
    }
    return _detailLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
//        CHTCollectionViewWaterfallLayout *waterFallLayout = [[CHTCollectionViewWaterfallLayout alloc] init];
//        waterFallLayout.columnCount = 2;
//        waterFallLayout.sectionInset = UIEdgeInsetsMake(12, 12, 0, 12);
        
//        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:waterFallLayout];
        
//        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 45);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.detailLayout];
        
        [_collectionView addObserver:self forKeyPath:kColletionContentOffsetName options:NSKeyValueObservingOptionNew context:nil];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.dataSource = self.viewModel;
        _collectionView.delegate = self.viewModel;
        _collectionView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        if (APP_TYPE == 3) {
            _collectionView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        }
        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 11, 0);
        _collectionView.contentOffset = CGPointMake(0, -10);
//        [_collectionView registerClass:[UICollectionReusableView class]
//        forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
//               withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
//        [_collectionView registerClass:[UICollectionReusableView class]
//        forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
//               withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
        
        
        [_collectionView registerClass:[OSSVDetailReviewCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVDetailReviewCell.class)];
        [_collectionView registerClass:[OSSVDetailRecommendHeaderCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVDetailRecommendHeaderCell.class)];
        [_collectionView registerClass:[STLGoodsDetailReviewMoreCell class] forCellWithReuseIdentifier:NSStringFromClass(STLGoodsDetailReviewMoreCell.class)];
        [_collectionView registerClass:[OSSVDetailReviewStarCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVDetailReviewStarCell.class)];
        [_collectionView registerClass:[OSSVDetailRecommendCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVDetailRecommendCell.class)];
        [_collectionView registerClass:[OSSVDetailAdvertiseViewCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVDetailAdvertiseViewCell.class)];
        [_collectionView registerClass:[OSSVDetailFastAddCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVDetailFastAddCCell.class)];
        [_collectionView registerClass:[OSSVDetailInfoCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVDetailInfoCell.class)];
        [_collectionView registerClass:[OSSVDetailServicesCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVDetailServicesCell.class)];
        [_collectionView registerClass:[OSSVDetailSizeDescCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVDetailSizeDescCell.class)];
        [_collectionView registerClass:[OSSVDetailActivityCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVDetailActivityCell.class)];
        [_collectionView registerClass:[OSSVDetailReviewNewCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVDetailReviewNewCell.class)];
        
        
        @weakify(self)
        _collectionView.mj_footer = [OSSVRefreshsAutosNormalFooter footerWithRefreshingBlock:^{
            @strongify(self)
            if (self.bottomRequestType == 0) {
                [self requestCommendData:self.isLoadMoreData];
            }else if (self.bottomRequestType == 1){
                [self requestBuyAndBuyData:self.isLoadMoreData];
            }
        }];
        _collectionView.mj_footer.hidden = NO;
    }
    return _collectionView;
}

//闪购商品提示View
- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [UILabel new];
        _bottomLabel.hidden = YES;
        _bottomLabel.font = [UIFont systemFontOfSize:11];
        _bottomLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _bottomLabel.backgroundColor = OSSVThemesColors.col_FFF5DF;
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _bottomLabel;
}
- (OSSVDetailBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[OSSVDetailBottomView alloc] initWithFrame:CGRectZero];
        _bottomView.delegate = self;
        _bottomView.hidden = YES;
    }
    return _bottomView;
}

//置顶按钮
- (UIButton *)backToTopBtn {
    if (!_backToTopBtn) {
        _backToTopBtn  = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backToTopBtn setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
        [_backToTopBtn addTarget:self action:@selector(scrollerToTop) forControlEvents:UIControlEventTouchDown];
    }
    return _backToTopBtn;
}

- (STLGoodsDetailActionSheet *)detailSheet {
    if (!_detailSheet) {
        _detailSheet = [[STLGoodsDetailActionSheet alloc] initWithFrame:self.view.bounds];
        _detailSheet.sourceType = self.sourceType;
        _detailSheet.reviewsId = self.reviewsId;
        _detailSheet.hadManualSelectSize = YES;
        _detailSheet.searchPositionNum = self.searchPositionNum;
        _detailSheet.searchKey = self.searchKey;
        @weakify(self)
        _detailSheet.cancelViewBlock = ^{   // cancel block
            @strongify(self)
            [self restoreTransform];
        };
        _detailSheet.attributeBlock = ^(NSString *goodsId,NSString *wid) {
            @strongify(self)
            [self requesData:goodsId wid:wid recommend:YES];
        };
        
        _detailSheet.addCartEventBlock = ^(BOOL flag) {
            @strongify(self)
            [self.viewModel addCartEventSuccess:self.detailModel status:flag];
            ///切换tab
            [self.buyAndBuyTabView setCurrentIndex:0];
            
            if (flag) {
                [self showAddCarAnimation];
            }
            
        };
        
        _detailSheet.collectionStateBlock = ^(BOOL isCollection, NSString *wishCount) {
            @strongify(self)
            self.viewModel.detailModel.goodsBaseInfo.isCollect = isCollection;
            self.viewModel.detailModel.goodsBaseInfo.wishCount = wishCount;
            
            [self.collectionView reloadData];
        };
    }
    return _detailSheet;
}

/**
 * 显示购物车加购动画
 */
- (void)showAddCarAnimation {
    CGRect rect = [self.topBarView convertRect:self.topBarView.eventView.cartButton.frame toView:WINDOW];
//    CGPoint endPoint = CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
    CGPoint endPoint = CGPointMake(rect.origin.x + 8, rect.origin.y + rect.size.height / 2.0 + 12);
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        endPoint = CGPointMake(rect.origin.x + rect.size.width / 2.0 + 12, rect.origin.y + rect.size.height / 2.0 + 12);
    }

    STLPopCartAnimation *popAnimation = [[STLPopCartAnimation alloc] init];
    popAnimation.animationImage = self.topBarView.imgView.image;
    popAnimation.animationDuration = 0.5f;
    popAnimation.endPoint = endPoint;
    
    self.collectionView.userInteractionEnabled = NO;
    @weakify(self)
    [popAnimation startAnimation:self.view endBlock:^{
        @strongify(self)

//        [STLPopCartAnimation popDownRotationAnimation:self.topBarView.eventView.cartButton];
        [self.topBarView playCartAnimate:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:STLBuyAndBuySwitchNotifiName object:self userInfo:@{@"index":@(0)}];
        [self scrollRecommendPosition];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.collectionView.userInteractionEnabled = YES;
        });
    }];
    
    popAnimation.noAnimationBlock = ^{
        @strongify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.collectionView.userInteractionEnabled = YES;
        });
    };
}

- (void)scrollRecommendPosition {
    [self.viewModel scrollRecommendPosition];
}


#pragma mark ----懒加载商品服务和 运输时间的 ADDTOBAG 弹出视图
- (OSSVDetailServiceDescView *)serviceDescView {
    if (!_serviceDescView) {
        _serviceDescView = [[OSSVDetailServiceDescView alloc] initWithFrame:self.view.bounds];
        @weakify(self)
        _serviceDescView.closeViewBlock = ^{
            @strongify(self)
            [self hideServiceTransform];
        };
        
        _serviceDescView.gotoWebViewBlock = ^{
            @strongify(self)
            NSLog(@"进入web页面");
            STLWKWebCtrl *webVc = [[STLWKWebCtrl alloc]init];
            webVc.title = STLLocalizedString_(@"help_ReturnPolicy", nil);
            webVc.isNoNeedsWebTitile = YES;
            webVc.url = [OSSVLocaslHosstManager appHelpUrl:HelpTypeReturnPolicy];;
            [self.navigationController pushViewController:webVc animated:YES];

        };
    }
    return _serviceDescView;
}

- (OSSVDetailTransportTimePopView *)transportPopView {
    if (!_transportPopView) {
        _transportPopView = [[OSSVDetailTransportTimePopView alloc] initWithFrame:self.view.bounds];
        @weakify(self)
        _transportPopView.closeViewBlock = ^{
            @strongify(self)
            [self dismissTransportTimeView];
        };
    }
    return _transportPopView;
}

#pragma mark
#pragma mark - Empty page
- (void)addEmptyView {
    UIView *emptyView = [[UIView alloc] init];
    [self.view addSubview:emptyView];
    
    [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(-20, 0, 0, 0));
    }];
    
    [self.view bringSubviewToFront:self.topBarView];
}

#pragma mark -- updateGoodDetailData  ---更新商品详情的通知
- (void)updateGoodDetailData {
    [self requesDetailData:self.goodsId wid:self.wid recommend:YES];
}
#pragma mark -- updateGoodDetailData  ---点击size属性更新商品详情的通知
- (void)sizeTapUpdateGoodDetailData:(NSNotification *)noti{
    if (!_viewModel) {
        _viewModel = [[OSSVDetailsViewModel alloc] init];
    }
    _viewModel.isTapSize = YES;
    NSString *goods_id = noti.object;
    self.goodsId = goods_id;
    self.bottomView.userInteractionEnabled = NO;// 防止同时点击加购和尺码
    [self updateGoodDetailData];
}
#pragma mark -- updateGoodDetailData  ---点击color属性更新商品详情的通知
- (void)colorTapUpdateGoodDetailData:(NSNotification *)noti{
    if (!_viewModel) {
        _viewModel = [[OSSVDetailsViewModel alloc] init];
    }
    NSString *goods_id = noti.object;
    self.goodsId = goods_id;
    self.bottomView.userInteractionEnabled = NO;// 防止同时点击加购和颜色
    [self updateGoodDetailData];
}
#pragma mark ---添加计时器 5秒后关闭加购成功的弹窗
- (void)addTimer {
    self.timeCount = 3;
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(closePopView) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];

}
- (void)closePopView {
    self.timeCount--;
    NSLog(@"倒计时： %ld", self.timeCount);
    if (self.timeCount == 0) {
        [self.timer invalidate];
        NSLog(@"关闭弹窗");
    }
}

- (PrivacySheet *)privacySheet{
    if (!_privacySheet) {
        _privacySheet = [[PrivacySheet alloc] initWithFrame:CGRectZero];
    }
    return _privacySheet;
}

@end
