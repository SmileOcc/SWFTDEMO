//
//  ZFOrderSuccessPageVC.m
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderSuccessPageVC.h"
#import "ZFWebViewViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFAnalytics.h"
#import "ZFPaySuccessViewModel.h"
#import "ZFPaySuccessModel.h"
#import "ZFBannerModel.h"
#import "ZFPaySuccessTypeModel.h"
#import "ZFPaySuccessPointCell.h"
#import "ZFPaySuccessDetailCell.h"
#import "ZFPaySuccessBannerCell.h"
#import "BannerManager.h"
#import "ZFPushAllowView.h"
#import "ZFNewPushAllowView.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFApiDefiner.h"
#import "Constants.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFCommonRequestManager.h"
#import "ZFAppsflyerAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "ZFPaymentViewController.h"
#import "ZFPaySuccessFiveThbannerCell.h"
#import "ZFMergeRequest.h"
#import "ZFPubilcKeyDefiner.h"
#import "YWLocalHostManager.h"
#import "ZFCarRecommendView.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFProgressHUD.h"
#import "ZFBranchAnalytics.h"
#import "ZFFireBaseAnalytics.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>

@interface ZFOrderSuccessPageVC () <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView                       *tableView;
@property (nonatomic, strong) ZFPaySuccessViewModel             *viewModel;
@property (nonatomic, strong) ZFPaySuccessModel                 *model;
@property (nonatomic, strong) NSMutableArray                    *sections;
@property (nonatomic, strong) NSMutableArray<ZFBannerModel *>   *bannerModelArr;
@property (nonatomic, strong) ZFNewPushAllowView                *pushAllowView;
@property (nonatomic, strong) ZFBannerModel                     *fiveThPointModel;
@property (nonatomic, strong) ZFBannerModel                     *fiveThCouponModel;
@property (nonatomic, strong) ZFCarRecommendView                *tableFooterView;
@property (nonatomic, strong) AFparams                          *recomendAFParams;
@end

@implementation ZFOrderSuccessPageVC

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self zfInitView];
    [self zfAutoLayoutView];
    
    //处理支付返回失败的场景
    [self dealwithOtherWase];
    
    [self mergeRequest];
    
    if (self.isShowNotictionView) {
        [ZFPushManager canShowAlertView:^(BOOL canShow) {
            if (canShow) {
                [self.pushAllowView limitShow:PushAllowViewType_OrderSuccess operateBlock:^(BOOL flag) {}];
            }
        }];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [self eventLog];
    });
    self.fd_interactivePopDisabled = YES;
    
    [self analyticsOrderSuccess];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.backBarButtonItem = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)pushToWebVCWithUrl:(NSString *)link_url {
    ZFWebViewViewController *paymentVC = [[ZFWebViewViewController alloc] init];
    paymentVC.link_url = link_url;
    [self.navigationController pushViewController:paymentVC animated:YES];
}

