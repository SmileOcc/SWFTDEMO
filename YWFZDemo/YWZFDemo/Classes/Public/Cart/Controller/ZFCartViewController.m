//
//  ZFCartViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/4/25.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCartViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFShoppingCarTopTipView.h"
#import "FilterManager.h"
#import "ZFOrderManager.h"

#import "ZFCollectionViewModel.h"
#import "ZFCartViewModel.h"
#import "ZFCartListResultModel.h"
#import "ZFCartGoodsListModel.h"
#import "ZFCartGoodsModel.h"
#import "CheckOutGoodListModel.h"
#import "ZFOrderCheckInfoModel.h"
#import "GoodsDetailModel.h"
#import "ZFBannerModel.h"
#import "ZFOrderCheckInfoDetailModel.h"

#import "FastPamentView.h"
#import "ZFNoNetEmptyView.h"
#import "ZFCartBottomPriceView.h"
#import "ZFCartDiscountHeaderView.h"
#import "ZFCartNormalHeaderView.h"
#import "ZFCartDiscountGoodsCell.h"
#import "ZFCartUnavailableHeaderView.h"
#import "ZFCartUnavailableGoodsCell.h"
#import "ZFCartUnavailableViewAllFooterView.h"
#import "ZFCartFreeGiftHearderView.h"
#import "ZFCartFreeGiftTableViewCell.h"

#import "ZFGoodsDetailViewController.h"
#import "ZFWebViewViewController.h"
#import "ZFAddressEditViewController.h"
#import "ZFOrderInfoViewController.h"
#import "ZFOrderContentViewController.h"
#import "ZFFreeGiftsViewController.h"
#import "ZFCollectionViewController.h"
#import "ZFUnlineSimilarViewController.h"
#import "ZFCarPiecingOrderVC.h"
#import "ZFFullReductionViewController.h"
#import "ZFCartListModel.h"
#import "ZFCarRecommendView.h"
#import "ZFCarCouponDetailsCodeHeaderView.h"
#import "ZFMyCouponViewController.h"
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalyticsTimeManager.h"
#import "ZFGrowingIOAnalytics.h"
#import "BannerManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "ZFRequestModel.h"
#import "Masonry.h"
#import "AccountManager.h"
#import "Constants.h"
#import "ZFCarHeaderInfoView.h"

#import "ZFMyOrderListViewModel.h"
#import "ZFMyOrderListModel.h"
#import "ZFCommonRequestManager.h"
#import "ZFPaymentViewController.h"
#import <GGBrainKeeper/BrainKeeperManager.h>
#import "ZFCartNormalFooterView.h"
#import "ZFGoodsDetailSelectTypeView.h"
#import "ZFCarRecommendGoodsHeaderView.h"
#import "ZFBranchAnalytics.h"
#import "ZFBTSManager.h"
#import "ZFGameLoginView.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>

//卡片式l距离屏幕边缘间距 V4.5.7
static NSInteger kCardMargin = 12;
// 推荐商品Header栏
#define kRecommendViewHeight  (250 * 1 + 12)

static NSString *const kZFCartDiscountHeaderViewIdentifier              = @"kZFCartDiscountHeaderViewIdentifier";
static NSString *const kZFCartNormalHeaderViewIdentifier                = @"kZFCartNormalHeaderViewIdentifier";
static NSString *const kZFCartDiscountGoodsCellIdentifier               = @"kZFCartDiscountGoodsCellIdentifier";
static NSString *const kZFCartUnavailableHeaderViewIdentifier           = @"kZFCartUnavailableHeaderViewIdentifier";
static NSString *const kZFCartUnavailableGoodsCellIdentifier            = @"kZFCartUnavailableGoodsCellIdentifier";
static NSString *const kZFCartUnavailableViewAllViewIdentifier          = @"kZFCartUnavailableViewAllViewIdentifier";
static NSString *const kZFCartFreeGiftHearderViewIdentifier             = @"kZFCartFreeGiftHearderViewIdentifier";
static NSString *const kZFCartFreeGiftTableViewCellIdentifier           = @"kZFCartFreeGiftTableViewCellIdentifier";
static NSString *const ZFCarCouponDetailsCodeHeaderViewIdentifier       = @"ZFCarCouponDetailsCodeHeaderViewIdentifier";
static NSString *const kZFCartSectionFooterViewIdentifier               = @"kZFCartSectionFooterViewIdentifier";
static NSString *const KZFCartDefaultEmptyCellIdentifier                = @"KZFCartDefaultEmptyCellIdentifier";
static NSString *const kZFCarRecommendGoodsHeaderViewIdentifier         = @"kZFCarRecommendGoodsHeaderViewIdentifier";

@interface ZFCartViewController () <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) BOOL                                  isUnavailableViewAll;
@property (nonatomic, strong) ZFShoppingCarTopTipView               *topTipView;
@property (nonatomic, strong) UITableView                           *tableView;
@property (nonatomic, strong) ZFCartBottomPriceView                 *bottomPriceView;
@property (nonatomic, strong) UIView                                *tmpWhiteView;
@property (nonatomic, strong) UIView                                *editCellBgWhiteView;
@property (nonatomic, strong) ZFCartListResultModel                 *cartListResultModel;
@property (nonatomic, strong) NSMutableArray                        *selectGoodsArray;
@property (nonatomic, strong) ZFCarRecommendView                    *tableFooterView;
@property (nonatomic, strong) NSArray                               *recommendGoodsArray;
@property (nonatomic, assign) BOOL                                  hasAddRecommendHeader;
@property (nonatomic, assign) BOOL                                  isHasShowMoveWilshTip;
@property (nonatomic, strong) AFparams                              *recomendAFParams;
@property (nonatomic, assign) CGFloat                               couponHeaderHeight;
@property (nonatomic, assign) NSInteger                             unpaidRequestFlag;//防止偶尔接口报202错误,循环调用接口
@property (nonatomic, strong) MyOrdersModel                         *unpaidOrderModel;
@property (nonatomic, strong) ZFCartViewModel                       *cartViewModel;
@property (nonatomic, strong) ZFGoodsDetailSelectTypeView           *selectSizeView;
@property (nonatomic, assign) BOOL                                  hasOpenSizeView;
@property (nonatomic, copy) NSString                                *selecteEditGoodsId;
@property (nonatomic, assign) NSInteger                             selecteEditGoodsNumber;
@property (nonatomic, assign) BOOL                                  isEmptyCart;
@property (nonatomic, strong) NSMutableArray                        *sectionBgCornerViewArr;
@end

@implementation ZFCartViewController

#pragma mark - Life Cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_selectSizeView) {
        [_selectSizeView removeFromSuperview];
        self.selectSizeView = nil;
    }
    if (_bottomPriceView) {
        [self.bottomPriceView invalidateTipTimer];
    }
    // 清除购物车选择主动记住的全局优惠券
    [AccountManager clearUserSelectedCoupon];
    [self configCartCountDownTimer:NO];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selecteEditGoodsNumber = 1;
    [self cofigNavigationView];
    [self zfInitView];
    [self zfAutoLayoutView];
    [self addNotificationObjects];
    [ZFAnalytics screenViewQuantityWithScreenName:@"Bag"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 请求数据购物车列表数据
    [self requestCartListData:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_selectSizeView) {
        self.selectSizeView.hidden = YES;
    }
}

/**
 * 显示移入收藏夹动画
 */
- (void)showMoveToWlishGifImageView:(NSTimeInterval)duration {
    if (self.cartListResultModel.goodsBlockList.count == 1 && ((ZFCartGoodsListModel *)self.cartListResultModel.goodsBlockList.firstObject).goodsModuleType.integerValue == ZFCartListBlocksTypeRecommendGoods) {
        YWLog(@"只有一个对象是推荐商品时不显示移入收藏夹动画");
        return;
    }
    
    NSNumber *showNum = GetUserDefault(KCarShowMoveToWlishKey);
    if (!showNum || ![showNum boolValue]) {
        SaveUserDefault(KCarShowMoveToWlishKey, @(YES));
        self.isHasShowMoveWilshTip = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //购物车顶部提示语高度
            CGFloat topOffset = 0;
            CGRect rect = CGRectZero;
            rect.size = [self.topTipView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
            //空的高度时，不加
            if (rect.size.height > [self.topTipView emptViewMinHeight]) {
                topOffset += rect.size.height;
            }
            //第一个组头高度
            if (self.cartListResultModel.goodsBlockList.count > 0) {
                topOffset += 50;
            }
            @weakify(self)
            ShowGifImageWithGifPathToTransparenceScreenView(topOffset, CGSizeMake(270, 144),  @"car_tipMoveWilsh_gif.gif",@"car_tipMoveWilsh", ^{
                @strongify(self)
                self.isHasShowMoveWilshTip = NO;
            });
        });
    }
}

#pragma mark - private methods

- (void)cofigNavigationView {
    [self refreshSelfTitle];
    
    UIButton *rightNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightNavBtn setFrame:CGRectMake(0, 0, NavBarButtonSize, NavBarButtonSize)];
    [rightNavBtn setImage:ZFImageWithName(@"cart_wishlist") forState:UIControlStateNormal];
    [rightNavBtn addTarget:self action:@selector(wishBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    rightNavBtn.adjustsImageWhenHighlighted = NO;
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:rightNavBtn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, buttonItem];
}

- (void)refreshSelfTitle {
    NSInteger badgeNum = [GetUserDefault(kCollectionBadgeKey) integerValue];
    self.title = [NSString stringWithFormat:@"%@(%zd)",ZFLocalizedString(@"ZFCheckout_mybag",nil), badgeNum];
}

#pragma mark -============ NSNotification ============

- (void)addNotificationObjects {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCarListDataFromNotify:) name:kLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCarListDataFromNotify:) name:kLogoutNotification object:nil];
    // 购物车不能监听bage数据的通知,因为会导致页面接口一直循环调用
}

// 通知刷新购物车列表数据
- (void)refreshCarListDataFromNotify:(NSNotification *)notify {
    NSDictionary *notifyDict = [notify userInfo];
    if (ZFJudgeNSDictionary(notifyDict)) {
        UIView *loadingView = notifyDict[kLoadingView];
        if ([loadingView isEqual:self.view]) {
            return;//如果是当前页面发出的通知则不处理
        }
    }
    [self requestCartListData:nil];
}

#pragma mark -===========购物车列表头部订单,底部推荐请求===========

/**
 * 请求展示未支付订单view
 */
