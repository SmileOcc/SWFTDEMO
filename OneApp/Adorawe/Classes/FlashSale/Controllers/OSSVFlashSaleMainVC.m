//
//  STLFlashjSaleMainViewController.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/6.
//  Copyright © 2020 starlink. All rights reserved.
//
///Controllers
#import "OSSVFlashSaleMainVC.h"
#import "YNPageViewController.h"
#import "OSSVCartVC.h"
#import "OSSVFlashSaleVC.h"
#import "OSSVFlashSaleNotStartVC.h"
#import "OSSVDetailsVC.h"
//ViewModels
#import "OSSVFlashSaleViewModel.h"
#import "OSSVFlashChannelModel.h"
//Helps
#import "UIView+YNPageExtend.h"
#import "UIButton+STLCategory.h"

#import "JSBadgeView.h"
#import "STLActionSheet.h"
#import "OSSVDetailsViewModel.h"
#import "OSSVFlashMainModel.h"
#import "Adorawe-Swift.h"

#define kOpenRefreshHeaderViewHeight 0

#define kFlashHedaerHeight 200*kScale_375

@interface OSSVFlashSaleMainVC ()<
YNPageViewControllerDataSource,
YNPageViewControllerDelegate
>
@property (copy, nonatomic) NSArray <UIViewController *>    *viewControllers;
@property (copy, nonatomic)   NSMutableArray                *menuTitles;
@property (nonatomic, strong) YNPageViewController          *pageVC;
@property (nonatomic, strong) UIButton                      *rightButton;
@property (nonatomic, copy)   NSMutableArray                *subTitles;
@property (nonatomic, strong) OSSVFlashSaleViewModel         *viewModel;
@property (nonatomic, strong) NSMutableArray                *activeId;
@property (nonatomic, strong) NSMutableArray                *timeCount;//剩余时间数
@property (nonatomic, strong) NSMutableArray                *labelStr;
@property (nonatomic, strong) NSMutableArray                *statusStr;

@property (nonatomic, strong) STLActionSheet                *detailSheet; // 属性选择弹窗
@property (nonatomic, assign) BOOL                            hasFirtFlash;
@property (nonatomic, strong) JSBadgeView                   *badgeView;  //购物车数字
@property (nonatomic, strong) OSSVDetailsViewModel         *baseInfoModel;

@property (nonatomic, assign) CGFloat                       headerViewHeight;

@property (nonatomic, strong) UIScrollView                  *emptyBackView;

@property (nonatomic, strong) OSSVFlashMainModel             *mainModel;

@property (nonatomic,weak) UILabel *loadingfaildLbl;
@property (assign,nonatomic) BOOL hasTabs;
@property (assign,nonatomic) BOOL success;
@property (nonatomic,weak) UIButton *reloadButton;

@end

@implementation OSSVFlashSaleMainVC

-(void)setHasTabs:(BOOL)hasTabs{
    _hasTabs = hasTabs;
    if (hasTabs) {
        if (APP_TYPE == 3) {
            [self.reloadButton setTitle:STLLocalizedString_(@"retry", nil) forState:UIControlStateNormal];
        } else {
            [self.reloadButton setTitle:STLLocalizedString_(@"retry", nil).uppercaseString forState:UIControlStateNormal];
        }
        self.loadingfaildLbl.hidden = NO;
    }
    else{
        [self.reloadButton setTitle:STLLocalizedString_(@"cart_blank_button_title", nil) forState:UIControlStateNormal];
        self.loadingfaildLbl.hidden = YES;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_detailSheet) {
        [_detailSheet removeFromSuperview];
        _detailSheet= nil;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [self setUpNavigationBgWithColor:OSSVThemesColors.col_FFCF60];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.navigationController) {
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage yy_imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
//        [self.navigationController.navigationBar setShadowImage:nil];
        [self setUpNavigationBgWithColor:[UIColor whiteColor]];
        
    } else {
        
        UIViewController *ctrl = [UIViewController currentTopViewController];
        if (ctrl && ctrl.navigationController) {
//            [ctrl.navigationController.navigationBar setBackgroundImage:[UIImage yy_imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
//            [ctrl.navigationController.navigationBar setShadowImage:nil];
            [ctrl setUpNavigationBgWithColor:[UIColor whiteColor]];
        }
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBagValues) name:kNotif_CartBadge object:nil];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage yy_imageWithColor:OSSVThemesColors.col_FFCF60] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    [self setUpNavigationBgWithColor:OSSVThemesColors.col_FFCF60];
//    [self requestChannelItemData:nil];

}