- (void)analyticsOrderSuccess
{
    if (!self.baseOrderModel) {
        return;
    }
    ZFBaseOrderModel *orderModel = self.baseOrderModel;
    
    __block NSString *goodsStr = @"";
    __block NSString *goodsPriceStr = @"";
    __block NSString *goodsNumStr = @"";
    
    NSMutableArray <BranchUniversalObject *>*goodsArray = [NSMutableArray array];
    NSMutableArray *bigDataParamsList = [NSMutableArray array];
    [self.baseOrderModel.baseGoodsList enumerateObjectsUsingBlock:^(ZFBaseOrderGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *goodsPrice = obj.hacker_point.goods_real_pay_amount;
        
        goodsStr = [NSString stringWithFormat:@"%@%@,", goodsStr, obj.goods_sn];
        goodsPriceStr = [NSString stringWithFormat:@"%@%@,", goodsPriceStr, goodsPrice];
        goodsNumStr = [NSString stringWithFormat:@"%@%@,", goodsNumStr, obj.goods_number];
        
        // Create a BranchUniversalObject with your content data:
        BranchUniversalObject *branchUniversalObject = [BranchUniversalObject new];
        branchUniversalObject.contentMetadata.contentSchema    = BranchContentSchemaCommerceProduct;
        branchUniversalObject.contentMetadata.quantity         = obj.goods_number.doubleValue;
        if (!ZFIsEmptyString(goodsPrice)) {
            branchUniversalObject.contentMetadata.price            = [NSDecimalNumber decimalNumberWithString:ZFToString(goodsPrice)];
        }
        branchUniversalObject.contentMetadata.currency         = BNCCurrencyUSD;
        branchUniversalObject.contentMetadata.sku              = ZFToString(obj.goods_sn);
        branchUniversalObject.contentMetadata.productName      = ZFToString(obj.goods_title);
        branchUniversalObject.contentMetadata.productBrand     = ZFToString(obj.goods_brand);
        [goodsArray addObject:branchUniversalObject];
        
        NSDictionary *params = [obj gainAnalyticsParams];
        [bigDataParamsList addObject:params];
    }];
    goodsStr = [goodsStr substringToIndex:goodsStr.length-1];
    goodsPriceStr = [goodsPriceStr substringToIndex:goodsPriceStr.length-1];
    goodsNumStr = [goodsNumStr substringToIndex:goodsNumStr.length-1];
    
    //branch统计
    [[ZFBranchAnalytics sharedManager] branchAnalyticsOrderModel:orderModel goodsList:goodsArray];
    
    //付款订单统计量
    [ZFAnalytics appsFlyerTrackFinishGoodsIds:goodsStr
                                  goodsPrices:goodsPriceStr
                                    quantitys:goodsNumStr
                                      orderSn:orderModel.order_sn
                                 orderPayMent:orderModel.realPayment
                                 orderRealPay:orderModel.hacker_point.order_real_pay_amount
                                      payment:nil
                                     btsModel:nil
                                bigDataParams:bigDataParamsList];
    
    //Firebase
    [ZFFireBaseAnalytics finishedPurchaseWithOrderModel:orderModel];
    NSString *paySource;
    switch (self.fromType) {
        case ZFOrderPayResultSource_OrderInfo:
            paySource = @"OrderInfo";
            break;
        case ZFOrderPayResultSource_OrderDetail:
        paySource = @"OrderDetail";
        break;
        case ZFOrderPayResultSource_OrderList:
        paySource = @"OrderList";
        break;
            
        default:
            paySource = @"OrderDetail";
            break;
    }
    //growingIO统计
    [ZFGrowingIOAnalytics ZFGrowingIOPayOrderSuccessWithBaseOrderModel:orderModel paySource:paySource];
}

#pragma mark - Request