- (void)requestShowUnpaidOrderInfoView {
    // 接口报202错误时,网络底层会发出需要登录通知, 购物车会监听此通知时,一定需要防止循环调用接口
    if (!ISLOGIN || self.unpaidRequestFlag == -1) return;
    
    [ZFCommonRequestManager requestHasNoPayOrderTodo:^(MyOrdersModel *orderModel) {
        self.unpaidRequestFlag = 1;
        self.unpaidOrderModel = orderModel;
        [self configCartCountDownTimer:YES];
        
        // 等购物车数据回来才刷新
        if (self.cartListResultModel.goodsBlockList) {
            [self refreshTableHeaderFooterView];
        }
    } failBlcok:^(NSError *error) {
        self.unpaidRequestFlag = 1;
        if (error.code == 202) {
            self.unpaidRequestFlag = -1;
        }
    } target:self];
}

/// 判断是否需要开启/关闭定时器
- (void)configCartCountDownTimer:(BOOL)firingTimer {
    if (firingTimer) {
        unsigned long long timcountdownTime = [self.unpaidOrderModel.pay_left_time longLongValue];
        if (timcountdownTime > 0) { //开启倒计时
            NSString *countDownCartTimerKey = [NSString stringWithFormat:@"ZFCartViewController-%@", self.unpaidOrderModel.order_id];
            self.unpaidOrderModel.countDownCartTimerKey = countDownCartTimerKey;
            [[ZFTimerManager shareInstance] startTimer:countDownCartTimerKey];
        }
    } else { //关闭倒计时
        NSString *cartTimerKey = self.unpaidOrderModel.countDownCartTimerKey;
        if (!ZFIsEmptyString(cartTimerKey)) {
            [[ZFTimerManager shareInstance] stopTimer:cartTimerKey];
        }
    }
}

/**
 * 请求购物车推荐商品数据
 */
- (void)requestCarRecommendGoods {
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.eventName = @"recommend_goods";
    requestModel.taget = self;
    requestModel.needToCache = YES;
    
    BOOL hasCarGoodsData = (self.cartListResultModel.goodsBlockList.count > 0);
    if (!ISLOGIN && !hasCarGoodsData) {
        requestModel.url = API(Port_bigData_homeRecommendGoods);//请求大数据
        requestModel.parmaters = @{@"page"           : @(1),
                                   @"appsFlyerUID"   : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                                   ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
        };
    } else {
        requestModel.url = API(Prot_cartRecommendGoods);
        requestModel.parmaters = @{@"sess_id"       :  (ISLOGIN ? @"" : ZFToString(SESSIONID)),
                                   @"appsFlyerUID"  : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                                   ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
        };
    }
    
    @weakify(self);
    [ZFNetworkHttpRequest sendExtensionRequestWithParmaters:requestModel success:^(id responseObject) {
        @strongify(self);
        NSDictionary *resultDict = responseObject[ZFResultKey];
        if (!ZFJudgeNSDictionary(resultDict)) return;
        
        NSArray *goods_list = resultDict[@"goods_list"];
        if (!ZFJudgeNSArray(goods_list) || goods_list.count == 0) return;
        self.recommendGoodsArray = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:goods_list];
        
        NSDictionary *paramsDict = resultDict[@"af_params"];
        if (!ZFJudgeNSDictionary(paramsDict)) return;
        self.recomendAFParams = [AFparams yy_modelWithJSON:paramsDict];
        
        if (!ISLOGIN && !hasCarGoodsData) {
            self.recomendAFParams.sourceType = ZFAppsflyerInSourceTypeCartEmptyDataRecommend;
        } else {
            self.recomendAFParams.sourceType = ZFAppsflyerInSourceTypeCarRecommend;
        }
        [self showRecommendGoodsList];
        
    } failure:nil];
}

/// 显示购物车推荐商品列表
- (void)showRecommendGoodsList {
    if (self.recommendGoodsArray.count == 0) return;
    NSArray *cartGoodsArray = self.cartListResultModel.goodsBlockList;
    
    BOOL isAlreadyInsert = NO;
    if (self.hasAddRecommendHeader == NO) {
        
        // V4.5.7有商品时: 在有效商品上面 增加一栏来显示推荐商品栏HeaderView
        NSInteger addRecommendIndex = cartGoodsArray.count;
        for (NSInteger i=0; i<cartGoodsArray.count; i++) {
            ZFCartGoodsListModel *blockModel = cartGoodsArray[i];
            if ([blockModel.goodsModuleType integerValue] == ZFCartListBlocksTypeUnavailable) {
                addRecommendIndex = i;
            }
            if ([blockModel.goodsModuleType integerValue] == ZFCartListBlocksTypeRecommendGoods) {
                isAlreadyInsert = YES;
            }
        }
        if (!isAlreadyInsert) {
            ZFCartGoodsListModel *blockModel = [[ZFCartGoodsListModel alloc] init];
            blockModel.goodsModuleType = [NSString stringWithFormat:@"%ld", (long)ZFCartListBlocksTypeRecommendGoods];
            self.hasAddRecommendHeader = YES;
            if (self.cartListResultModel.goodsBlockList == nil) {
                self.cartListResultModel.goodsBlockList = [NSMutableArray array];
            }
            [self.cartListResultModel.goodsBlockList insertObject:blockModel atIndex:addRecommendIndex];
            [self.tableView reloadData];
        }
    }
    if (!self.tableView.tableFooterView) {
        if (cartGoodsArray.count == 1
            && ((ZFCartGoodsListModel *)cartGoodsArray.firstObject).goodsModuleType.integerValue == ZFCartListBlocksTypeRecommendGoods) {
            YWLog(@"只有一个对象是推荐商品时不显示 imageView");
        } else {
            // V4.7.0 显示安全logo
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 35)];
            imageView.contentMode = UIViewContentModeTop;
            imageView.image = [UIImage imageNamed:@"pay_safe_logo"];
            self.tableView.tableFooterView = imageView;
        }
    }
}

#pragma mark -===========购物车列表数据请求===========

/**
 * 请求购物车列表数据
 */
- (void)requestCartListData:(void(^)(void))completion {
    self.hasAddRecommendHeader = NO;
    
    BOOL isEmptyData = self.cartListResultModel.goodsBlockList.count == 0;
    if (isEmptyData) {
        ShowLoadingToView(self.view);
        
        NSInteger badgeNum = [GetUserDefault(kCollectionBadgeKey) integerValue];
        if (badgeNum == 0) {
            // 列表为空时: 请求展示未支付订单view
            [self requestShowUnpaidOrderInfoView];
        }
    }
    
    @weakify(self)
    [self.cartViewModel requestCartListWithGiftFlag:@"1" completion:^(ZFCartListResultModel *cartListModel) {
        @strongify(self);
        [self handleCartListDataSuccess:cartListModel];
        [self cartViewPageAnalytics];
        
        // V4.6.0后每次都请求商品推荐位
        [self requestCarRecommendGoods];
        
        //一些弹框
        if (cartListModel.goodsBlockList.count > 0) {
            //显示一次移入收藏夹动画
            [self showMoveToWlishGifImageView:0.1];
            // 学生卡优惠的弹窗
            [self alertStudentMarkTips];
        }
        if (completion) {
            completion();
        }
    } failure:^(id obj) {
        @strongify(self);
        [self refreshCarListGoodsDataUI];
        [self.tableView reloadData];
        [self.tableView showRequestTip:nil];
        HideLoadingFromView(self.view);
    }];
}

///统一处理购物车数据方法
- (void)handleCartListDataSuccess:(ZFCartListResultModel *)cartListModel
{
    HideLoadingFromView(self.view);
    self.cartListResultModel = cartListModel;
    SaveUserDefault(kCollectionBadgeKey, @(self.cartListResultModel.totalNumber));
    self.bottomPriceView.model = self.cartListResultModel;
    self.hasAddRecommendHeader = NO;
    [self refreshSelfTitle];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCartNotification object:nil userInfo:@{kLoadingView : self.view}];
    
    NSInteger addCouponIndex = cartListModel.goodsBlockList.count;
    for (NSInteger i=0; i<cartListModel.goodsBlockList.count; i++) {
        ZFCartGoodsListModel *blockModel = cartListModel.goodsBlockList[i];
        if ([blockModel.goodsModuleType integerValue] == ZFCartListBlocksTypeUnavailable) {
            addCouponIndex = i;
        }
    }
    NSInteger addRecommendIndex = addCouponIndex;
    
    //  在有效商品下面 与 失效/赠品商品上面 增加一栏来显示优惠券栏HeaderView
    if (addCouponIndex > 0) {
        ZFCartGoodsListModel *blockModel = [[ZFCartGoodsListModel alloc] init];
        blockModel.goodsModuleType = [NSString stringWithFormat:@"%ld", (long)ZFCartListBlocksTypeCouponDetailsCode];
        [cartListModel.goodsBlockList insertObject:blockModel atIndex:addCouponIndex];
        
        // 计算优惠券栏HeaderView高度
        if (self.cartListResultModel.isAllUnavailableGoodsOrNoGoods) {
            self.couponHeaderHeight = 36;////这里本应该为48,因为有footer高度12的圆角在底部需要减去
        } else {
            self.couponHeaderHeight = 241;
            if (cartListModel.cart_discount_amount.floatValue == 0.0) {
                self.couponHeaderHeight -= 40;// (Event Discoun可选显示高度)
            }
            if (cartListModel.student_discount_amount.floatValue == 0.0) {
                self.couponHeaderHeight -= 40;// (Student Discount可选显示高度)
            }
        }
        addRecommendIndex = addCouponIndex + 1;
    }
    
    // V4.5.7有商品时: 在有效商品上面 增加一栏来显示推荐商品栏HeaderView
    if (cartListModel.goodsBlockList.count > 0 && self.recommendGoodsArray.count >0) {
        ZFCartGoodsListModel *blockModel = [[ZFCartGoodsListModel alloc] init];
        blockModel.goodsModuleType = [NSString stringWithFormat:@"%ld", (long)ZFCartListBlocksTypeRecommendGoods];
        if (addRecommendIndex > cartListModel.goodsBlockList.count) {
            addRecommendIndex = cartListModel.goodsBlockList.count;
        }
        self.hasAddRecommendHeader = YES;
        [cartListModel.goodsBlockList insertObject:blockModel atIndex:addRecommendIndex];
    }
    [self refreshCarListGoodsDataUI];
    [self refreshTableHeaderFooterView];
    [self.tableView reloadData];
}

/**
 * 统一处理表格头部和尾部显示数据
 * 1. 登录:
 有商品: 显示商品,显示底部推荐位
 无商品: 有订单): 显示头部未支付订单,显示底部推荐位  | 无订单): 显示头部空白页, 显示底部推荐位
 
 * 2. 未登录:
 有商品: 显示商品,显示底部推荐位
 无商品: 显示新版头部空白页, 显示底部推荐位 (V4.6.0)
 */