- (NSMutableArray *)menuTitles {
    if (!_menuTitles) {
        _menuTitles = [[NSMutableArray alloc] init];
    }
    return _menuTitles;
}

- (NSMutableArray *)activeId {
    if (!_activeId) {
        _activeId = [[NSMutableArray alloc] init];
    }
    return _activeId;
}

- (NSMutableArray *)subTitles {
    if (!_subTitles) {
        _subTitles = [[NSMutableArray alloc] init];
    }
    return _subTitles;
}
- (NSMutableArray *)timeCount {
    if (!_timeCount) {
        _timeCount = [[NSMutableArray alloc] init];
    }
    return _timeCount;
}

- (NSMutableArray *)labelStr {
    if (!_labelStr) {
        _labelStr = [[NSMutableArray alloc] init];
    }
    return _labelStr;
}

- (NSMutableArray *)statusStr {
    if (!_statusStr) {
        _statusStr = [[NSMutableArray alloc] init];
    }
    return _statusStr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = STLLocalizedString_(@"Flash_sale", nil);
    [self setupNavigation];
    [self requestChannelItemData:nil];
    [self showCartCount];
    [self createEmptyViews];
}


- (void)setupNavigation {
    
    _rightButton = [[UIButton alloc] init];
    [_rightButton setImage:[UIImage imageNamed:@"bag_new"] forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    _rightButton.imageView.contentMode = UIViewContentModeCenter;

    UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceButtonItem.width = -10.0;

    UIBarButtonItem *rihtItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    [self.navigationItem setRightBarButtonItems:@[spaceButtonItem, rihtItem]];

}

- (JSBadgeView *)badgeView {
    if (!_badgeView) {
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            // 阿语
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.rightButton alignment:JSBadgeViewAlignmentTopLeft];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(0), 5);
        }else{
            _badgeView = [[JSBadgeView alloc] initWithParentView:self.rightButton alignment:JSBadgeViewAlignmentTopRight];
            _badgeView.badgePositionAdjustment = CGPointMake(STLAutoLayout(16), -10);
        }
        
        _badgeView.userInteractionEnabled = NO;
        _badgeView.badgeBackgroundColor = [OSSVThemesColors col_B62B21];
        _badgeView.badgeTextFont = [UIFont systemFontOfSize:9];
        _badgeView.badgeStrokeColor = [OSSVThemesColors stlWhiteColor];
        _badgeView.badgeStrokeWidth = 1.0;
    }
    return _badgeView;
}

//occ阿语适配
- (void)arMenuViewHandle {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        
        self.pageVC.view.transform = CGAffineTransformMakeScale(-1.0,1.0);
        self.pageVC.headerView.transform = CGAffineTransformMakeScale(-1.0,1.0);
//        
        for (UIView *subView in self.pageVC.scrollMenuView.subviews) {
            for (UIView *subbView in subView.subviews) {
                if ([subbView isKindOfClass:[UIButton class]]) {
                    subbView.transform = CGAffineTransformMakeScale(-1.0,1.0);
                }
            }
        }
    }
}
- (void)requestChannelItemData:(void(^)(BOOL flag))resutlBlock {
    @weakify(self)
    [self.viewModel requestFlashSaleChannelWithParmater:self.channelId completion:^(id result) {
        NSLog(@"返回结果result: %@", result);
        @strongify(self)
        
        self.success = NO;
        self.hasTabs = YES;
        if (result && [result isKindOfClass:[OSSVFlashMainModel class]]) {
            self.success = YES;
            
            self.mainModel = (OSSVFlashMainModel*)result;
            if (self.mainModel) {
                self.hasTabs = self.mainModel.activeTabs.count > 0;
            }
            
            
            [self.menuTitles removeAllObjects];
            [self.subTitles removeAllObjects];
            [self.activeId removeAllObjects];
            [self.timeCount removeAllObjects];
            [self.labelStr removeAllObjects];
            [self.statusStr removeAllObjects];
            
            if (self.mainModel.activeTabs.count) {
                for (OSSVFlashChannelModel *model in self.mainModel.activeTabs) {
                    NSLog(@"便利数据：%@", model.title);
                    [self.menuTitles addObject: STLToString(model.timeLabel)];
                    [self.subTitles  addObject:STLToString(model.title)];
                    [self.activeId   addObject:STLToString(model.activeId)];
                    [self.timeCount  addObject:STLToString(model.expireTime)];
                    [self.labelStr   addObject:STLToString(model.label)];
                    [self.statusStr  addObject:STLToString(model.status)];
                }
                [self setupConfig];
            }
        }
        
        if (self.emptyBackView) {
            self.emptyBackView.hidden = self.success && self.hasTabs;
        }
        if (resutlBlock) {
            resutlBlock(self.success);
        }
    
    } failure:^(NSError *error) {
        NSLog(@"失败了");
        if (resutlBlock) {
            resutlBlock(NO);
        }
        
        if (self.emptyBackView && !self.mainModel) {
            self.emptyBackView.hidden = NO;
        }
    }];

}