- (void)mergeRequest
{
    ZFMergeRequest *mergeRequestManager = [[ZFMergeRequest alloc] init];
    
    ZFRequestModel *paySuccessModel = [[ZFRequestModel alloc] init];
    paySuccessModel.url = API(Port_paySuccess);
    paySuccessModel.parmaters = @{@"order_sn" : self.baseOrderModel.order_sn};
    paySuccessModel.taget = self;
    [mergeRequestManager addRequest:paySuccessModel];
    
    
    ZFRequestModel *cmsRequestModel = [ZFCommonRequestManager gainCmsRequestModelWithTpye:ZFCMSAppAdvertsType_PaySuccess otherId:nil target:self];
    [mergeRequestManager addRequest:cmsRequestModel];
    
    
    ZFRequestModel *recommendModel = [[ZFRequestModel alloc] init];
    recommendModel.eventName = @"recommend_goods";
    recommendModel.taget = self;
    recommendModel.url = API(Port_bigData_homeRecommendGoods);//请求大数据推荐商品
    recommendModel.parmaters = @{@"page"            : @(1),
                                 @"appsFlyerUID"    : ZFToString([[AppsFlyerTracker sharedTracker] getAppsFlyerUID]),
                                 ZFApiBtsUniqueID : ZFToString([GGAppsflyerAnalytics getAppsflyerDeviceId]),
    };
    [mergeRequestManager addRequest:recommendModel];
    
    
    ShowLoadingToView(self.view);
    @weakify(self)
    [mergeRequestManager requestResult:^(NSDictionary<NSString *,NSDictionary *> *mergeSuccessResult, NSDictionary<NSString *,NSDictionary *> *mergeFailResult, NSError *error) {
        @strongify(self)
        HideLoadingFromView(self.view);
        
        NSString *orderKey = [NSString stringWithFormat:@"%p", paySuccessModel];
        
        NSArray *mergeFailList = [mergeFailResult allKeys];
        if (error && [mergeFailList containsObject:orderKey]) {
            ///失败接口里有订单接口
            [self.tableView reloadData];
            [self.tableView showRequestTip:@{}];
            return ;
        }
        
        ///订单成功接口返回数据
        NSDictionary *result = mergeSuccessResult[orderKey];
        [self handleOrderData:result];
        
        ///cms接口返回数据
        NSString *cmsKey = [NSString stringWithFormat:@"%p", cmsRequestModel];
        NSDictionary *cmsResult = mergeSuccessResult[cmsKey];
        [self handleCMSData:cmsResult];
        
        /// 推荐接口返回数据
        NSString *recommendKey = [NSString stringWithFormat:@"%p", recommendModel];
        NSDictionary *recommendResult = mergeSuccessResult[recommendKey];
        [self handleRecommendData:recommendResult];
        
        [self configureTypeDataSource];
        [self.tableView reloadData];
        [self.tableView showRequestTip:@{}];
    }];
    [mergeRequestManager startRequest];
}

/// 处理大数据推荐商品接口数据
- (void)handleRecommendData:(NSDictionary *)responseObject
{
    NSDictionary *resultDict = responseObject[ZFResultKey];
    if (!ZFJudgeNSDictionary(resultDict)) return;
    
    NSArray *goods_list = resultDict[@"goods_list"];
    if (!ZFJudgeNSArray(goods_list) || goods_list.count == 0) return;
    NSArray *recommendGoodsArray = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:goods_list];
    
    NSDictionary *paramsDict = resultDict[@"af_params"];
    if (ZFJudgeNSDictionary(paramsDict)) {
        self.recomendAFParams = [AFparams yy_modelWithJSON:paramsDict];
    } else {
        self.recomendAFParams = [[AFparams alloc] init];
    }
    self.recomendAFParams.sourceType = ZFAppsflyerInSourceTypePaySuccessRecommend;
    [self.tableFooterView setDataArray:recommendGoodsArray afParams:self.recomendAFParams];
    self.tableView.tableFooterView = self.tableFooterView;
}

/// 处理订单数据
- (void)handleOrderData:(NSDictionary *)result
{
    ZFPaySuccessModel *paysuccessModel = [ZFPaySuccessModel yy_modelWithJSON:result[ZFResultKey]];
    self.model = paysuccessModel;
    self.model.isCodPay = self.isCodPay;
    self.model.offlineLink = self.offlineLink;
    if (self.model.is_show_popup) {
        [self showAppStoreCommentWithContactUs:self.model.contact_us];
    }
}