- (void)refreshTableHeaderFooterView {
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.tableFooterView = nil;
    
    BOOL hasCarGoodsData = (self.cartListResultModel.goodsBlockList.count > 0);
    if (self.cartListResultModel.goodsBlockList.count == 1) {
        ZFCartGoodsListModel *blockModel = self.cartListResultModel.goodsBlockList.firstObject;
        if ([blockModel.goodsModuleType integerValue] == ZFCartListBlocksTypeRecommendGoods) {
            hasCarGoodsData = NO; //只有一栏推荐数据
        }
    }
    if (ISLOGIN) {
        if (!hasCarGoodsData) {
            ZFCarHeaderInfoShowUIType headerType = self.unpaidOrderModel ? ZFCarHeaderUI_WaitingPayment : ZFCarHeaderUI_EmptyData;
            self.tableView.tableHeaderView = [self showHeaderView:headerType orderModel:self.unpaidOrderModel];
        }
    } else {
        if (!hasCarGoodsData) {
            self.tableView.tableHeaderView = [self showHeaderView:ZFCarHeaderUI_ForNewUser orderModel:nil];
        }
    }
    [self showRecommendGoodsList];
    // 控制上下拉控件和空白页
    [self.tableView showRequestTip:@{}];
}

/// 根据购物车数据刷新 顶部和底部UI
- (void)refreshCarListGoodsDataUI {
    BOOL isEmptyData = self.cartListResultModel.goodsBlockList.count == 0;
    self.bottomPriceView.hidden = isEmptyData;
    self.tmpWhiteView.backgroundColor = isEmptyData ? ZFC0xF2F2F2(): ZFCOLOR_WHITE;
    
    NSString *allTipText = @"";
    BOOL showArrow = NO;
    if (!ZFIsEmptyString(self.cartListResultModel.cartRadioHint)) {
        allTipText = self.cartListResultModel.cartRadioHint;
        NSString *replaceText = self.cartListResultModel.cart_shipping_free_amount_replace;
        showArrow = [self.cartListResultModel.cart_shipping_free_amount floatValue]>0;
        NSString *price = nil;
        if (!ZFIsEmptyString(replaceText) && replaceText.length > 1) {
            price = [replaceText substringFromIndex:1];
        }
        if (price && [allTipText containsString:replaceText]) {
            NSString *amount = [ExchangeManager transforPrice:price];
            NSInteger priceLocation = [[allTipText componentsSeparatedByString:replaceText] firstObject].length;
            NSRange range = NSMakeRange(priceLocation, replaceText.length);
            if (!ZFIsEmptyString(amount)) {
                allTipText = [allTipText stringByReplacingCharactersInRange:range withString:amount];
            }
        }
    }
    
    // 刷新顶部提示文案
    if (!isEmptyData && !ZFIsEmptyString(self.cartListResultModel.cartRadioHint)) {
        self.topTipView.hidden = NO;
        [self.topTipView cartTipText:allTipText showArrow:showArrow bgColor:ZFC0x06B190()];
    } else {
        self.topTipView.hidden = YES;
    }
    NSDictionary *detailVCTipsDict = @{@"tipText"  : ZFToString(allTipText),
                                       @"showArrow": @(showArrow)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshGoodsDetailCartInfoNotification object:detailVCTipsDict];
    
    self.isEmptyCart = isEmptyData;
    if (isEmptyData) {
        self.tableView.contentInset = UIEdgeInsetsZero;
    } else {
        self.tableView.contentInset = UIEdgeInsetsMake(kCardMargin, 0, kCardMargin, 0);
    }
    // 刷新列表页面表格
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (isEmptyData) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        } else {
            make.top.mas_equalTo(self.topTipView.hidden ? self.topTipView.mas_top : self.topTipView.mas_bottom).offset(0);
            make.leading.mas_equalTo(self.view).offset(kCardMargin);
            make.trailing.mas_equalTo(self.view).offset(-kCardMargin);
            make.bottom.mas_equalTo(self.bottomPriceView.mas_top).offset(kCardMargin);
        }
    }];
    // 刷新选中数据
    [self dealAllSelectGoodsIntoArray];
}

/// 处理购物车全选状态
- (void)dealAllSelectGoodsIntoArray {
    [self.selectGoodsArray removeAllObjects];
    [self.cartListResultModel.goodsBlockList enumerateObjectsUsingBlock:^(ZFCartGoodsListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.goodsModuleType integerValue] != ZFCartListBlocksTypeUnavailable) {
            [obj.cartList enumerateObjectsUsingBlock:^(ZFCartGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.is_selected) {
                    [self.selectGoodsArray addObject:obj];
                }
            }];
        }
    }];
    BOOL enabled = (self.selectGoodsArray && self.selectGoodsArray.count > 0);
    // 刷新底部按钮状态
    [self.bottomPriceView refreshButtonEnabledStatus:enabled];
}

/**
 * 选择商品规格
 */
- (void)selectedGoodsSize:(NSString *)goods_id {
    YWLog(@"选择商品规格===%@", goods_id);
    ShowLoadingToView(self.view);
    [ZFCartViewModel requestCartSizeColorData:goods_id completion:^(GoodsDetailModel *detailModel) {
        HideLoadingFromView(self.view);
        
        if ([detailModel isKindOfClass:[GoodsDetailModel class]]) {
            self.selectSizeView.model = detailModel;
            if (!self.hasOpenSizeView) {
                [self.selectSizeView openSelectTypeView];
            }
            
            //用户点击查看商品
            NSMutableDictionary *valuesDic     = [NSMutableDictionary dictionary];
            valuesDic[AFEventParamContentId]   = ZFToString(detailModel.goods_sn);
            valuesDic[AFEventParamContentType] = @"product";
            valuesDic[AFEventParamPrice]       = ZFToString(detailModel.shop_price);
            valuesDic[AFEventParamCurrency]    = @"USD";
            valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeCartProduct sourceID:nil];
            valuesDic[@"af_changed_size_or_color"] = @"1";
            valuesDic[BigDataParams]           = [detailModel gainAnalyticsParams];
            [ZFAppsflyerAnalytics zfTrackEvent:@"af_view_product" withValues:valuesDic];
            
            [ZFFireBaseAnalytics scanGoodsWithGoodsModel:detailModel];
            // 谷歌统计
            [ZFAnalytics scanProductDetailWithProduct:detailModel screenName:@"Product Detail"];
            //Branch
            [[ZFBranchAnalytics sharedManager] branchViewItemDetailWithProduct:detailModel];
            //GrowingIO商品详情查看
            [ZFGrowingIOAnalytics ZFGrowingIOProductDetailShow:detailModel];
        }
    } failure:^(NSError *error) {
        ShowToastToViewWithText(self.view, error.domain);
    }];
}

/**
 *  编辑切换商品规格完成
 */
- (void)selectedEditGoodsWithGoodsId:(NSString *)oldId newGoodsId:(NSString *)newGoodsId {
    NSDictionary *dict = @{@"old_goods_id"     : ZFToString(oldId),
                           @"update_goods_id"  : ZFToString(newGoodsId),
                           ZFApiTokenKey       : ZFToString(TOKEN),
                           ZFApiSessId         : ZFToString(SESSIONID)};
    [self sendCarRequestWithUrl:Port_UpdateCartGoods parmaters:dict];
    self.selecteEditGoodsId = nil;
    
    //添加商品至购物车事件统计
    NSString *goodsSN = self.selectSizeView.model.goods_sn;
    NSString *spuSN = @"";
    if (goodsSN.length > 7) {  // sn的前7位为同款id
        spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
    }else{
        spuSN = goodsSN;
    }
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId] = ZFToString(goodsSN);
    valuesDic[@"af_spu_id"] = ZFToString(spuSN);
    valuesDic[AFEventParamPrice] = ZFToString(self.selectSizeView.model.shop_price);
    valuesDic[AFEventParamQuantity] = [NSString stringWithFormat:@"%zd",self.selecteEditGoodsNumber];
    valuesDic[AFEventParamContentType] = @"product";
    valuesDic[@"af_content_category"] = ZFToString(self.selectSizeView.model.long_cat_name);
    valuesDic[AFEventParamCurrency] = @"USD";
    valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeCartProduct sourceID:nil];
    valuesDic[@"af_changed_size_or_color"] = @"1";
    valuesDic[BigDataParams]           = @[[self.selectSizeView.model gainAnalyticsParams]];
    valuesDic[@"af_purchase_way"] = @"1";//V5.0.0增加, 判断是否为一键购买(0)还是正常加购(1)
    
    [ZFAnalytics appsFlyerTrackEvent:@"af_add_to_bag" withValues:valuesDic];
    
    self.selectSizeView.model.buyNumbers = self.selecteEditGoodsNumber;
    [ZFAnalytics addToCartWithProduct:self.selectSizeView.model fromProduct:YES];
    [ZFFireBaseAnalytics addToCartWithGoodsModel:self.selectSizeView.model];
    //Branch
    [[ZFBranchAnalytics sharedManager] branchAddToCartWithProduct:self.selectSizeView.model number:self.selecteEditGoodsNumber];
    [ZFGrowingIOAnalytics ZFGrowingIOAddCart:self.selectSizeView.model];
}

/**
 * 再次购买
 */
- (void)requestReturnToBag:(NSString *)orderId {
    NSDictionary *dict = @{@"order_id"    : ZFToString(orderId),
                           kLoadingView   : self.view};
    @weakify(self)
    [[ZFMyOrderListViewModel new] requestReturnToBag:dict completion:^(id obj) {
        @strongify(self);
        HideLoadingFromView(self.view);
        [self requestCartListData:nil];
    } failure:^(id obj) {
        @strongify(self);
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"Failed", nil));
    }];
}

#pragma mark -===========其他操作请求===========