- (OSSVFlashSaleViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[OSSVFlashSaleViewModel alloc] init];
    }
    return _viewModel;
}

- (void)setupConfig {
    YNPageConfigration *configration = [YNPageConfigration defaultConfig];
    configration.pageStyle = YNPageStyleSuspensionCenter;
    ////这个就会出现刷新
//    configration.pageStyle = YNPageStyleSuspensionTop;

    configration.headerViewCouldScale = YES;
    configration.showTabbar = NO;
    configration.showNavigation = YES;
    configration.scrollMenu = NO;
    configration.aligmentModeCenter = NO;
    configration.lineWidthEqualFontWidth = NO;
    configration.showBottomLine = YES;
    configration.lineColor = OSSVThemesColors.col_0D0D0D;
    configration.scrollViewBackgroundColor = OSSVThemesColors.col_FFCF60;
    configration.normalItemColor = [OSSVThemesColors col_0D0D0D:0.6];
    configration.selectedItemColor = OSSVThemesColors.col_0D0D0D;
    configration.bottomLineBgColor = [UIColor clearColor];
    configration.lineHeight = 1.5f;
    configration.lineCorner = 0.5f;
//    configration.lineColor = [UIColor clearColor];
    configration.menuHeight = 44.f;
    configration.itemFont = [UIFont boldSystemFontOfSize:17];
    configration.selectedItemFont = [UIFont boldSystemFontOfSize:17];
    configration.headerViewCouldScrollPage = YES;

   
    YNPageViewController *vc = [YNPageViewController pageViewControllerWithControllers:[self viewControllers] titles:self.menuTitles subTitles:self.subTitles config:configration];
    self.pageVC = vc;
    self.pageVC.bgScrollView.pagingEnabled = YES;
    vc.dataSource = self;
    vc.delegate = self;
    
    self.headerViewHeight = 0;
    if (self.mainModel && self.mainModel.bannerInfo && [self.mainModel.bannerInfo.width floatValue] > 0 && !STLIsEmptyString(self.mainModel.bannerInfo.imageURL)) {
        
        CGFloat advHeight = SCREEN_WIDTH * [self.mainModel.bannerInfo.height floatValue] / [self.mainModel.bannerInfo.width floatValue];
        self.headerViewHeight = advHeight;
        
        YYAnimatedImageView *headImgView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.headerViewHeight)];
        [headImgView yy_setImageWithURL:[NSURL URLWithString:self.mainModel.bannerInfo.imageURL]
                              placeholder:[UIImage imageNamed:@"placeholder_banner_pdf"]
                                  options:YYWebImageOptionShowNetworkActivity
                                 progress:nil
                                transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                    return image;
                                }
                               completion:nil];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        [headImgView addGestureRecognizer:tap];
        headImgView.userInteractionEnabled = YES;
        
        vc.headerView = headImgView;
        
        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                     @"attr_node_1":@"flash",
                                     @"attr_node_2":@"flash_top",
                                     @"attr_node_3":@"flash_top_project",
                                     @"position_number":@(0),
                                     @"venue_position":@(0),
                                     @"action_type":@([self.mainModel.bannerInfo advActionType]),
                                     @"url":[self.mainModel.bannerInfo advActionUrl],
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerImpression" parameters:sensorsDic];
        
        //数据GA埋点曝光 广告
        
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
        
        [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewPromotion parameters:promoParams];
        
        
    } else {
        vc.headerView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    vc.pageScrollView.pagingEnabled = YES;
    /// 指定默认选择index 页面
    vc.pageIndex = 0;
    [vc addSelfToParentViewController:self];
    [self arMenuViewHandle];
}