/// 处理CMS数据
- (void)handleCMSData:(NSDictionary *)cmsResult
{
    NSArray *resultArray = cmsResult[ZFDataKey];
    if (!ZFJudgeNSArray(resultArray)) return;
    
    NSDictionary *resultDic = [resultArray firstObject];
    if(!ZFJudgeNSDictionary(resultDic)) return;
    
    NSMutableArray<ZFBannerModel *> *bannerModelArr = [NSMutableArray array];
    NSArray *list = [resultDic ds_arrayForKey:@"list"];
    if (!ZFJudgeNSArray(list) || list.count == 0) return;
    
    NSInteger index = 0;
    for (NSDictionary *listDic in list) {
        ZFBannerModel *bannerModel = [[ZFBannerModel alloc] init];
        bannerModel.image = [listDic ds_stringForKey:@"img"];
        bannerModel.name = [listDic ds_stringForKey:@"name"];
        bannerModel.banner_id = [listDic ds_stringForKey:@"advertsId"];
        bannerModel.banner_width = [listDic ds_stringForKey:@"width"];
        bannerModel.banner_height = [listDic ds_stringForKey:@"height"];
        bannerModel.colid = [listDic ds_stringForKey:@"colId"];
        bannerModel.componentId = [listDic ds_stringForKey:@"componentId"];
        bannerModel.menuid = [listDic ds_stringForKey:@"menuId"];
        
        NSString *actionType = [listDic ds_stringForKey:@"actionType"];
        NSString *url = [listDic ds_stringForKey:@"url"];
        
        //如果actionType=-2,则特殊处理自定义完整ddeplink
        if (actionType.integerValue == -2) {
            bannerModel.deeplink_uri = ZFToString(ZFEscapeString(url, YES));
        } else {
            bannerModel.deeplink_uri = [NSString stringWithFormat:ZFCMSConvertDeepLinkString, actionType, url, bannerModel.name];
        }
        [bannerModelArr addObject:bannerModel];
        
        //如果有Banner, GA 广告浏览
        NSString *GAImpress = [NSString stringWithFormat:@"%@_%ld_%@", [self GAAnalyticsKey], (long)index, ZFToString(bannerModel.name)];
        NSArray *GAParams = @[@{@"name" : GAImpress}];
        [ZFAnalytics showAdvertisementWithBanners:GAParams position:nil screenName:@"订单支付成功页"];
        
        //增加AppsFlyer统计
        NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                          @"af_banner_name" : ZFToString(bannerModel.name), //banenr名，如叫拼团
                                          @"af_channel_name" : ZFToString(bannerModel.menuid), //菜单id，如Homepage / NEW TO SALE
                                          @"af_ad_id" : ZFToString(bannerModel.banner_id), //banenr id，数据来源于后台配置返回的id
                                          @"af_component_id" : ZFToString(bannerModel.componentId),//组件id，数据来源于后台返回的组件id
                                          @"af_col_id" : ZFToString(bannerModel.colid), //坑位id，数据来源于后台返回的坑位id
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type) //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_impression" withValues:appsflyerParams];
        
//        [ZFGrowingIOAnalytics ZFGrowingIOActivityImpByCMS:bannerModel];
        [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithBannerModel:bannerModel page:@"支付成功页"];
        index++;
    }
    self.bannerModelArr = bannerModelArr;
}

/**
 * V3.8.0增加此逻辑
 * 背景: 线上1/3用户出现在此页面请求失败的场景, 因此只要出现失败都当做成功处理点击去订单列表页
 */
- (void)dealwithOtherWase {
    self.tableView.emptyDataImage = ZFImageWithName(@"blankPage_payOkHasNoData");
    self.tableView.emptyDataTitle = ZFLocalizedString(@"Payment_Success", nil);
    self.tableView.emptyDataBtnTitle = ZFLocalizedString(@"orderListButton", nil);
    
    self.tableView.requestFailImage = ZFImageWithName(@"blankPage_payOkHasNoData");
    self.tableView.requestFailTitle = ZFLocalizedString(@"Payment_Success", nil);
    self.tableView.requestFailBtnTitle = ZFLocalizedString(@"orderListButton", nil);
    
    self.tableView.networkErrorImage = ZFImageWithName(@"blankPage_payOkHasNoData");
    self.tableView.networkErrorTitle = ZFLocalizedString(@"Payment_Success", nil);
    self.tableView.networkErrorBtnTitle = ZFLocalizedString(@"orderListButton", nil);
    
    @weakify(self)
    [self.tableView setBlankPageViewActionBlcok:^(ZFBlankPageViewStatus status) {
        @strongify(self)
        // 产品规定失败都当做成功处理去订单列表页
        if (self.toAccountOrHomeblock) {
            self.toAccountOrHomeblock(YES);
        } else {
            //防止未实现回调退不出去
            [(ZFTabBarController *)self.tabBarController setZFTabBarIndex:TabBarIndexAccount];
        }
    }];
}