// 购物车大部分接口都返回购物车列表数据公用一个方法处理
- (void)sendCarRequestWithUrl:(NSString *)url parmaters:(NSDictionary *)parmaters {
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(url);
    requestModel.eventName = @"edit_cart";
    requestModel.taget = self;
    
    NSMutableDictionary *InfoDict = [NSMutableDictionary dictionaryWithDictionary:parmaters];
    [InfoDict addEntriesFromDictionary:@{@"auto_add_gift" : @"1",
                                         @"bizhong"       : ZFToString([ExchangeManager localCurrencyName] )}];
    requestModel.parmaters = InfoDict;
    
    [ZFAnalyticsTimeManager recordRequestStartTime:url];
    ShowLoadingToView(self.view);
    @weakify(self)
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        @strongify(self)
        HideLoadingFromView(self.view);
        [ZFAnalyticsTimeManager recordRequestEndTime:url];
        
        NSDictionary *resultDict = responseObject[ZFResultKey];
        if (ZFJudgeNSDictionary(resultDict)) {
            NSDictionary *dataDict = resultDict[ZFDataKey];
            if (ZFJudgeNSDictionary(dataDict) && dataDict.count>0) {
                ZFCartListResultModel *resultModel = [ZFCartListResultModel yy_modelWithJSON:dataDict];
                [self handleCartListDataSuccess:resultModel];
            }
            ShowErrorToastToViewWithResult(self.view, resultDict);//错误提示
        }
    } failure:^(NSError *error) {
        @strongify(self)
        ShowToastToViewWithText(self.view, error.domain);
    }];
}

/**
 * 增减商品数量请求
 */
- (void)cartGoodsNumberEditWithGoodsId:(NSString *)goodsId andGoodsNumber:(NSInteger)goodsNumber {
    NSDictionary *dict = @{@"num"       : @(goodsNumber),
                           @"goods_id"  : goodsId,
                           ZFApiTokenKey: ZFToString(TOKEN),
                           ZFApiSessId  : ZFToString(SESSIONID)};
    [self sendCarRequestWithUrl:Port_editCartGoodsNumber parmaters:dict];
    
    // firebase 统计
    NSString *itemId = [NSString stringWithFormat:@"Click_Bag_Goods_%@_%ld", goodsId, (long)goodsNumber];
    [ZFFireBaseAnalytics selectContentWithItemId:itemId
                                        itemName:@"GoodsNumber"
                                     ContentType:@"Goods_Number"
                                    itemCategory:@"Button"];
}

/**
 * 删除商品
 */
- (void)cartGoodsDeleteOptionWithGoodsId:(NSString *)goodsId {
    NSDictionary *dict = @{@"goods"     : @[ZFToString(goodsId)],
                           ZFApiTokenKey: ZFToString(TOKEN),
                           ZFApiSessId  : ZFToString(SESSIONID)};
    [self sendCarRequestWithUrl:Port_DeleteGoodCart parmaters:dict];
    // firebase 统计
    NSString *itemId = [NSString stringWithFormat:@"Delete_Bag_Goods_%@", goodsId];
    [ZFFireBaseAnalytics selectContentWithItemId:itemId
                                        itemName:@"GoodsDelete"
                                     ContentType:@"Goods_Delete"
                                    itemCategory:@"Button"];
}

/**
 * 删除赠品商品
 */
- (void)cartFreeGiftDeleteOptionWithModel:(ZFCartGoodsModel *)model{
    NSDictionary *dict = @{@"sku"       : ZFToString(model.goods_sn),
                           @"manzeng_id": ZFToString(model.manzeng_id),
                           ZFApiTokenKey: ZFToString(TOKEN),
                           ZFApiSessId  : ZFToString(SESSIONID)};
    [self sendCarRequestWithUrl:Port_freeGiftDelCart parmaters:dict];
}

/**
 * 清除失效商品
 */
- (void)cartClearAllUnavailableGoodsOption {
    NSMutableArray *unavailableGoods = [NSMutableArray array];
    [self.cartListResultModel.goodsBlockList enumerateObjectsUsingBlock:^(ZFCartGoodsListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.goodsModuleType integerValue] == ZFCartListBlocksTypeUnavailable) {
            [obj.cartList enumerateObjectsUsingBlock:^(ZFCartGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [unavailableGoods addObject:obj.goods_id];
            }];
        }
    }];
    NSDictionary *dict = @{@"goods" : unavailableGoods,
                           ZFApiTokenKey: ZFToString(TOKEN),
                           ZFApiSessId  : ZFToString(SESSIONID)};
    [self sendCarRequestWithUrl:Port_DeleteGoodCart parmaters:dict];
}

/**
 * 添加/取消收藏请求
 * type = 0/1 0添加 1取消
 */
- (void)collectionCartGoodsOperation:(ZFCartGoodsModel *)goodsModel
                        isAddCollect:(BOOL)isAddCollect
                    refreshIndexPath:(NSIndexPath *)indexPath {
    
    if (isAddCollect) { // 添加收藏时做统计
        [self addAnalysicsWithCartModel:goodsModel];
    }
    NSDictionary *dict = @{@"goods_id" : goodsModel.goods_id,
                           @"type"     : isAddCollect ? @"0" : @"1",
                           kLoadingView : self.view };
    @weakify(self);
    ShowLoadingToView(self.view);
    [ZFCollectionViewModel requestCollectionGoodsNetwork:dict completion:^(BOOL isOK) {
        @strongify(self);
        HideLoadingFromView(self.view);
        
        if (isOK) {
            YWLog(@"添加/取消收藏请求===OK");
            UIView *loadingView = indexPath ? self.view : nil;
            ShowToastToViewWithText(loadingView, ZFLocalizedString(@"CarVC_AddedWishlist_Success", nil));
        }
        BOOL if_collect = isOK ? isAddCollect : !isAddCollect;
        
        if (indexPath) {
            NSArray *goodsBlockList = self.cartListResultModel.goodsBlockList;
            if (goodsBlockList.count > indexPath.section) {
                ZFCartGoodsListModel *blockModel = goodsBlockList[indexPath.section];
                if (blockModel.cartList.count > indexPath.row) {
                    ZFCartGoodsModel *goodModel = blockModel.cartList[indexPath.row];
                    if (goodModel){
                        goodModel.if_collect = if_collect;
                    }
                }
            }
            [self.tableView reloadData];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kCollectionGoodsNotification object:nil userInfo:dict];
    } target:self];
}

// 编辑Cell删除商品
- (void)deleteGoodsFromEditCell:(NSIndexPath *)indexPath isMoveWishlistFlag:(BOOL)isWishlistFlag {
    if (self.cartListResultModel.goodsBlockList.count <= indexPath.section) return;
    ZFCartGoodsListModel *blockModel = self.cartListResultModel.goodsBlockList[indexPath.section];
    
    if (blockModel.cartList.count <= indexPath.row) return;
    ZFCartGoodsModel *goodModel = blockModel.cartList[indexPath.row];
    if (!goodModel) return;
    
    if (isWishlistFlag) {
        // 从购物车删除
        if (ZFIsEmptyString(goodModel.manzeng_id)) {
            [self cartGoodsDeleteOptionWithGoodsId:goodModel.goods_id];
        } else { // 删除赠品
            [self cartFreeGiftDeleteOptionWithModel:goodModel];
        }
        
        // 移入收藏夹
        if ([blockModel.goodsModuleType integerValue] != ZFCartListBlocksTypeFreeGift &&
            !goodModel.if_collect) {  // 非赠品，没有收藏才加入收藏
            [self collectionCartGoodsOperation:goodModel
                                  isAddCollect:YES
                              refreshIndexPath:nil];
        } else {
            ShowToastToViewWithText(nil, ZFLocalizedString(@"CarVC_AddedWishlist_Success", nil));
        }
    } else {
        NSString *title = ZFLocalizedString(@"CartRemoveProductTips", nil);
        NSArray *btnArr = @[ZFLocalizedString(@"CartRemoveProductYes", nil)];
        NSString *cancelTitle = ZFLocalizedString(@"CartRemoveProductNo", nil);
        ShowAlertView(title, nil, btnArr, ^(NSInteger buttonIndex, id buttonTitle) {
            // 从购物车删除
            if (ZFIsEmptyString(goodModel.manzeng_id)) {
                [self cartGoodsDeleteOptionWithGoodsId:goodModel.goods_id];
            } else { // 赠品
                [self cartFreeGiftDeleteOptionWithModel:goodModel];
            }
        }, cancelTitle, nil);
    }
    // 谷歌统计
    [ZFAnalytics clickButtonWithCategory:@"Bag" actionName:@"Bag - Delete" label:@"Bag - Delete"];
    [ZFAnalytics removeFromCartWithItem:goodModel];
}

#pragma mark ==========支付请求==========

- (void)checkOutButtonAction:(UIButton *)sender {
    //v4.1.0 新增统计事件 v4.2.0后可能删除
    NSMutableArray *contentId = [[NSMutableArray alloc] init];
    [self.selectGoodsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[ZFCartGoodsModel class]]) {
            ZFCartGoodsModel *model = (ZFCartGoodsModel *)obj;
            [contentId addObject:ZFToString(model.goods_sn)];
        }
    }];
    NSDictionary *params = @{@"af_content_type": @"checkout_btn",
                             @"af_content_id": ZFToString([contentId componentsJoinedByString:@","]),
                             };
    [ZFAnalytics appsFlyerTrackEvent:@"af_checkout_btn_click" withValues:params];
    
    //提示用户登陆，登陆成功刷新购物车
    if (![AccountManager sharedManager].isSignIn) {
        //只有这4个国家做游客登录
        NSArray *guestCountry = @[@"us", @"gb", @"ca", @"fr"];
        
        ZFInitCountryInfoModel *countryModel = [AccountManager sharedManager].initializeModel.countryInfo;
        
        NSString *countryCode = countryModel.region_code;
        
        if (![guestCountry containsObject:[countryCode lowercaseString]]) {
            [self oldVersionLogin];
            return;
        }
        //游客登录
        [self newVersionGameLogin];
    } else {
        [self requestCheckoutPayment];
    }
}

- (void)oldVersionLogin
{
//    @weakify(self)
//    [self judgePresentLoginVCCompletion:^{
//        @strongify(self)
//        [self requestCartListData:nil];
//    }];
    @weakify(self)
    [self judgePresentLoginVCChooseType:YWLoginEnterTypeLogin comeFromType:YWLoginViewControllerEnterTypeCartPage Completion:^{
        @strongify(self)
        [self requestCartListData:nil];
    }];
}

/// 游客登录
- (void)newVersionGameLogin {
    ZFGameLoginView *loginView = [[ZFGameLoginView alloc] init];
    @weakify(self)
    [loginView showLoginView:self.view success:^{
        //刷新购物车
        @strongify(self)
        @weakify(self)
        AccountModel *accountModel = [AccountManager sharedManager].account;
        //游客登录时才进入
        if (accountModel.is_guest == 1) {
            [self requestCartListData:^{
                @strongify(self)
                [self checkOutButtonAction:nil];
            }];
        }
    }];
}

/**
 * 请求get_checkout_flow
 */