- (void)actionTap:(UITapGestureRecognizer *)tap {
    STLLog(@"adv");
    
    if (self.mainModel && self.mainModel.bannerInfo) {
        
        NSString *pageName = [UIViewController currentTopViewControllerPageName];
        NSDictionary *sensorsDic = @{@"page_name":STLToString(pageName),
                                     @"attr_node_1":@"flash",
                                     @"attr_node_2":@"flash_top",
                                     @"attr_node_3":@"flash_top_project",
                                     @"position_number":@(0),
                                     @"venue_position":@(0),
                                     @"action_type":@([self.mainModel.bannerInfo advActionType]),
                                     @"url":[self.mainModel.bannerInfo advActionUrl],
        };
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"BannerClick" parameters:sensorsDic];
        
        
        [OSSVAdvsEventsManager advEventTarget:self withEventModel:self.mainModel.bannerInfo];
        
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
                            
                            [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventSelectPromotion parameters:promoParams];
    }
}

//刷新数据页面、所有View、菜单栏、headerView - 默认移除缓存控制器
//刷新菜单栏配置 标题数组
//e.g: vc.config = ...
//vc.titlesM = [self getArrayTitles].mutableCopy;
//
//如果需要重新走控制器的ViewDidLoad方法则需要重新赋值 controllers
//e.g:
//vc.controllersM = [self getArrayVCs].mutableCopy;

- (void)relaodMainView {
    
    if (self.menuTitles.count > 0) {
        self.viewControllers = nil;
        self.pageVC.titlesM = self.menuTitles;
        self.viewControllers = [self setupViewControllers];
        self.pageVC.controllersM = [[NSMutableArray alloc] initWithArray:self.viewControllers];
        self.pageVC.pageIndex = 0;
        [self.pageVC reloadData];
    } else {
        
//        [self.pageVC removeSelfViewController];
        
//        YYAnimatedImageView *headImgView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.headerViewHeight)];
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            headImgView.image = [UIImage imageNamed:@"flashsale_black_ar_"];
//        } else {
//            headImgView.image = [UIImage imageNamed:@"flashsale_black_en_"];
//        }
//
//        [self.view addSubview:headImgView];
    }
    
}

- (void)reReloadQuest {
    
    @weakify(self)
    [self.viewModel requestFlashSaleChannelWithParmater:self.channelId completion:^(id result) {
        NSLog(@"返回结果result: %@", result);
        @strongify(self)
        if (STLJudgeNSArray(result)) {
            [self.menuTitles removeAllObjects];
            [self.subTitles removeAllObjects];
            [self.activeId removeAllObjects];
            [self.timeCount removeAllObjects];
            [self.labelStr removeAllObjects];
            [self.statusStr removeAllObjects];
            NSArray *dataArray = (NSArray *)result;
            if (dataArray.count) {
                for (OSSVFlashChannelModel *model in dataArray) {
                    NSLog(@"便利数据：%@", model.title);
                    [self.menuTitles addObject: STLToString(model.timeLabel)];
                    [self.subTitles  addObject:STLToString(model.title)];
                    [self.activeId   addObject:STLToString(model.activeId)];
                    [self.timeCount  addObject:STLToString(model.expireTime)];
                    [self.labelStr   addObject:STLToString(model.label)];
                    [self.statusStr  addObject:STLToString(model.status)];
                }
                [self relaodMainView];
            } else {
                [self relaodMainView];
            }
        } else {
            
        }
    
    } failure:^(NSError *error) {
        NSLog(@"失败了");
    }];
}

#pragma mark --Action ---
- (void)clickButtonAction:(id)sender {
    OSSVCartVC *cartVC = [[OSSVCartVC alloc] init];
    [self.navigationController pushViewController:cartVC animated:YES];
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
           @"screen_group":@"FlashSale",
           @"button_name":@"Cart"}];
}

#pragma mark - Getter and Setter

-(NSArray <UIViewController *> *)viewControllers {
    if (!_viewControllers) {
        _viewControllers = [self setupViewControllers];
    }
    return _viewControllers;
}