#pragma mark - Private method
- (void)configureTypeDataSource {
    [self.sections removeAllObjects];
    NSMutableArray *types = [NSMutableArray arrayWithArray:@[@[@(ZFPaySuccessTypePoint)],@[@(ZFPaySuccessTypeDetail)]]];
    /**
     *  V4.5.7 五周年纪念日送积分优惠券字段
     * banner_type: 0 都不显示 1 显示积分 2 显示优惠券 3 都显示
     */
    NSInteger showFlag = self.fiveThModel.banner_type.integerValue;
    if (showFlag == 2 || showFlag == 3) { // 添加优惠券banner
        [types addObject:@[@(ZFPaySuccessTypeFivethCouponBanner)]];
        
        ZFBannerModel *couponModel = [[ZFBannerModel alloc] init];
        couponModel.image = self.fiveThModel.coupon_image_url;
        couponModel.deeplink_uri = [NSString stringWithFormat:ZFCMSConvertDeepLinkString, @"9", @"", ZFLocalizedString(@"Account_Cell_Coupon", nil)];
        couponModel.banner_width = @"343";
        couponModel.banner_height = @"276";
        self.fiveThCouponModel = couponModel;
    }
    
    if (showFlag == 1 || showFlag == 3) { // 显示积分banner
        [types addObject:@[@(ZFPaySuccessTypeFivethPointBanner)]];
        
        ZFBannerModel *pointModel = [[ZFBannerModel alloc] init];
        pointModel.image = self.fiveThModel.point_image_url;
        pointModel.deeplink_uri = [NSString stringWithFormat:ZFCMSConvertDeepLinkString, @"18", self.fiveThModel.point_web_url, ZFLocalizedString(@"Account_Cell_Points", nil)];
        pointModel.banner_width = @"343";
        pointModel.banner_height = @"260";
        self.fiveThPointModel = pointModel;
    }
    
    // 多分管放最后
    if (self.bannerModelArr.count > 0) {
        [types addObject:@[@(ZFPaySuccessTypeBanner)]];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:types.count];
    for (NSArray *section in types) {
        NSMutableArray *cells = [NSMutableArray arrayWithCapacity:section.count];
        
        for (NSNumber *type in section) {
            ZFPaySuccessTypeModel *model = [[ZFPaySuccessTypeModel alloc] initWithPaySuccessModel:[type integerValue] rowCount:section.count];
            if ([type integerValue] == ZFPaySuccessTypePoint) {
                model.rowHeight = 128;
                
            } else if ([type integerValue] == ZFPaySuccessTypeBanner) { // V4.5.3开始使用CMS接口的广告数据
                model.rowHeight = [self fetchBannerHeight:self.bannerModelArr];
                
            } else if ([type integerValue] == ZFPaySuccessTypeFivethPointBanner) {// V4.5.7开始
                model.rowHeight = [self fetchFivethBannerTypeHeight:self.fiveThPointModel];
                
            }  else if ([type integerValue] == ZFPaySuccessTypeFivethCouponBanner) {
                model.rowHeight = [self fetchFivethBannerTypeHeight:self.fiveThCouponModel];
                
            } else if ([type integerValue] == ZFPaySuccessTypeDetail) {
                model.rowHeight = 128;
            }
            [cells addObject:model];
        }
        [sections addObject:cells];
    }
    self.sections = sections;
}