- (void)requestCheckoutPayment {
    @weakify(self);
    ShowLoadingToView(self.view);
    [self.cartViewModel requestPaymentProcessCompletion:^(NSInteger state, NSString *msg) {
        @strongify(self);
        switch (state) {
            case PaymentProcessTypeOld:
            case PaymentProcessTypeNew:
            {
                NSString *region_code = ZFToString([AccountManager sharedManager].accountCountryModel.region_code);
                if ([region_code isEqualToString:@"US"] || [region_code isEqualToString:@"FR"]) {
                    // checkout前需要请求物流时效BTS
                    [ZFBTSManager asynGetBtsModel:kZFBtsIosdeliverytime
                                    defaultPolicy:@"0"
                                  timeoutInterval:3
                                completionHandler:^(ZFBTSModel * _Nonnull model, NSError * _Nonnull error) {
                        [self oldPaymentProcess];
                    }];
                } else {
                    [self oldPaymentProcess];
                }
            }
                break;
            case PaymentProcessTypeNoGoods:
            {
                if (![NSStringUtils isEmptyString:msg]) {
                    ShowToastToViewWithText(self.view, msg);
                    [self requestCartListData:nil];
                }
            }
                break;
        }
    } failure:^(id obj) {
        @strongify(self);
        HideLoadingFromView(self.view);
    }];
    [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Bag_CheckOut" itemName:@"Check Out" ContentType:@"Payment" itemCategory:@"Button"];
}

// 老的支付方式
- (void)oldPaymentProcess {
    @weakify(self);
    [self.cartViewModel requestCartCheckOutNetwork:nil completion:^(id obj) {
        @strongify(self);
        HideLoadingFromView(self.view);
        
        ZFOrderCheckInfoModel *checkInfoModel = obj;
        ZFOrderCheckInfoDetailModel *model = checkInfoModel.order_info;
        if ([NSStringUtils isEmptyString:model.address_info.address_id]) {
            ZFAddressEditViewController *addressVC = [[ZFAddressEditViewController alloc] init];
            addressVC.sourceCart = YES;
            addressVC.addressEditSuccessCompletionHandler = ^(AddressEditStateType editStateType) {
                @strongify(self);
                [self checkOutButtonAction:nil];
            };
            
            [self.navigationController pushViewController:addressVC animated:YES];
        } else {
            ZFOrderContentViewController *contentVC = [[ZFOrderContentViewController alloc] init];
            contentVC.paymentProcessType = PaymentProcessTypeOld;
            contentVC.payCode = PayCodeTypeOld; // 代表老流程
            contentVC.checkoutModel = model;
            [self.navigationController pushViewController:contentVC animated:YES];
            
            //统计
            ZFOrderManager *manager = [[ZFOrderManager alloc] init];
            NSString *goodsStr      = [manager appendGoodsSN:model];
            NSString *goodsPrices   = [manager appendGoodsPrice:model];
            NSString *goodsQuantity = [manager appendGoodsQuantity:model];
            
            //添加商品至购物车事件
            NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
            valuesDic[AFEventParamContentId] = ZFToString(goodsStr);
            valuesDic[AFEventParamPrice] = ZFToString(goodsPrices);
            valuesDic[AFEventParamQuantity] = ZFToString(goodsQuantity);
            valuesDic[AFEventParamContentType] = @"product";
            valuesDic[AFEventParamCurrency] = @"USD";
            [ZFAnalytics appsFlyerTrackEvent:@"af_process_to_pay" withValues:valuesDic];
            [ZFFireBaseAnalytics beginCheckOutWithGoodsInfo:model];
            //GrowingIO 统计
            [ZFGrowingIOAnalytics ZFGrowingIOCartCheckOut:model];
        }
    } failure:^(NSError *error) {
        @strongify(self);
        HideLoadingFromView(self.view);
        ShowToastToViewWithText(self.view, error.domain);
    }];
}

/**
 * 快捷支付
 */
- (void)fastPaymentButtonAction:(UIButton *)sender {
    @weakify(self);
    ShowLoadingToView(self.view);
    [self.cartViewModel requestPayPaylProcessCompletion:^(NSInteger state, NSString *msg, NSString *url) {
        HideLoadingFromView(self.view);
        @strongify(self);
        switch (state) {
            case PaymentProcessTypeNoGoods:
            {
                if (![NSStringUtils isEmptyString:msg]) {
                    ShowToastToViewWithText(self.view, msg);
                    [self requestCartListData:nil];
                }
            }
                break;
            default:
            {
                //2.使用令牌拼接路径，拿到token和payid
                //                FastPamentView *fastPamentView = [[FastPamentView alloc] init];
                ////                NSString *appAuthQuickPayURL = [YWLocalHostManager appAuthQuickPayURL];
                //                fastPamentView.url = url;//[NSString stringWithFormat:@"%@bizhong=%@&user_id=%@&token=%@&lang=%@&sess_id=%@",appAuthQuickPayURL,[ExchangeManager localCurrencyName],USERID,TOKEN, [ZFLocalizationString shareLocalizable].nomarLocalizable, [AccountManager sharedManager].isSignIn ? @"" : SESSIONID];
                //                fastPamentView.paymentCallBackBlock = ^(NSString *token, NSString *payid) {
                //                    //这里请求类似checkout接口
                //                    @strongify(self);
                //                    [self requestCartFastPayNetworktoken:token payerId:payid];
                //                };
                //                [fastPamentView show];
                ZFPaymentViewController *fastPayment = [[ZFPaymentViewController alloc] init];
                //                NSString *appAuthQuickPayURL = [YWLocalHostManager appAuthQuickPayURL];
                fastPayment.url = url;
                fastPayment.fastCallBackHandler = ^(NSString *token, NSString *payId) {
                    //这里请求类似checkout接口
                    @strongify(self);
                    [self.navigationController popViewControllerAnimated:NO];
                    [self requestCartFastPayNetworktoken:token payerId:payId];
                };
                fastPayment.block = ^(PaymentStatus status) {
                    @strongify(self);
                    [self.navigationController popViewControllerAnimated:YES];
                };
                [self.navigationController pushViewController:fastPayment animated:YES];
                // 谷歌统计
                [ZFAnalytics clickButtonWithCategory:@"Bag" actionName:@"Bag - FastPayment" label:@"Bag - FastPayment"];
                [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Bag_PayPal" itemName:@"PayPal" ContentType:@"Payment" itemCategory:@"Button"];
                [ZFFireBaseAnalytics beginCheckOutWithGoodsInfo:nil];
            }
                break;
        }
    } failure:^(NSError *error) {
        @strongify(self);
        HideLoadingFromView(self.view);
        ShowToastToViewWithText(self.view, error.domain);
    }];
}

/**
 * 快捷支付请求
 */
- (void)requestCartFastPayNetworktoken:(NSString *)token payerId:(NSString *)payid {
    NSMutableDictionary *couponDict = [NSMutableDictionary dictionary];
    couponDict[@"payertoken"] = token;
    couponDict[@"payerId"] = payid;
    couponDict[kLoadingView] = self.view;
    
    @weakify(self);
    [self.cartViewModel requestCartFastPayNetwork:couponDict completion:^(BOOL hasAddress, id obj) {
        @strongify(self)
        
        if (!hasAddress) {
            if (![obj isKindOfClass:[ZFAddressInfoModel class]] && [obj boolValue]) {
                [self.tableView.mj_header beginRefreshing];
                return;
            }
            ZFAddressEditViewController *addressVC = [[ZFAddressEditViewController alloc] init];
            addressVC.sourceCart = YES;
            addressVC.model = obj;
            addressVC.addressEditSuccessCompletionHandler = ^(AddressEditStateType editStateType) {
                @strongify(self);
                if (editStateType != AddressEditStateFail) {
                    [self requestCartFastPayNetworktoken:token payerId:payid];
                }
            };
            [self.navigationController pushViewController:addressVC animated:YES];
        } else {
            //            ZFOrderCheckInfoDetailModel *checkModel = (ZFOrderCheckInfoDetailModel *)obj;
            //            if (!ZFToString(checkModel.address_info.address_id).length) {
            //                //如果地址没有的话，进入编辑地址页
            //                ZFAddressEditViewController *addressVC = [[ZFAddressEditViewController alloc] init];
            //                addressVC.sourceCart = YES;
            //                addressVC.model = obj;
            //                addressVC.addressEditSuccessCompletionHandler = ^(BOOL isEdit) {
            //                    @strongify(self);
            //                    [self requestCartFastPayNetworktoken:token payerId:payid];
            //                };
            //                [self.navigationController pushViewController:addressVC animated:YES];
            //                return;
            //            }
            ZFOrderInfoViewController *orderInfo = [[ZFOrderInfoViewController alloc] init];
            orderInfo.checkOutModel = obj;
            orderInfo.payCode = PayCodeTypeOld;
            orderInfo.isFastPay = YES;
            [self.navigationController pushViewController:orderInfo animated:YES];
            ///GrowingIO 统计
            [ZFGrowingIOAnalytics ZFGrowingIOCartCheckOut:obj];
        }
    } failure:nil];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cartListResultModel.goodsBlockList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section < self.cartListResultModel.goodsBlockList.count && [self.cartListResultModel.goodsBlockList[section].goodsModuleType integerValue] == ZFCartListBlocksTypeUnavailable) {
        if (self.cartListResultModel.goodsBlockList[section].cartList.count > 2) {
            return self.isUnavailableViewAll ? self.cartListResultModel.goodsBlockList[section].cartList.count : 2;
        }
    }
    return self.cartListResultModel.goodsBlockList[section].cartList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    /*
     * 如果是普通商品分栏，如果是活动满减分栏，如果是赠品商品分栏, ZFCartDiscountGoodsCell
     * 如果是过期商品分栏，ZFCartUnavailableGoodsCell;
     */
    ZFCartGoodsListModel *blockModel = self.cartListResultModel.goodsBlockList[indexPath.section];
    
    switch ([blockModel.goodsModuleType integerValue])
    {
        case ZFCartListBlocksTypeDiscount:
        case ZFCartListBlocksTypeNormal:
        case ZFCartListBlocksTypeFreeGift:
        {
            ZFCartDiscountGoodsCell *goodsCell = [tableView dequeueReusableCellWithIdentifier:kZFCartDiscountGoodsCellIdentifier];
            goodsCell.model = blockModel.cartList[indexPath.row];
            goodsCell.showEditFlag = ([blockModel.goodsModuleType integerValue] != ZFCartListBlocksTypeFreeGift);
            @weakify(self);
            goodsCell.selectedSizeBlock = ^(ZFCartGoodsModel *model) {
                @strongify(self);
                self.selecteEditGoodsId = model.goods_id;
                self.selecteEditGoodsNumber = model.buy_number;
                [self selectedGoodsSize:model.goods_id];
            };
            goodsCell.changeNumberBlock = ^(ZFCartGoodsModel *model, BOOL shouldDelete) {
                @strongify(self);
                if (shouldDelete) {
                    [self deleteGoodsFromEditCell:indexPath isMoveWishlistFlag:NO];
                } else {
                    [self cartGoodsNumberEditWithGoodsId:model.goods_id andGoodsNumber:model.buy_number];
                }
            };
            return goodsCell;
        }
            break;
            
        case ZFCartListBlocksTypeUnavailable:
        {
            ZFCartUnavailableGoodsCell *unavailableCell = [tableView dequeueReusableCellWithIdentifier:kZFCartUnavailableGoodsCellIdentifier];
            
            ZFCartGoodsModel *goodsModel = blockModel.cartList[indexPath.row];
            unavailableCell.model = goodsModel;
            @weakify(self)
            unavailableCell.tapSimilarGoodsHandle = ^{
                @strongify(self)
                ZFUnlineSimilarViewController *unlineSimilarVC = [[ZFUnlineSimilarViewController alloc] initWithImageURL:goodsModel.wp_image sku:goodsModel.goods_sn];
                unlineSimilarVC.sourceType = ZFAppsflyerInSourceTypeSearchImageitems;
                [self.navigationController pushViewController:unlineSimilarVC animated:YES];
            };
            unavailableCell.deleteGoodsBlock = ^(ZFCartGoodsModel *model){
                @strongify(self)
                [self deleteGoodsFromEditCell:indexPath isMoveWishlistFlag:NO];
            };
            return unavailableCell;
        }
            break;
    }
    return [tableView dequeueReusableCellWithIdentifier:KZFCartDefaultEmptyCellIdentifier];//异常处理
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section > self.cartListResultModel.goodsBlockList.count - 1) ? 98 + 200 * 1 : 136;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    [view zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    /*
     * 如果是普通商品分栏，设置ZFCartDiscountHeaderView
     * 如果是活动满减分栏，设置ZFCartDiscountHeaderView
     * 如果是过期商品分栏，设置ZFCartUnavailableHeaderView;
     * 如果是赠品列表分栏，设置ZFCartFreeGiftHearderView
     * 优惠券栏 : Code + 各种价格 ZFCarCouponDetailsCodeHeaderView
     */
    if ((section > self.cartListResultModel.goodsBlockList.count - 1) || self.cartListResultModel.goodsBlockList.count == 0) {
        return nil;
    }
    
    ZFCartGoodsListModel *blockModel = self.cartListResultModel.goodsBlockList[section];
    switch ([blockModel.goodsModuleType integerValue]) {
            
        case ZFCartListBlocksTypeNormal: {
            ZFCartNormalHeaderView *normalHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFCartNormalHeaderViewIdentifier];
            normalHeaderView.model = blockModel;
            @weakify(self);
            normalHeaderView.cartDiscountTopicJumpCompletionHandler = ^{
                @strongify(self);
                [self pushToWebViewWithUrl:blockModel.url title:nil];
            };
            normalHeaderView.refreshHandler = ^{
                [tableView reloadData];
            };
            return normalHeaderView;
        }
            break;
            
        case ZFCartListBlocksTypeDiscount: {
            ZFCartDiscountHeaderView *discountHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFCartDiscountHeaderViewIdentifier];
            discountHeaderView.model = blockModel;
            @weakify(self);
            discountHeaderView.cartDiscountTopicJumpCompletionHandler = ^{
                @strongify(self);
                [self pushToWebViewWithUrl:blockModel.url title:nil];
            };
            discountHeaderView.fullReductionCompletionHandler = ^(NSString *reduc_id, NSString *activity_type, NSString *activity_title) {
                @strongify(self);
                [self pushToFullReductionVC:reduc_id
                              activity_type:activity_type
                             activity_title:activity_title];
            };
            discountHeaderView.refreshHandler = ^{
                [tableView reloadData];
            };
            return discountHeaderView;
        }
            break;
            
        case ZFCartListBlocksTypeUnavailable: {
            ZFCartUnavailableHeaderView *unavailableHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFCartUnavailableHeaderViewIdentifier];
            @weakify(self);
            unavailableHeaderView.cartUnavailableGoodsClearAllCompletionHandler = ^{
                @strongify(self);
                NSString *title = ZFLocalizedString(@"CartUnavailableClearAllTips", nil);
                NSArray *btnArr = @[ZFLocalizedString(@"CartRemoveProductYes", nil)];
                NSString *cancelTitle = ZFLocalizedString(@"CartRemoveProductNo", nil);
                ShowAlertView(title, nil, btnArr, ^(NSInteger buttonIndex, id buttonTitle) {
                    [self cartClearAllUnavailableGoodsOption];
                }, cancelTitle, nil);
            };
            return unavailableHeaderView;
        }
            break;
        case ZFCartListBlocksTypeFreeGift: {
            ZFCartFreeGiftHearderView *freeGiftHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFCartFreeGiftHearderViewIdentifier];
            freeGiftHeaderView.model = blockModel;
            @weakify(self);
            freeGiftHeaderView.cartFreeGiftActionCompltionHandler = ^{
                @strongify(self);
                ZFFreeGiftsViewController *freeGiftVC = [[ZFFreeGiftsViewController alloc] init];
                [self.navigationController pushViewController:freeGiftVC animated:YES];
                
                [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOFistEvar : GIOSourceCartRecommend,
                                                           GIOSndNameEvar : GIOSourceCartFreeGifts
                }];
            };
            return freeGiftHeaderView;
        }
            break;
        case ZFCartListBlocksTypeCouponDetailsCode: { // HeaderView优惠券显示: 明细信息
            ZFCarCouponDetailsCodeHeaderView *detailsCouponView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ZFCarCouponDetailsCodeHeaderViewIdentifier];
            @weakify(self);
            detailsCouponView.cartListResultModel = self.cartListResultModel;
            detailsCouponView.addCodesHandler = ^{
                @strongify(self);
                [self pushToMyCouponViewController];
            };
            return detailsCouponView;
        }
            break;
        case ZFCartListBlocksTypeRecommendGoods: {
            ZFCarRecommendGoodsHeaderView *recommendView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFCarRecommendGoodsHeaderViewIdentifier];
            recommendView.isEmptyCart = self.isEmptyCart;
            @weakify(self)
            if (self.cartListResultModel.goodsBlockList.count == 1) {
                recommendView.contentView.backgroundColor = ZFC0xF2F2F2();
            } else {
                recommendView.contentView.backgroundColor = ZFCOLOR_WHITE;
            }
            [recommendView setDataArray:self.recommendGoodsArray afParams:self.recomendAFParams];
            recommendView.selectGoodsBlock = ^(NSString *goodsId, UIImageView *imageView){
                @strongify(self)
                ZFCartGoodsModel *model = [[ZFCartGoodsModel alloc] init];
                model.goods_id = goodsId;
                [self pushToGoodsDetailWithModel:model isAnalytics:YES];
            };
            return recommendView;
        }
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section > self.cartListResultModel.goodsBlockList.count - 1) {
        return CGFLOAT_MIN;
    }
    NSInteger type = [self.cartListResultModel.goodsBlockList[section].goodsModuleType integerValue];
    if (type == ZFCartListBlocksTypeCouponDetailsCode) {
        return self.couponHeaderHeight;//优惠券栏
        
    } else if (type == ZFCartListBlocksTypeRecommendGoods) {
        if (self.recommendGoodsArray.count >0) {
            return kRecommendViewHeight;//推荐商品Header栏
        } else {
            return CGFLOAT_MIN;
        }
    }
    return 44 - 8;
}

//- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
//    [view zfAddCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight) cornerRadii:CGSizeMake(8, 8)];
//}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section > self.cartListResultModel.goodsBlockList.count - 1) {
        return [[UIView alloc] init];
    }
    NSInteger type = [self.cartListResultModel.goodsBlockList[section].goodsModuleType integerValue];
    
    if (type == ZFCartListBlocksTypeUnavailable
        && self.cartListResultModel.goodsBlockList[section].cartList.count > 2) {
        
        ZFCartUnavailableViewAllFooterView *viewAllView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFCartUnavailableViewAllViewIdentifier];
        viewAllView.isShowMore = self.isUnavailableViewAll;
        @weakify(self);
        viewAllView.cartUnavailableViewAllSelectCompletionHandler = ^(BOOL isShowMore) {
            @strongify(self);
            self.isUnavailableViewAll = isShowMore;
            [self.tableView reloadData];
        };
        return viewAllView;
    }
    // 通用的footer样式
    ZFCartNormalFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFCartSectionFooterViewIdentifier];
    if (type == ZFCartListBlocksTypeRecommendGoods) {
        NSArray *cartGoodsArray = self.cartListResultModel.goodsBlockList;
        footerView.showCornersView = !(cartGoodsArray.count==1 && self.hasAddRecommendHeader);
    } else {
        footerView.showCornersView = YES;
    }
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section > self.cartListResultModel.goodsBlockList.count - 1) {
        return CGFLOAT_MIN;
    }
    NSInteger type = [self.cartListResultModel.goodsBlockList[section].goodsModuleType integerValue];
    if (type == ZFCartListBlocksTypeUnavailable) {
        return self.cartListResultModel.goodsBlockList[section].cartList.count > 2 ? (44 + kCardMargin) : kCardMargin * 2;
    }
    return kCardMargin * 2; //这里除了正常的12还要加上每组底部有一段白色间距12
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section < self.cartListResultModel.goodsBlockList.count;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.cartListResultModel.goodsBlockList || indexPath.section > self.cartListResultModel.goodsBlockList.count - 1) {
        return ;
    }
    ZFCartGoodsListModel *blockModel = self.cartListResultModel.goodsBlockList[indexPath.section];
    if ([blockModel.goodsModuleType integerValue] == ZFCartListBlocksTypeUnavailable) {
        return ;
    }
    ZFCartGoodsModel *goodsModel = blockModel.cartList[indexPath.row];
    [self pushToGoodsDetailWithModel:blockModel.cartList[indexPath.row] isAnalytics:NO];
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Click_Bag_Goods_%@", goodsModel.goods_sn] itemName:goodsModel.goods_title ContentType:@"Goods" itemCategory:@"Bag_List"];
    
    if ([blockModel.goodsModuleType integerValue] == ZFCartListBlocksTypeFreeGift) {
        [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOGoodsTypeEvar : GIOGoodsTypeRecommend,
                                                   GIOGoodsNameEvar : @"cart_freeproduct"
        }];
    } else {
//        [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOGoodsTypeEvar : GIOGoodsTypeOther,
//                                                   GIOGoodsNameEvar : @"cart_product"
//        }];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    _editCellBgWhiteView.hidden = YES;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    /// 防止滑动删除Cell漏出的背景色
    self.editCellBgWhiteView.hidden = NO;
    self.editCellBgWhiteView.frame = cell.frame;
    [tableView insertSubview:self.editCellBgWhiteView atIndex:0];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    self.editCellBgWhiteView.hidden = YES;
}