-(NSArray <UIViewController *> *)setupViewControllers {
    NSMutableArray <UIViewController *> *ctrlsArray = [NSMutableArray arrayWithCapacity:0];
    if (self.menuTitles.count) {
        for (int i = 0; i<self.menuTitles.count; i++) {
            NSString *actId = self.activeId[i];
            NSString *timeCountStr = self.timeCount[i];
            NSString *labelStr = self.labelStr[i];
            NSString *actStatus  = self.statusStr[i];
            //活动状态： 0--未开始，   1--进行中
                 if ([actStatus isEqualToString:@"0"]){
                     OSSVFlashSaleNotStartVC *notStartVc = [[OSSVFlashSaleNotStartVC alloc] init];
                     notStartVc.activeId = actId;
                     notStartVc.timeCount = timeCountStr;
                     notStartVc.labelStr = labelStr;
                     notStartVc.contentHeight = self.headerViewHeight;
                     notStartVc.isArCellTransform = YES;
                     notStartVc.tabItem = self.mainModel.activeTabs[i];
                     notStartVc.transmitMutDic = self.transmitMutDic;
                     @weakify(self)
                     notStartVc.activiteRefreshBlock = ^(BOOL refresh) {
                         @strongify(self)
                         [self reReloadQuest];
                     };
                     [ctrlsArray addObject:notStartVc];
                     
                 } else {
                     OSSVFlashSaleVC *goodVc = [[OSSVFlashSaleVC alloc] init];
                     goodVc.activeId = actId;
                     goodVc.timeCount = timeCountStr;
                     goodVc.labelStr = labelStr;
                     goodVc.contentHeight = self.headerViewHeight;
                     goodVc.isArCellTransform = YES;
                     goodVc.transmitMutDic = self.transmitMutDic;
                     
                     @weakify(self)
                     goodVc.activiteRefreshBlock = ^(BOOL refresh) {
                         @strongify(self)
                         [self reReloadQuest];
                     };
                     
                     goodVc.showCartBlock = ^(OSSVFlashSaleGoodsModel * _Nonnull saleModel, NSInteger index) {
                         @strongify(self)
                         [self showSheetView:saleModel index:index];
                     };
                     [ctrlsArray addObject:goodVc];
                 }
        }

    }
   
    return [ctrlsArray copy];
}

- (void)requesData:(NSString*)goodsId wid:(NSString*)wid {
    @weakify(self)
    NSDictionary *dic = dic = @{@"goods_id":STLToString(goodsId),
                                @"loadState":STLRefresh,
                                @"wid":STLToString(wid),
                                @"specialId":STLToString(@"")};
    [self.baseInfoModel requestNetworkOnly:dic completion:^(OSSVDetailsBaseInfoModel *obj) {
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            OSSVDetailsBaseInfoModel *baseInfoModel = (OSSVDetailsBaseInfoModel *)obj;
            NSArray <OSSVSpecsModel *> *goods_specs = baseInfoModel.GoodsSpecs;
            for (OSSVSpecsModel *specModel in goods_specs) {
                specModel.isSelectSize = YES;
            }
            self.detailSheet.baseInfoModel = baseInfoModel;
            self.detailSheet.hadManualSelectSize = YES;
            [self.detailSheet addCartAnimationTop:0 moveLocation:CGRectZero showAnimation:NO];
            [self.view addSubview:self.detailSheet];
            [UIView animateWithDuration: 0.25 animations: ^{
                [self.detailSheet shouAttribute];
                self.detailSheet.sourceType = STLAppsflyerGoodsSourceFlashList;
                self.detailSheet.type = GoodsDetailEnumTypeAdd;
            } completion: nil];
            
        }
    } failure:^(id obj) {
    }];
}