- (CGFloat)fetchBannerHeight:(NSArray *)bannerModelArr {
    CGFloat bannerHeight = 0;
    NSInteger branchCount = bannerModelArr.count;
    if (branchCount > 0) {
        ZFBannerModel *model = bannerModelArr.firstObject;
        BOOL isValid = !ZFIsEmptyString(model.banner_height) && !ZFIsEmptyString(model.banner_width);
        CGFloat scale = isValid ? [model.banner_width floatValue] / [model.banner_height floatValue] : 0;
        CGFloat bannerWidth = KScreenWidth / branchCount;
        bannerHeight = scale > 0 ?  (bannerWidth / scale) : 0.1;
    }
    return bannerHeight;
}

- (CGFloat)fetchFivethBannerTypeHeight:(ZFBannerModel *)model {
    CGFloat bannerWidth = model.banner_width.floatValue;
    CGFloat showHeight = 0.0;
    if (bannerWidth != 0) {
        CGFloat showWidth = KScreenWidth; // 五周年的banner左右边上留12宽度
        showHeight = model.banner_height.floatValue * showWidth / bannerWidth;
    }
    return showHeight;
}

- (void)eventLog {
    [ZFAnalytics screenViewQuantityWithScreenName:@"PaySuccess"];
}

/**
 * 统计广告点击
 */