// 编辑Cell
- (NSArray*)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *actionArr = [NSMutableArray array];
    BOOL showWishlishAction = NO;
    
    if (self.cartListResultModel.goodsBlockList.count > indexPath.section) {
        ZFCartGoodsListModel *blockModel = self.cartListResultModel.goodsBlockList[indexPath.section];
        
        if (blockModel.cartList.count > indexPath.row) {
            ZFCartGoodsModel *goodModel = blockModel.cartList[indexPath.row];
            if (goodModel) { // 非赠品才能加入收藏
                if ([blockModel.goodsModuleType integerValue] != ZFCartListBlocksTypeFreeGift &&
                    [blockModel.goodsModuleType integerValue] != ZFCartListBlocksTypeUnavailable) {
                    showWishlishAction = YES;
                }
            }
        }
    }
    //从购物车移除 并添加到收藏夹
    if (showWishlishAction) {
        NSString *wishlishTitle = ZFLocalizedString(@"Account_Cell_Wishlist", nil);
        UITableViewRowAction *wishlishAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:wishlishTitle handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            [self deleteGoodsFromEditCell:indexPath isMoveWishlistFlag:YES];
        }];
        wishlishAction.backgroundColor = ZFCOLOR(248, 168, 2, 1);
        [actionArr addObject:wishlishAction];
    }
    
    //从购物车删除
    NSString *deleteTitle = ZFLocalizedString(@"Address_List_Cell_Delete", nil);
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:deleteTitle handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self deleteGoodsFromEditCell:indexPath isMoveWishlistFlag:NO];
    }];
    deleteAction.backgroundColor = ZFCOLOR(255, 98, 98, 1);
    [actionArr insertObject:deleteAction atIndex:0];
    return actionArr;
}

#pragma mark -===========统计代码===========

// 添加收藏时统计
- (void)addAnalysicsWithCartModel:(ZFCartGoodsModel *)model {
    // Appsflyer
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId]   = model.goods_sn;
    valuesDic[AFEventParamContentType] = model.cat_name;
    valuesDic[@"af_inner_mediasource"] = @"carts page";
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_add_to_wishlist" withValues:valuesDic];
    
    // FireBase
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Bag_Goods_%@", model.goods_sn] itemName:model.goods_name ContentType:@"Goods_Collection" itemCategory:@"Button"];
    GoodsDetailModel *goodsDetailModel = [[GoodsDetailModel alloc] init];
    goodsDetailModel.goods_id = model.goods_id;
    goodsDetailModel.goods_name = model.goods_title;
    goodsDetailModel.long_cat_name = model.cat_name;
    goodsDetailModel.goods_sn = model.goods_sn;
    [ZFFireBaseAnalytics addCollectionWithGoodsModel:goodsDetailModel];
}

- (void)alertStudentMarkTips {
    // 不能同时弹框2个框
    if (self.isHasShowMoveWilshTip) return;
    
    NSInteger studentLevel = [AccountManager sharedManager].account.student_level;
    if (studentLevel <= 0) {
        return;
    }
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"Student%@", [AccountManager sharedManager].account.email];
    BOOL isAlertStudent = [ud boolForKey:key];
    if (!isAlertStudent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title = ZFLocalizedString(@"Guest_Sales_Tips_title", nil) ;
            NSString *content = ZFLocalizedString(@"Guest_Sales_Tips_Content", nil);
            NSString *OK = ZFLocalizedString(@"OK", nil);
            ShowAlertSingleBtnView(title, content, OK);
        });
        [ud setBool:YES forKey:key];
        [ud synchronize];
    }
}

- (void)cartViewPageAnalytics {
    NSMutableArray *contentIdArr = [[NSMutableArray alloc] init];
    [self.cartListResultModel.goodsBlockList enumerateObjectsUsingBlock:^(ZFCartGoodsListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.goodsModuleType integerValue] != ZFCartListBlocksTypeUnavailable) { //失效的商品排除
            [obj.cartList enumerateObjectsUsingBlock:^(ZFCartGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [contentIdArr addObject:ZFToString(obj.goods_sn)];
            }];
        }
    }];
    //新增统计代码
    NSString *content = @"";
    if ([contentIdArr count]) {
        content = [contentIdArr componentsJoinedByString:@","];
    }
    NSString *contentType = @"view cartpage";
    if (!ZFToString(content).length) {
        contentType = @"view cartpage_null";
        self.isEmptyCart = YES;
    } else {
        self.isEmptyCart = NO;
    }
    NSDictionary *params = @{@"af_content_type": contentType,
                             @"af_content_id": content
                             };
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_cartpage" withValues:params];
}

#pragma mark -===========PUSH 事件===========

/// 未登录空数据时点击空白页跳转到 Women, Men分类
- (void)jumpToCategoryListVC:(ZFCarHeaderInfoViewActionType)actionType {
    NSString *url = nil;
    NSString *name = @"";
    if(actionType == ZFCarHeaderAction_ShopWomen) {
        url = @"1";
        name = @"Women";
    } else if(actionType == ZFCarHeaderAction_ShopMen) {
        url = @"118";
        name = @"Men";
    }
    if (!url) return;
    NSString *deeplink = [NSString stringWithFormat:@"ZZZZZ://action?actiontype=2&url=%@&name=%@&source=deeplink", url, name];
    NSMutableDictionary *paramDict = [BannerManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:deeplink]];
    [BannerManager jumpDeeplinkTarget:self deeplinkParam:paramDict];
}

- (void)pushToMyCouponViewController {
    @weakify(self)
    ZFMyCouponViewController *couponVC = [[ZFMyCouponViewController alloc] init];
    couponVC.availableArray = self.cartListResultModel.couponListModel.available;
    couponVC.disabledArray  = self.cartListResultModel.couponListModel.disabled;
    couponVC.couponAmount   = self.cartListResultModel.cart_coupon_amount;
    
    // 记住在购物车是否已手动选择过的优惠券
    if ([AccountManager sharedManager].hasSelectedAppCoupon) {
        couponVC.couponCode = ZFToString([AccountManager sharedManager].selectedAppCouponCode);
    } else {
        couponVC.couponCode = self.cartListResultModel.coupon_code;
    }
    couponVC.applyCouponHandle = ^(NSString *couponCode, BOOL shouldPop) {
        @strongify(self);
        [AccountManager sharedManager].hasSelectedAppCoupon = YES;
        [AccountManager sharedManager].selectedAppCouponCode = couponCode;
        if (shouldPop) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    [self.navigationController pushViewController:couponVC animated:YES];
}

/**
 * 免邮差价，如果大于0，可以去凑单商品列表页
 */
- (void)pushToPiecingOrderVC {
    ZFCarPiecingOrderVC *vc = [[ZFCarPiecingOrderVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)pushToWebViewWithUrl:(NSString *)url title:(NSString *)title {
    if ([url hasPrefix:@"ZZZZZ:"]) {
        ZFBannerModel *model = [[ZFBannerModel alloc] init];
        model.deeplink_uri = url;
        [BannerManager doBannerActionTarget:self withBannerModel:model];
    }else{
        ZFWebViewViewController *webVC = [[ZFWebViewViewController alloc] init];
        webVC.link_url = url;
        if (!ZFIsEmptyString(title)) {
            webVC.title = title;
        }
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

// 跳转到满减页面
- (void)pushToFullReductionVC:(NSString *)reduc_id
                activity_type:(NSString *)activity_type
               activity_title:(NSString *)activity_title {
    ZFFullReductionViewController *fullReductionVC = [[ZFFullReductionViewController alloc] init];
    fullReductionVC.title = ZFToString(activity_title);
    fullReductionVC.reduc_id = reduc_id;
    fullReductionVC.activity_type = activity_type;
    [self.navigationController pushViewController:fullReductionVC animated:YES];
}

///analytics 是否需要把购物车推荐商品信息带到商品详情页
- (void)pushToGoodsDetailWithModel:(ZFCartGoodsModel *)model isAnalytics:(BOOL)analytics {
    [self.view endEditing:YES];
    ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
    
    //v455 occ 赠品且为满足赠品条件商品跳到商品详情页，否则跳到普通商品详情
    if (model.is_full && !ZFIsEmptyString(model.manzeng_id) && model.is_valid) {
        detailVC.freeGiftId = model.manzeng_id;
    }
    detailVC.goodsId = model.goods_id;
    if (analytics) {  // 推荐商品点击
        detailVC.afParams = self.recomendAFParams;
        detailVC.sourceType = self.recomendAFParams.sourceType;
    } else {
        detailVC.sourceType = ZFAppsflyerInSourceTypeCartProduct;
        // appflyer统计
        NSString *spuSN = @"";
        if (model.goods_sn.length > 7) {  // sn的前7位为同款id
            spuSN = [model.goods_sn substringWithRange:NSMakeRange(0, 7)];
        }else{
            spuSN = model.goods_sn;
        }
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(model.goods_sn),
                                          @"af_spu_id" : ZFToString(spuSN),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"cartpage",    // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
    }
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)wishBtnClick:(UIButton *)sender {
    //防止从购物车页面循环跳转购物车
    [self pushOrPopToViewController:NSStringFromClass(ZFCollectionViewController.class)
                         withObject:nil
                          aSelector:nil
                           animated:YES];
}

/// 处理HeaderView页面跳转
- (void)doHeaderInfoViewAction:(ZFCarHeaderInfoViewActionType)actionType
                    orderModel:(MyOrdersModel *)orderModel
{
    if(actionType == ZFCarHeaderAction_waitingForPayment){
        [ZFCommonRequestManager gotoOrderDetail:orderModel orderReloadBlock:^{
            [self requestShowUnpaidOrderInfoView];
        }];
        
    } else if (actionType == ZFCarHeaderAction_BuyAgain) {
        [self requestReturnToBag:orderModel.order_id];
        
    } else if(actionType == ZFCarHeaderAction_PayButton){
        [ZFCommonRequestManager gotoPayOrderInfo:orderModel];
        
    } else if(actionType == ZFCarHeaderAction_EmptyData){
        if (orderModel) {
            [self requestCartListData:nil];
        } else {
            [(ZFTabBarController *)(self.tabBarController) setZFTabBarIndex:TabBarIndexHome];
        }
    } else if(actionType == ZFCarHeaderAction_ShopWomen) {
        [self jumpToCategoryListVC:actionType];
        
    } else if(actionType == ZFCarHeaderAction_ShopMen) {
        [self jumpToCategoryListVC:actionType];
        
    } else if(actionType == ZFCarHeaderAction_ForNewUser) {
        [self judgePresentLoginVCChooseType:YWLoginEnterTypeRegister comeFromType:YWLoginViewControllerEnterTypeCartPage Completion:nil];
    }
}

#pragma mark - ======ZFInitViewProtocol====

- (void)zfInitView {
    self.view.backgroundColor = ZFC0xF2F2F2();
    [self.view addSubview:self.topTipView];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.tmpWhiteView];
    [self.view addSubview:self.bottomPriceView];
}

- (void)zfAutoLayoutView {
    [self.topTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view).offset(0);
        make.leading.mas_equalTo(self.view).offset(0);
        make.trailing.mas_equalTo(self.view).offset(0);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topTipView.mas_bottom).offset(0);
        make.leading.mas_equalTo(self.view).offset(kCardMargin);
        make.trailing.mas_equalTo(self.view).offset(-kCardMargin);
        make.bottom.mas_equalTo(self.view).offset(kCardMargin);
    }];
    
    [self.bottomPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tableView.mas_bottom).offset(kCardMargin);
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-kiphoneXHomeBarHeight);
    }];
    
    [self.tmpWhiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomPriceView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view);
    }];
}