- (void)requesData:(NSString*)goodsId wid:(NSString*)wid specialId:(NSString *)specialId{
    @weakify(self)
    NSDictionary *dic = dic = @{@"goods_id":STLToString(goodsId),
                                @"loadState":STLRefresh,
                                @"wid":STLToString(wid),
                                @"specialId":STLToString(specialId)};
    [self.baseInfoModel requestNetworkOnly:dic completion:^(OSSVDetailsBaseInfoModel *obj) {
        @strongify(self)
        if (obj && [obj isKindOfClass:[OSSVDetailsBaseInfoModel class]]) {
            OSSVDetailsBaseInfoModel *baseInfoModel = (OSSVDetailsBaseInfoModel *)obj;
            NSArray <OSSVSpecsModel *> *goods_specs = baseInfoModel.GoodsSpecs;
            for (OSSVSpecsModel *specModel in goods_specs) {
                specModel.isSelectSize = YES;
            }
            self.detailSheet.baseInfoModel = baseInfoModel;
            self.detailSheet.hadManualSelectSize = YES;
            [self.detailSheet addCartAnimationTop:0 moveLocation:CGRectZero showAnimation:NO];
            [self.view addSubview:self.detailSheet];
            [UIView animateWithDuration: 0.25 animations: ^{
                [self.detailSheet shouAttribute];
                self.detailSheet.sourceType = STLAppsflyerGoodsSourceFlashList;
                self.detailSheet.type = GoodsDetailEnumTypeAdd;
            } completion: nil];
            
        }
    } failure:^(id obj) {
    }];
}


- (void)showSheetView:(OSSVFlashSaleGoodsModel *)baseInfoModel index:(NSInteger)index{
    if (!baseInfoModel) {
        return;
    }
    self.hasFirtFlash = NO;
    self.detailSheet.analyticsDic = @{kAnalyticsPositionNumber:@(index+1),
                                      kAnalyticsKeyWord:STLToString(self.transmitMutDic[kAnalyticsKeyWord]),
    }.mutableCopy;
    [self requesData:baseInfoModel.goodId wid:baseInfoModel.wid];

}
#pragma mark - YNPageViewControllerDataSource

- (UIScrollView *)pageViewController:(YNPageViewController *)pageViewController pageForIndex:(NSInteger)index {
    UIViewController *vc = pageViewController.controllersM[index];
    NSLog(@"点击了地%ld个栏目",index);
    if ([vc isKindOfClass:[OSSVFlashSaleVC class]]) {
        OSSVFlashSaleVC *flashVc = (OSSVFlashSaleVC *) vc;
        return [flashVc querySubScrollView];
    } else if ([vc isKindOfClass:[OSSVFlashSaleNotStartVC class]]) {
        OSSVFlashSaleNotStartVC *vc1 = (OSSVFlashSaleNotStartVC *)vc;
        return [vc1 querySubScrollView];
    }
    return [[UIScrollView alloc] initWithFrame:CGRectZero];
}

///上下滚动的代理方法
- (void)pageViewController:(YNPageViewController *)pageViewController
            contentOffsetY:(CGFloat)contentOffset
                  progress:(CGFloat)progress {
    STLLog(@"----%f  %f",SCREEN_HEIGHT,200*kScale_375);
    NSLog(@"---bgH: %f --%f ===  contentOffset = %f", pageViewController.bgScrollView.contentSize.height,pageViewController.pageScrollView.contentSize.height, contentOffset);

}

//左右滚动调用方法
- (void)pageViewController:(YNPageViewController *)pageViewController
        didEndDecelerating:(UIScrollView *)scrollView {

    STLLog(@"%f --- %f",SCREEN_HEIGHT - kNavHeight - kTabHeight - 44,scrollView.height);

    STLLog(@"--%f",self.pageVC.pageScrollView.height);

    self.pageVC.bgScrollView.showsVerticalScrollIndicator = NO;
    self.pageVC.pageScrollView.showsVerticalScrollIndicator = NO;
}


- (void)pageViewController:(YNPageViewController *)pageViewController
                 didScroll:(UIScrollView *)scrollView
                  progress:(CGFloat)progress
                 formIndex:(NSInteger)fromIndex
                   toIndex:(NSInteger)toIndex {
}

- (OSSVDetailsViewModel *)baseInfoModel {
    if (!_baseInfoModel) {
        _baseInfoModel = [[OSSVDetailsViewModel alloc] init];
    }
    return _baseInfoModel;
}