- (void)analyticsBanner:(ZFBannerModel *)model idx:(NSInteger)idx {
    //GA 广告点击
    NSString *GAImpress = [NSString stringWithFormat:@"%@_%ld_%@", [self GAAnalyticsKey], (long)idx, ZFToString(model.name)];
    [ZFAnalytics clickAdvertisementWithId:ZFToString(model.banner_id) name:GAImpress position:nil];
    
    //增加AppsFlyer统计
    NSDictionary *appsflyerParams = @{@"af_content_type" : @"banner impression",  //固定值 banner impression
                                      @"af_banner_name" : ZFToString(model.name), //banenr名，如叫拼团
                                      @"af_channel_name" : ZFToString(model.menuid), //菜单id，如Homepage / NEW TO SALE
                                      @"af_ad_id" : ZFToString(model.banner_id), //banenr id，数据来源于后台配置返回的id
                                      @"af_component_id" : ZFToString(model.componentId),//组件id，数据来源于后台返回的组件id
                                      @"af_col_id" : ZFToString(model.colid), //坑位id，数据来源于后台返回的坑位id
                                      @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                      @"af_page_name" : @"pay_success",    // 当前页面名称
                                      };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
//    [ZFGrowingIOAnalytics ZFGrowingIOActivityClickByCMS:model];
    [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithBannerModel:model page:@"支付成功页" sourceParams:@{
        
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray<ZFPaySuccessTypeModel *> *cells = self.sections[section];
    return cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFPaySuccessTypeModel *typeModel = self.sections[indexPath.section][indexPath.row];
    switch (typeModel.type) {
        case ZFPaySuccessTypePoint:
        {
            ZFPaySuccessPointCell *pointCell = [ZFPaySuccessPointCell pointCellWith:tableView];
            pointCell.model = self.model;
            return pointCell;
        }
            break;
        case ZFPaySuccessTypeDetail:
        {
            ZFPaySuccessDetailCell *detailCell = [ZFPaySuccessDetailCell detailCellWith:tableView];
            //            self.model.offlineLink = @"12345";
            detailCell.model = self.model;
            @weakify(self);
            detailCell.buttonHandler = ^(UIButton *sender) {
                @strongify(self);
                BOOL isAccount = sender.tag == OrderFinishActionTypeOrderList ? YES : NO;
                if (self.toAccountOrHomeblock) {
                    self.toAccountOrHomeblock(isAccount);
                }
            };
            detailCell.checkTokenButtonHandler = ^{
                @strongify(self);
                [self pushToWebVCWithUrl:self.model.offlineLink];
            };
            return detailCell;
        }
            break;
        case ZFPaySuccessTypeBanner:
        {
            ZFPaySuccessBannerCell *bannerCell = [ZFPaySuccessBannerCell bannerCellWith:tableView];
            bannerCell.banners = self.bannerModelArr; //CMS广告
            @weakify(self);
            bannerCell.paySuccessBannerHandler = ^(ZFBannerModel *model, NSInteger idx) {
                @strongify(self);
                //test
                [BannerManager doBannerActionTarget:self withBannerModel:model];
                [self analyticsBanner:model idx:idx];
            };
            return bannerCell;
        }
            break;
        case ZFPaySuccessTypeFivethCouponBanner:
        case ZFPaySuccessTypeFivethPointBanner:
        {
            ZFPaySuccessFiveThbannerCell *bannerCell = [ZFPaySuccessFiveThbannerCell bannerCellWith:tableView];
            if (typeModel.type == ZFPaySuccessTypeFivethCouponBanner) {
                bannerCell.bannerModel = self.fiveThCouponModel;
            } else {
                bannerCell.bannerModel = self.fiveThPointModel;
            }
            @weakify(self);
            bannerCell.payBannerHandler = ^(ZFBannerModel *model) {
                @strongify(self);
                //[BannerManager doBannerActionTarget:self withBannerModel:model];//产品改需求不跳本地deeplink
                if (typeModel.type == ZFPaySuccessTypeFivethCouponBanner) {
                    [self pushToWebVCWithUrl:self.fiveThModel.coupon_web_url];
                } else {
                    [self pushToWebVCWithUrl:self.fiveThModel.point_web_url];
                }
            };
            return bannerCell;
        }
            break;
        case ZFPaySuccessTypeOrderPartHint:
        {
            
        }
            break;
        case ZFPaySuccessTypeCODCheckAddress:
        {
            
        }
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFPaySuccessTypeModel *typeModel = self.sections[indexPath.section][indexPath.row];
    if (typeModel.type == ZFPaySuccessTypeBanner ||
        typeModel.type == ZFPaySuccessTypeFivethCouponBanner ||
        typeModel.type == ZFPaySuccessTypeFivethPointBanner) {
        return (typeModel.rowHeight > 0) ? typeModel.rowHeight : 200;
    } else {
        return UITableViewAutomaticDimension;
    }
}

/// 到商品详情页
- (void)pushToGoodsDetail:(NSString *)goods_id {
    ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];
    detailVC.goodsId = goods_id;
    detailVC.afParams = self.recomendAFParams;
    detailVC.sourceType = ZFAppsflyerInSourceTypePaySuccessRecommend;
    self.navigationController.delegate = nil;
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 200;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

- (ZFCarRecommendView *)tableFooterView {
    if (!_tableFooterView) {
        _tableFooterView = [[ZFCarRecommendView alloc] init];
        _tableFooterView.isPaysuccessView = YES;
        _tableFooterView.frame = CGRectMake(0, 0, KScreenWidth, 270 * ScreenWidth_SCALE + 14);
        @weakify(self)
        [_tableFooterView setCarRecommendSelectGoodsBlock:^(NSString * _Nonnull goodsId, UIImageView * _Nonnull imageView) {
            @strongify(self)
            [self pushToGoodsDetail:goodsId];
        }];
    }
    return _tableFooterView;
}

- (ZFNewPushAllowView *)pushAllowView {
    if (!_pushAllowView) {
        _pushAllowView = [[ZFNewPushAllowView alloc] init];
    }
    return _pushAllowView;
}

- (ZFPaySuccessViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFPaySuccessViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (NSMutableArray *)sections {
    if (!_sections) {
        _sections = [NSMutableArray array];
    }
    return _sections;
}

- (NSString *)GAAnalyticsKey {
    return @"impression_paysuccess_banner";
}


@end
