//
//  ZFCarPiecingOrderVC.m
//  ZZZZZ
//
//  Created by YW on 2018/9/15.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCarPiecingOrderVC.h"
#import "ZFPiecingOrderViewModel.h"
#import "ZFPiecingOrderPriceModel.h"
#import "ZFCarPiecingOrderSubVC.h"
#import "ZFGoodsModel.h"
#import "ZFCarPiecingOrderBottomView.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFAnalytics.h"
#import "ExchangeManager.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"


@interface ZFCarPiecingOrderVC ()
@property (nonatomic, strong) NSArray<ZFPiecingOrderPriceModel *> *tagDataArray;
@property (nonatomic, strong) NSArray *firstSectionGoodsList;
@property (nonatomic, strong) ZFCarPiecingOrderBottomView *bottomView;
@end

@implementation ZFCarPiecingOrderVC

- (instancetype)init {
    if (self = [super init]) {
        self.titleSizeNormal    = 14.0f;
        self.titleSizeSelected  = 14.0f;
        self.menuViewStyle      = WMMenuViewStyleLine;
        self.itemMargin         = 15.0f;
        self.titleColorNormal   = ZFCOLOR(153, 153, 153, 1);
        self.titleColorSelected = ZFC0x2D2D2D();
        self.progressColor      = ZFC0x2D2D2D();
        self.progressHeight     = 3.0f;
        self.automaticallyCalculatesItemWidths = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"PiecingOrderVCTitle_AddItems",nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    //添加一个透明视图让事件传递到顶层,使其能够侧滑返回
    [self shouldShowLeftHoledSliderView:self.view.height];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //获取第一页数据的标签数组
    [self requestPiecingOrderData];
}

- (ZFCarPiecingOrderBottomView *)bottomView {
    if(!_bottomView){
        _bottomView = [[ZFCarPiecingOrderBottomView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_bottomView];
        
        [_bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self.view);
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-kiphoneXHomeBarHeight);
        }];
    }
    [self.view bringSubviewToFront:_bottomView];
    return _bottomView;
}

#pragma mark - 网络请求
- (void)requestPiecingOrderData {
    ShowLoadingToView(self.view);
    @weakify(self)
    [ZFPiecingOrderViewModel requestPiecingOrderData:nil finishedHandle:^(NSDictionary *resultDict){
        @strongify(self)
        HideLoadingFromView(self.view);
        
        NSArray *priceSectionArray = [resultDict ds_arrayForKey:@"price_section"];
        if (priceSectionArray.count == 0) {
            [self showAgainRequestView];
            return ;
        }
        self.tagDataArray = [NSArray yy_modelArrayWithClass:[ZFPiecingOrderPriceModel class] json:priceSectionArray];
        
        NSArray *firstGoodList = [resultDict ds_arrayForKey:@"goods_list"];
        if (firstGoodList.count>0) {
            self.firstSectionGoodsList = [NSArray yy_modelArrayWithClass:[ZFGoodsModel class] json:firstGoodList];
        }
        self.bottomView.topPrice = [resultDict ds_stringForKey:@"cart_total_amount"];
        self.bottomView.bottomPrice = [resultDict ds_stringForKey:@"cart_shipping_free_amount"];
        
        [self reloadData];
        [self shouldSelectedCustomTaget];
    }];
}

/**
 * 选中指定标签
 */
- (void)shouldSelectedCustomTaget {
    [self.tagDataArray enumerateObjectsUsingBlock:^(ZFPiecingOrderPriceModel * _Nonnull priceModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if (priceModel.checked) {
            self.selectIndex = (int)idx;
            *stop = YES;
        }
    }];
}

#pragma mark - privete method
- (void)showAgainRequestView {
    self.emptyImage = [UIImage imageNamed:@"blankPage_requestFail"];
    self.emptyTitle = ZFLocalizedString(@"Search_ResultViewModel_Tip",nil);
    self.edgeInsetTop = -TabBarHeight;
    @weakify(self)
    [self showEmptyViewHandler:^{
        @strongify(self)
        //获取第一页数据的标签数组
        [self requestPiecingOrderData];
    }];
}

#pragma mark -WMPageControllerDelegate / WMPageControllerDatasource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.tagDataArray.count;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    if (self.tagDataArray.count <= index) return nil;
    ZFPiecingOrderPriceModel *piecingModel = self.tagDataArray[index];
    // 拼接显示的价格区间
    NSString *start_price = [ExchangeManager transforPrice:piecingModel.start_price];
    NSString *end_price = [ExchangeManager transforPrice:piecingModel.end_price];
    return [NSString stringWithFormat:@"%@-%@", start_price, end_price];
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    if (self.tagDataArray.count <= index) return nil;
    ZFPiecingOrderPriceModel *piecingModel = self.tagDataArray[index];
    
    ZFCarPiecingOrderSubVC *subVC   = [[ZFCarPiecingOrderSubVC alloc] init];
    subVC.priceSectionID = piecingModel.priceSectionID;
    if (piecingModel.checked == YES && self.firstSectionGoodsList.count>0) {
        subVC.goodDataList = self.firstSectionGoodsList;
    }
    //GA统计事件
    NSString *impressionName = [NSString stringWithFormat:@"impression_addItems_%@", ZFToString(piecingModel.end_price)];
    [ZFAnalytics showAdvertisementWithBanners:@[@{@"name" : impressionName}] position:@"" screenName:@"凑单页"];
    
    return subVC;
}

- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info
{
    //GA统计点击事件
    NSInteger index = [info[@"index"] integerValue];
    if (self.tagDataArray.count > index) {
        ZFPiecingOrderPriceModel *piecingModel = self.tagDataArray[index];
        NSString *impressionName = [NSString stringWithFormat:@"impression_addItems_%@", ZFToString(piecingModel.end_price)];
        [ZFAnalytics clickAdvertisementWithId:@"" name:impressionName position:@""];
    }
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, 0, KScreenWidth, 44);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat menuMaxY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    CGFloat selfViewH = self.view.height - 44 -self.bottomView.height - kiphoneXHomeBarHeight;
    return CGRectMake(0, menuMaxY, KScreenWidth, selfViewH);
}

@end