#pragma mark - ===========getter===========

- (ZFCartViewModel *)cartViewModel {
    if (!_cartViewModel) {
        _cartViewModel = [[ZFCartViewModel alloc] init];
        _cartViewModel.controller = self;
    }
    return _cartViewModel;
}

- (NSMutableArray *)selectGoodsArray {
    if (!_selectGoodsArray) {
        _selectGoodsArray = [NSMutableArray array];
    }
    return _selectGoodsArray;
}

- (ZFCartListResultModel *)cartListResultModel {
    if (!_cartListResultModel) {
        _cartListResultModel = [[ZFCartListResultModel alloc] init];
    }
    return _cartListResultModel;
}

- (ZFShoppingCarTopTipView *)topTipView {
    if (!_topTipView) {
        _topTipView = [[ZFShoppingCarTopTipView alloc] initWithFrame:CGRectZero];
        _topTipView.hidden = YES;
        @weakify(self)
        _topTipView.tapTopTipViewBlock = ^{
            @strongify(self)
            [self pushToPiecingOrderVC];
        };
    }
    return _topTipView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = ZFC0xF2F2F2();
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.contentInset = UIEdgeInsetsMake(kCardMargin, 0, kCardMargin, 0);
        _tableView.layer.cornerRadius = 8;
        _tableView.layer.masksToBounds = YES;
        
        // 注册Cell
        [_tableView registerClass:[ZFCartDiscountGoodsCell class] forCellReuseIdentifier:kZFCartDiscountGoodsCellIdentifier];
        [_tableView registerClass:[ZFCartFreeGiftTableViewCell class] forCellReuseIdentifier:kZFCartFreeGiftTableViewCellIdentifier];
        [_tableView registerClass:[ZFCartUnavailableGoodsCell class] forCellReuseIdentifier:kZFCartUnavailableGoodsCellIdentifier];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:KZFCartDefaultEmptyCellIdentifier]; //异常兼容
        
        // 注册HeaderFooter
        [_tableView registerClass:[ZFCartDiscountHeaderView class] forHeaderFooterViewReuseIdentifier:kZFCartDiscountHeaderViewIdentifier];
        [_tableView registerClass:[ZFCartNormalHeaderView class] forHeaderFooterViewReuseIdentifier:kZFCartNormalHeaderViewIdentifier];
        [_tableView registerClass:[ZFCartUnavailableHeaderView class] forHeaderFooterViewReuseIdentifier:kZFCartUnavailableHeaderViewIdentifier];
        [_tableView registerClass:[ZFCartUnavailableViewAllFooterView class] forHeaderFooterViewReuseIdentifier:kZFCartUnavailableViewAllViewIdentifier];
        [_tableView registerClass:[ZFCartNormalFooterView class] forHeaderFooterViewReuseIdentifier:kZFCartSectionFooterViewIdentifier];
        [_tableView registerClass:[ZFCartFreeGiftHearderView class] forHeaderFooterViewReuseIdentifier:kZFCartFreeGiftHearderViewIdentifier];
        
        [_tableView registerClass:[ZFCarCouponDetailsCodeHeaderView class] forHeaderFooterViewReuseIdentifier:ZFCarCouponDetailsCodeHeaderViewIdentifier];
        
        [_tableView registerClass:[ZFCarRecommendGoodsHeaderView class] forHeaderFooterViewReuseIdentifier:kZFCarRecommendGoodsHeaderViewIdentifier];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        // 处理空数据
        _tableView.emptyDataImage = [UIImage imageNamed:@"blankPage_noCart"];
        _tableView.emptyDataTitle = ZFLocalizedString(@"CartViewModel_NoData_TitleLabel", nil);
        _tableView.emptyDataBtnTitle = ZFLocalizedString(@"CartViewModel_NoData_TitleButton", nil);
        
        @weakify(self);
        _tableView.blankPageViewActionBlcok = ^(ZFBlankPageViewStatus status){
            @strongify(self);
            if (status == RequestEmptyDataStatus) {
                ZFTabBarController *tabbar = (ZFTabBarController *)(self.tabBarController);
                [tabbar setZFTabBarIndex:TabBarIndexHome];
            } else {
                [self.tableView.mj_header beginRefreshing];
            }
        };
        // 下拉刷新
        [_tableView addHeaderRefreshBlock:^{
            @strongify(self);
            // 请求购物车列表数据
            [self requestCartListData:nil];
            
        } footerRefreshBlock:nil startRefreshing:NO];
    }
    return _tableView;
}

- (ZFCarRecommendView *)tableFooterView {
    if (!_tableFooterView) {
        _tableFooterView = [[ZFCarRecommendView alloc] init];
        _tableFooterView.frame = CGRectMake(0, 0, KScreenWidth, kRecommendViewHeight);
        @weakify(self)
        [_tableFooterView setCarRecommendSelectGoodsBlock:^(NSString * _Nonnull goodsId, UIImageView * _Nonnull imageView) {
            @strongify(self)
            ZFCartGoodsModel *model = [[ZFCartGoodsModel alloc] init];
            model.goods_id = goodsId;
            [self pushToGoodsDetailWithModel:model isAnalytics:YES];
        }];
    }
    return _tableFooterView;
}

- (ZFCarHeaderInfoView *)showHeaderView:(ZFCarHeaderInfoShowUIType)showUIType
                             orderModel:(MyOrdersModel *)orderModel {
    
    CGFloat maginSpace = orderModel ? -35 : +29;
    CGRect rect = CGRectMake(0, 0, KScreenWidth, 270 + maginSpace);
    if (showUIType == ZFCarHeaderUI_ForNewUser) { //新版头部时高度充满页面高度
        rect.size.height = self.view.bounds.size.height/2;
    }
    @weakify(self)
    return [[ZFCarHeaderInfoView alloc] initWithFrame:rect
                                           showUIType:showUIType
                                           orderModel:orderModel
                                headerViewActionBlock:^(ZFCarHeaderInfoViewActionType actionType) {
                                    @strongify(self)
                                    [self doHeaderInfoViewAction:actionType
                                                      orderModel:orderModel];
                                }];
}

- (ZFCartBottomPriceView *)bottomPriceView {
    if (!_bottomPriceView) {
        _bottomPriceView = [[ZFCartBottomPriceView alloc] initWithFrame:CGRectZero];
        _bottomPriceView.hidden = YES;
        @weakify(self);
        _bottomPriceView.cartOptionViewActionBlock = ^(ZFCartBottomPriceViewActionType actionType) {
            @strongify(self);
            if (actionType == PayPalBtnActionType) {
                [self fastPaymentButtonAction:nil];
                
            } else if (actionType == CheckoutOutBtnActionType) {
                [self checkOutButtonAction:nil];
            }
        };
    }
    return _bottomPriceView;
}

/// 盖住底部漏出的背景色
- (UIView *)tmpWhiteView {
    if (!_tmpWhiteView) {
        _tmpWhiteView = [[UIView alloc] initWithFrame:CGRectZero];
        _tmpWhiteView.backgroundColor = ZFC0xF2F2F2();//ZFCOLOR_WHITE;
    }
    return _tmpWhiteView;
}

/// 盖住滑动删除Cell漏出的背景色
- (UIView *)editCellBgWhiteView {
    if (!_editCellBgWhiteView) {
        _editCellBgWhiteView = [[UIView alloc] initWithFrame:CGRectZero];
        _editCellBgWhiteView.frame = CGRectMake(0, 0, KScreenWidth, 132);
        _editCellBgWhiteView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _editCellBgWhiteView;
}

- (ZFGoodsDetailSelectTypeView *)selectSizeView {
    if (!_selectSizeView) {
        _selectSizeView = [[ZFGoodsDetailSelectTypeView alloc] initSelectSizeView:NO bottomBtnTitle:ZFLocalizedString(@"OK", nil)];
        _selectSizeView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        [self.view.window addSubview:_selectSizeView];
        
        @weakify(self);
        _selectSizeView.openOrCloseBlock = ^(BOOL isOpen) {
            @strongify(self);
            self.hasOpenSizeView = isOpen;
        };
        _selectSizeView.goodsDetailSelectTypeBlock = ^(NSString *goodsId) {
            @strongify(self);
            [self selectedGoodsSize:goodsId];
        };
        _selectSizeView.addCartBlock = ^(NSString *goodsId, NSInteger count) {
            @strongify(self);
            [self.selectSizeView hideSelectTypeView];
            [self selectedEditGoodsWithGoodsId:self.selecteEditGoodsId newGoodsId:goodsId];
        };
        _selectSizeView.goodsDetailSelectSizeGuideBlock = ^(NSString *url){
            @strongify(self);
            [self.selectSizeView hideSelectTypeView];
            [self pushToWebViewWithUrl:url title:ZFLocalizedString(@"Detail_Product_SizeGuides",nil)];
        };
    }
    return _selectSizeView;
}

@end