- (STLActionSheet *)detailSheet {
    if (!_detailSheet) {
        CGFloat detailSheetY = kIS_IPHONEX? 88.f : 64.f;
            _detailSheet = [[STLActionSheet alloc] initWithFrame:CGRectMake(0, -detailSheetY, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _detailSheet.type = GoodsDetailEnumTypeAdd;
        _detailSheet.hasFirtFlash = YES;
        _detailSheet.isListSheet = YES;
        _detailSheet.addCartType = 1;
        @weakify(self)
        _detailSheet.cancelViewBlock = ^{   // cancel block
            
//            [self restoreTransform];
        };
        _detailSheet.attributeBlock = ^(NSString *goodsId,NSString *wid) {
            @strongify(self)
            [self requesData:goodsId wid:wid];
        };
        
        _detailSheet.attributeNewBlock = ^(NSString *goodsId, NSString *wid, NSString *specialId) {
            @strongify(self)
            [self requesData:goodsId wid:wid specialId:specialId];
        };
        
        _detailSheet.addCartEventBlock = ^(BOOL flag) {
            
        };
        
        _detailSheet.attributeHadManualSelectSizeBlock = ^{
            @strongify(self)
            self.baseInfoModel.hadManualSelectSize = YES;
        };
        
        
        _detailSheet.goNewToDetailBlock = ^(NSString *goodsId, NSString *wid, NSString *specialId, NSString *goodsImageUrl) {
            @strongify(self)
            OSSVDetailsVC *detailVC = [[OSSVDetailsVC alloc] init];
            detailVC.goodsId = goodsId;
            detailVC.wid = wid;
            detailVC.specialId = specialId;
            detailVC.sourceType = STLAppsflyerGoodsSourceFlashList;
            detailVC.coverImageUrl = STLToString(goodsImageUrl);
            [self.navigationController pushViewController:detailVC animated:YES];
            
            [self.detailSheet dismiss];
        };
    }
    return _detailSheet;
}

#pragma mark --购物车图标
- (void)refreshBagValues {
    [self showCartCount];
}
- (void)showCartCount {
    NSInteger allGoodsCount = [[OSSVCartsOperateManager sharedManager] cartValidGoodsAllCount];
    self.badgeView.badgeText = nil;
    if (allGoodsCount > 0) {
        self.badgeView.badgeText = [NSString stringWithFormat:@"%lu",(unsigned long)allGoodsCount];
        if (allGoodsCount > 99) {
            allGoodsCount = 99;
            self.badgeView.badgeText = [NSString stringWithFormat:@"%lu+",(unsigned long)allGoodsCount];
        }
    }
}



#pragma mark - 空白View
- (void)createEmptyViews {
    self.emptyBackView = [[UIScrollView alloc] init];
    self.emptyBackView.hidden = YES;
    [self.view addSubview:self.emptyBackView];
    [self.emptyBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.top.mas_equalTo(self.view);
    }];
    
    // 这样做是为了增加  菊花的刷新效果
    @weakify(self)
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self)
        @weakify(self)
        [self requestChannelItemData:^(BOOL flag) {
            @strongify(self)
            [self.emptyBackView.mj_header endRefreshing];
        }];
    }];
    // 隐藏时间
    header.lastUpdatedTimeLabel.hidden = YES;

    // 隐藏状态
    header.stateLabel.hidden = YES;
    self.emptyBackView.mj_header = header;
    
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:@"loading_failed"];
    [self.emptyBackView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.emptyBackView.mas_top).offset(52 * DSCREEN_WIDTH_SCALE);
        make.centerX.mas_equalTo(self.emptyBackView.mas_centerX);
    }];
    
    UILabel *titleLabel = [UILabel new];
    self.loadingfaildLbl = titleLabel;
    titleLabel.textColor = OSSVThemesColors.col_333333;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.text = STLLocalizedString_(@"load_failed", nil);;
    [self.emptyBackView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imageView.mas_bottom).offset(36);
        make.centerX.mas_equalTo(self.emptyBackView.mas_centerX);
    }];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    self.reloadButton = button;
    button.backgroundColor = [OSSVThemesColors col_262626];
    button.titleLabel.font = [UIFont stl_buttonFont:14];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (APP_TYPE == 3) {
        [button setTitle:STLLocalizedString_(@"retry", nil) forState:UIControlStateNormal];
    } else {
        [button setTitle:STLLocalizedString_(@"retry", nil).uppercaseString forState:UIControlStateNormal];
    }
    [button addTarget:self action:@selector(emptyHomeTapAction) forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 3;
    [self.emptyBackView addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLabel.mas_bottom).mas_offset(33);
        make.centerX.mas_equalTo(self.emptyBackView.mas_centerX);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(40);
    }];
}

- (void)emptyHomeTapAction {
    if (!self.success) {
        [self.emptyBackView.mj_header beginRefreshing];
    }else{
        if (!self.hasTabs) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}


@end
