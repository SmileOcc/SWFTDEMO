//
//  OSSVCartVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartVC.h"
#import "STLAlertControllerView.h"
#import "OSSVAppNewThemeVC.h"
#import "CartModel.h"
#import "STLCartModel.h"
#import "OSSVCartFreeShippingModel.h"
#import "OSSVVivaiaCartFreeShippingModel.h"
#import "OSSVCartViewModel.h"
#import "MGSwipeTableCell.h"
#import "OSSVCartHeaderView.h"
#import "OSSVCommendFooterView.h"
#import "SDCycleScrollView.h"
#import "OSSVCartBottomResultView.h"
#import "OSSVCartSelectCodGoodsView.h"
#import "STLAlertBottomView.h"
#import "OSSVCartHeaderFreeShippingView.h"
#import "OSSVWishListVC.h"
#import "OSSVAppNewThemeVC.h"
#import "OSSVTopSignInView.h"
#import "OSSVCommonnRequestsManager.h"

@interface OSSVCartVC ()<SDCycleScrollViewDelegate, OSSVCartHeaderFreeShippingViewDelegate>

@property (nonatomic, strong) OSSVTopSignInView          *topSignInView; //顶部登录
@property (nonatomic, strong) UIView                    *tableHeaderView;

@property (nonatomic, strong) UITableView               *tableView;
//顶部包邮文案
@property (nonatomic, strong) OSSVCartHeaderFreeShippingView *freeShipView;
/** COD宣传语*/
@property (nonatomic, strong) UIView                    *topCodBgView;
@property (nonatomic, strong) SDCycleScrollView         *topCycleView;
/** 闪购提示语*/
@property (nonatomic, strong) UIView                    *flashTipView;
@property (nonatomic, strong) UILabel                   *flashTipLabel;

/** 凑单提示*/
@property (nonatomic, strong) OSSVCartSelectCodGoodsView  *selectCodGoodsView;
/** 选择结果条*/
@property (nonatomic, strong) OSSVCartBottomResultView      *bottomResultView;

@property (nonatomic, strong) OSSVCartViewModel             *cartViewModel;
@property (nonatomic, strong) NSMutableArray            *cycleTitlesArray;

@property (nonatomic, assign) BOOL                      isNeedAnalyticsStart;

@property (nonatomic, strong) NSMutableArray <NSString*> *aopGoodsSet;

///标记是否有正在请求的加载数据
@property (nonatomic,assign) BOOL hasPreRequest;
@property (nonatomic, copy)  NSString *specialId; //专题ID
@end

@implementation OSSVCartVC
static int instanceCount = 0;
-(void)dealloc {
    [self removeObservers];
    instanceCount--;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage yy_imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.aopGoodsSet removeAllObjects];
    self.isNeedAnalyticsStart = YES;
    [self requestDataShowLoading:!self.firstEnter];
    if (!self.firstEnter) {
        self.firstEnter = YES;
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
        
//    __block NSMutableArray *cartSkus = [[NSMutableArray alloc] init];
//    NSArray *goodsLists = [self.cartViewModel.cartModel allValidGoods];
//    [goodsLists enumerateObjectsUsingBlock:^(CartModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [cartSkus addObject:STLToString(obj.goods_sn)];
//    }];
//
//    NSString *cartSkuString = [cartSkus componentsJoinedByString:@","];
    
    [STLAlertBottomView removeOkAlertFromWindow];
}

- (NSMutableArray<NSString *> *)aopGoodsSet {
    if (!_aopGoodsSet) {
        _aopGoodsSet = [[NSMutableArray alloc] init];
    }
    return _aopGoodsSet;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = STLLocalizedString_(@"cart_title",nil);
    self.view.backgroundColor = OSSVThemesColors.col_F7F7F7;
    self.currentPageCode = @"cart";
    [self initView];
    [self registerNotify];
    instanceCount++;
    _hasPreRequest = NO;
    
    ///1.3.8 16 增加收藏入口
    [self setupRightNavibarItem];
}


-(NSString *)specialId {
    if (!_specialId) {
        _specialId = [NSString string];
    }
    return _specialId;
}

-(void)setupRightNavibarItem{
    UIButton *wishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    wishBtn.frame = CGRectMake(0, 0, 24, 24);
    
    UIImage *image = [UIImage imageNamed:@"wishlist_new"];
    [wishBtn setImage:image forState:UIControlStateNormal];
//    [wishBtn convertUIWithARLanguage];
    UIBarButtonItem *whishItem = [[UIBarButtonItem alloc] initWithCustomView:wishBtn];
    self.navigationItem.rightBarButtonItem = whishItem;
    
    [wishBtn addTarget:self action:@selector(jumpToWishList) forControlEvents:UIControlEventTouchUpInside];
    wishBtn.sensor_element_id = @"collect_button";
}

-(void)jumpToWishList{
    
    ///判断是否登录
    if (![OSSVAccountsManager sharedManager].isSignIn) {
        SignViewController *signVC = [SignViewController new];
        signVC.modalPresentationStyle = UIModalPresentationFullScreen;
        @weakify(self)
        signVC.modalBlock = ^{
            @strongify(self)
            [self directToWishList];
        };
        [self presentViewController:signVC animated:YES completion:nil];
    } else {
        [self directToWishList];
    }
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"top_function" parameters:@{
           @"screen_group":@"Cart",
           @"button_name":@"Wishlist"}];
    
}


-(void)directToWishList{
    ///1.3.8 收藏入口埋点
    OSSVWishListVC *wishListVC = nil;
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    NSInteger index = 0;
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:OSSVWishListVC.class] && index != 0) {
            wishListVC = (OSSVWishListVC*)vc;
            break;
        }
        index++;
    }
    if (wishListVC) {
        [arr removeObject:wishListVC];
        [self.navigationController setViewControllers:arr animated:YES];
    }
    if (!wishListVC) {
        wishListVC = [[OSSVWishListVC alloc] init];
    }

    [self.navigationController pushViewController:wishListVC animated:YES];
    
}

#pragma mark - MakeUI

- (void)initView {
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = OSSVThemesColors.col_F7F7F7;
    [self.tableHeaderView addSubview:lineView];
    
    [self.tableHeaderView addSubview:self.freeShipView];
    [self.tableHeaderView addSubview:self.topCodBgView];
    [self.tableHeaderView addSubview:self.flashTipView];
    [self.flashTipView addSubview:self.flashTipLabel];
    [self.topCodBgView addSubview:self.topCycleView];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.tableHeaderView);
        if (APP_TYPE == 3) {
            make.height.equalTo(2);
        } else {
            make.height.equalTo(8);
        }
//        make.height.equalTo(8);

    }];
    
    [self.freeShipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.tableHeaderView);
        make.top.mas_equalTo(lineView.mas_bottom);
        make.height.equalTo(0);
    }];
    
    [self.topCodBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.tableHeaderView);
        make.top.mas_equalTo(self.freeShipView.mas_bottom);
        make.height.equalTo(44);
    }];
    
    [self.topCycleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topCodBgView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.topCodBgView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.topCodBgView.mas_top);
        make.height.equalTo(44);
    }];
    [self.flashTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.flashTipView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.flashTipView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.flashTipView.mas_centerY);
    }];
    
//    self.tableView.tableHeaderView = self.tableHeaderView;
    
    [self.view addSubview:self.topSignInView];
    [self.view addSubview:self.selectCodGoodsView];
    [self.view addSubview:self.bottomResultView];
    [self.view addSubview:self.tableView];
    
    [self.topSignInView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.view);
        make.height.equalTo(0);
    }];
    
    [self.bottomResultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(self.view);
    }];
    
    [self.selectCodGoodsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomResultView.mas_top);
        make.height.mas_equalTo(0);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (APP_TYPE == 3) {
            make.leading.trailing.mas_equalTo(self.view);
        } else {
            make.leading.mas_equalTo(self.view).offset(12);
            make.trailing.mas_equalTo(self.view).offset(-12);
        }
        make.top.mas_equalTo(self.topSignInView.mas_bottom).offset(0);
        make.bottom.mas_equalTo(self.selectCodGoodsView.mas_top);
    }];
    
}

-(void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_Cart object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_Login object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_Logout object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotif_Currency object:nil];
}


- (void)registerNotify {
    //应该先判断Tabbar里面的CartViewCtrl是否存在
    if (instanceCount >= 1) {
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCartNotify:) name:kNotif_Cart object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCartNotify:) name:kNotif_Login object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshCartNotify:) name:kNotif_Logout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCurrency:) name:kNotif_Currency object:nil];
}

#pragma mark - Request

//同步数据处理
- (void)requestDataShowLoading:(BOOL)showLoading{
    if (_hasPreRequest) {
        return;
    }
    
    _hasPreRequest = YES;
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        [[OSSVCartsOperateManager sharedManager] cartSyncServiceDataGoods:nil showView: showLoading ? self.view : nil Completion:^(STLCartModel *obj) {
            @strongify(self)

            [self updateCartView];
            [self.cartViewModel updateCartData:obj];
            self.tableView.hidden = NO;

            [self showBuyAgainAlertView];
            
//            if (self.isNeedAnalyticsStart) {
//                self.isNeedAnalyticsStart = NO;
//                __block NSMutableArray *cartSkus = [[NSMutableArray alloc] init];
//                NSArray *goodsLists = [self.cartViewModel.cartModel allValidGoods];
//                [goodsLists enumerateObjectsUsingBlock:^(CartModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    [cartSkus addObject:STLToString(obj.goods_sn)];
//                }];
//
//                NSString *cartSkuString = [cartSkus componentsJoinedByString:@","];
//
//            }
            _hasPreRequest = NO;
            [self handleEmptyButton:YES];
            [self.tableView showRequestTip:@{}];

        } failure:^(id obj) {
            @strongify(self)
            
            [self updateCartView];
            [self.cartViewModel updateCartData:nil];
            self.tableView.hidden = NO;
            [self handleEmptyButton:YES];
            [self.tableView showRequestTip:nil];

            [[OSSVCartsOperateManager sharedManager] cartSaveValidGoodsAllCount:0];
            _hasPreRequest = NO;
        }];

    } exception:^{
        @strongify(self)
        [self updateCartView];
        [self.cartViewModel updateCartData:nil];
        self.tableView.hidden = NO;
        [self handleEmptyButton:NO];
        [self.tableView showRequestTip:nil];
        _hasPreRequest = NO;
    }];
}


- (void)deleteAction:(UIButton *)sender {
    
}
#pragma mark - 再次购买弹窗
- (void)showBuyAgainAlertView {
    
    if (self.buyAgainAlert) {
        self.buyAgainAlert = NO;
       
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"Repurchase_invalid_order_goods_moved_following_zone", nil)];
    }
}


#pragma mark Cod凑单
- (void)tailorCodGoods {
    
    CartNeedBuyModel *buyModel = self.cartViewModel.cartModel.needBuy;
    OSSVAppNewThemeVC *themeCtrl = [[OSSVAppNewThemeVC alloc] init];
    themeCtrl.customId = STLToString(buyModel.idx);
    themeCtrl.customName = STLToString(buyModel.title);
    [self.navigationController pushViewController:themeCtrl animated:YES];
}


#pragma mark - 刷新控件
- (void)updateCartView {
    
//    NSArray *selectedLists = [self.cartViewModel.cartModel allSelectGoods];
    NSArray *goodsLists = [self.cartViewModel.cartModel allValidGoods];
    NSArray *failureGoodsLists = self.cartViewModel.cartModel.failureGoodsList;
    //顶部活动
    [self updateTopCycleDatas:self.cartViewModel.cartModel.cartTips hasGoods:(goodsLists.count + failureGoodsLists.count)freeShipping:self.cartViewModel.cartModel.freeShippingTip vivaiaFreeShip:self.cartViewModel.cartModel.vivaiaFreeShipping];

//    //cod凑单提示
//    self.selectCodGoodsView.hidden = YES;
//    [self.selectCodGoodsView setHtmlTitle:@"" specialUrl:@""];
//    if (selectedLists.count > 0) {// 购物车有选择的效商品
//        CartNeedBuyModel *buyModel = self.cartViewModel.cartModel.needBuy;
//        if (![OSSVNSStringTool isEmptyString:buyModel.content]) {
//            [self.selectCodGoodsView setHtmlTitle:STLToString(buyModel.content) specialUrl:STLToString(buyModel.idx)];
//            self.selectCodGoodsView.hidden = NO;
//        }
//    }

    //底部结算
    [self updateBottomResultView:goodsLists.count];
    
    if ([UIViewController currentTopViewController] != self) {
        STLLog(@"-----购物车没显示出来");
        return;
    }
    STLLog(@"-----购物车显示出来刷新");

    __block NSMutableArray *itemsGoods = [[NSMutableArray alloc] init];
    __block CGFloat allPrice = 0;
    __block NSMutableArray *tempGoodsIDsArray = [[NSMutableArray alloc] init];
    [goodsLists enumerateObjectsUsingBlock:^(CartModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (![self.aopGoodsSet containsObject:STLToString(obj.goods_sn)]) {

            CGFloat price = [obj.shop_price floatValue];
            ///与有效商品显示逻辑一致
            if (obj.flash_sale && [obj.flash_sale isCanBuyFlashSaleStateing]) {
                price = [obj.flash_sale.active_price floatValue];
            }
            allPrice += obj.goodsNumber * price;
            NSDictionary *items = @{
                @"item_id": STLToString(obj.goods_sn),
                @"item_name": STLToString(obj.goodsName),
                @"item_category": STLToString(obj.cat_name),
                @"price": @(price),
                @"quantity": @(obj.goodsNumber),
                @"item_variant":STLToString(obj.goodsAttr),
            };
            
            [itemsGoods addObject:items];
            
            [tempGoodsIDsArray addObject:STLToString(obj.goods_sn)];
        }
    }];
    
    [failureGoodsLists enumerateObjectsUsingBlock:^(CartModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        
        if (![self.aopGoodsSet containsObject:STLToString(obj.goods_sn)]) {
            CGFloat price = [obj.shop_price floatValue];
            ///与失效商品显示逻辑一致
            if (obj.flash_sale && [obj.is_flash_sale boolValue] && [obj.flash_sale.active_status integerValue] == 1) {
                price = [obj.flash_sale.active_price floatValue];
            }
            NSDictionary *items = @{
                @"item_id": STLToString(obj.goods_sn),
                @"item_name": STLToString(obj.goodsName),
                @"item_category": STLToString(obj.cat_name),
                @"price": @(price),
                @"quantity": @(obj.goodsNumber),
                @"item_variant":STLToString(obj.goodsAttr),
            };
            
            [itemsGoods addObject:items];
            [tempGoodsIDsArray addObject:STLToString(obj.goods_sn)];
        }
    }];
    
    if (STLJudgeNSArray(itemsGoods) && itemsGoods.count > 0) {
        self.aopGoodsSet = [[NSMutableArray alloc] initWithArray:tempGoodsIDsArray];
    }
    
    //GA
    NSDictionary *itemsDic = @{@"items":itemsGoods,
                               @"currency": @"USD",
                               @"value": @(allPrice),
                               @"screen_group":@"Cart"
    };
    
    [OSSVAnalyticsTool analyticsGAEventWithName:kFIREventViewCart parameters:itemsDic];
    
    //未登录并且购物车有数据
    if (![OSSVAccountsManager sharedManager].isSignIn && (goodsLists.count || failureGoodsLists.count)) {
        self.topSignInView.hidden = NO;
        [self.topSignInView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(44);
        }];
        
    } else {
        [self.topSignInView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(0);
        }];
        self.topSignInView.hidden = YES;
    }
}


#pragma mark 顶部活动 文案
- (void)updateTopCycleDatas:(NSArray *)cartTips hasGoods:(BOOL)hasGoods freeShipping:(OSSVCartFreeShippingModel *)freeShippingModel vivaiaFreeShip:(OSSVVivaiaCartFreeShippingModel *)vivaiFreeShippingModel {
    
    //包邮文案处理
    self.freeShipView.rightButton.hidden = YES;
    NSString *specailId = STLToString(freeShippingModel.specialId);
    NSString *freeShipLeft = STLToString(freeShippingModel.freeShipLeft);
    NSString *freeShipRight = STLToString(freeShippingModel.freeShipRight);
    NSString *amount = STLToString(freeShippingModel.amount);
    self.specialId = specailId;
    if (APP_TYPE == 3) {
        if (!STLIsEmptyString(specailId) && STLToString(vivaiFreeShippingModel.percentage).intValue < 100) {
            self.freeShipView.rightButton.hidden = NO;
        }
    } else {
        if (!STLIsEmptyString(specailId)) {
            self.freeShipView.rightButton.hidden = NO;
        }
    }
    
    if (APP_TYPE == 3) {
        self.freeShipView.progress = STLToString(vivaiFreeShippingModel.percentage).floatValue / 100;
        self.freeShipView.freeShippingLabel.textColor = OSSVThemesColors.col_FF9318;
        self.freeShipView.freeShippingLabel.text = STLToString(vivaiFreeShippingModel.text);

    } else {
        if (STLIsEmptyString(amount)) {
            self.freeShipView.freeShippingLabel.text = freeShipLeft;
        } else {
            //阿语环境
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                NSString *contentString = [NSString stringWithFormat:@"%@%@%@", freeShipRight, amount, freeShipLeft];
                NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:contentString];
                [att addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_666666 range:NSMakeRange(0, freeShipRight.length)];
                [att addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_B62B21 range:NSMakeRange(freeShipRight.length, amount.length)];
                [att addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_666666 range:NSMakeRange(freeShipRight.length+amount.length, freeShipLeft.length)];
                self.freeShipView.freeShippingLabel.attributedText = att;

            } else {
                NSString *contentString = [NSString stringWithFormat:@"%@%@%@", freeShipLeft, amount, freeShipRight];
                NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:contentString];
                [att addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_666666 range:NSMakeRange(0, freeShipLeft.length)];
                [att addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_B62B21 range:NSMakeRange(freeShipLeft.length, amount.length)];
                [att addAttribute:NSForegroundColorAttributeName value:OSSVThemesColors.col_666666 range:NSMakeRange(freeShipLeft.length+amount.length, freeShipRight.length)];
                self.freeShipView.freeShippingLabel.attributedText = att;
            }
        }
    }

    if (cartTips.count > 0) {
        [self.cycleTitlesArray removeAllObjects];
        [self.cycleTitlesArray addObjectsFromArray:cartTips];
        self.topCycleView.titlesGroup = self.cycleTitlesArray;
        self.topCycleView.autoScroll = cartTips.count > 1 ? YES : NO;
    }
    
    BOOL isShow = hasGoods ? cartTips.count: NO;
    CGRect frame = self.tableHeaderView.frame;
    
    self.tableHeaderView.hidden = YES;
    self.topCodBgView.hidden = YES;
    self.flashTipView.hidden = YES;
    
    //顶部线条间距8
      if ((STLIsEmptyString(freeShipRight) && STLIsEmptyString(freeShipLeft)) || (STLIsEmptyString(vivaiFreeShippingModel.text) && STLIsEmptyString(vivaiFreeShippingModel.percentage) && STLIsEmptyString(vivaiFreeShippingModel.differ_amount))) {
        self.freeShipView.hidden = YES;
        if (APP_TYPE == 3) {
            frame.size.height = 0.001;
        } else {
            frame.size.height = 8;
        }
    } else {
        self.freeShipView.hidden = NO;
        [self.freeShipView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.height.equalTo(60);
            } else {
                make.height.equalTo(48);
            }
        }];
        
        if (APP_TYPE == 3) {
            frame.size.height = 52 + 8;
        } else {
            frame.size.height = 48 + 8;
        }
        self.tableHeaderView.hidden = NO;
    }

    float flashTipHeight = 0;
    if (!STLIsEmptyString(self.cartViewModel.cartModel.top_notice)) {
        
        //标题内容高
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:4];

        UIFont *textFont = [UIFont systemFontOfSize:11];
        CGSize titleSize;
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        paragraph.lineSpacing = 4;//连字符

        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        titleSize = [STLToString(self.cartViewModel.cartModel.top_notice) boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 24 - 24, 42)
                                                        options:(NSStringDrawingUsesLineFragmentOrigin |
                                                                 NSStringDrawingTruncatesLastVisibleLine)
                                                     attributes:attributes
                                                        context:nil].size;
        if (titleSize.height < 20) {
            flashTipHeight = 32;
        } else {
            flashTipHeight = 42;
        }
    }
    
    //都留间距8
    if (!STLIsEmptyString(self.cartViewModel.cartModel.top_notice) && isShow) {
        
        self.topCodBgView.hidden = NO;
        self.flashTipView.hidden = NO;
        self.flashTipLabel.text = self.cartViewModel.cartModel.top_notice;
        
        self.flashTipView.frame = CGRectMake(0, frame.size.height + 44 + 8, SCREEN_WIDTH - 24, flashTipHeight);
        frame.size.height = (frame.size.height + 44 + 8 + flashTipHeight + 8);
        
        self.tableHeaderView.hidden = NO;
        
    } else if(!STLIsEmptyString(self.cartViewModel.cartModel.top_notice)) {
        
        self.flashTipLabel.text = self.cartViewModel.cartModel.top_notice;
        self.flashTipView.hidden = NO;
        self.flashTipView.frame = CGRectMake(0, frame.size.height, SCREEN_WIDTH - 24, flashTipHeight);
        frame.size.height = (frame.size.height + flashTipHeight) + 8;
       
        self.tableHeaderView.hidden = NO;
    } else if(isShow) {
        self.topCodBgView.hidden = NO;
        frame.size.height = frame.size.height + 44 + 8;
        self.tableHeaderView.hidden = NO;
    }
    self.tableHeaderView.frame = frame;
    self.tableView.tableHeaderView = self.tableHeaderView;
}

#pragma mark  底部结算条
- (void)updateBottomResultView:(BOOL)isShow {
    self.bottomResultView.hidden = !isShow;
    [self.bottomResultView mas_updateConstraints:^(MASConstraintMaker *make) {

        if (kIS_IPHONEX) {
            if (kIS_IPHONEX && self.navigationController.viewControllers.count > 1) {
                make.height.mas_equalTo((isShow ? 88 + 29 + STL_TABBAR_IPHONEX_H: 0));
            } else {
                make.height.mas_equalTo((isShow ? 88 + 29: 0));
            }
        } else {
            if (self.navigationController.viewControllers.count > 1) {
                make.height.mas_equalTo((isShow ? 88 + 29: 0));
            } else {
                make.height.mas_equalTo((isShow ? 88 + 29: 0));
            }
        }
        
    }];
    NSString *discountValue = STLToString(self.cartViewModel.cartModel.discountValue);
    NSString *discountMsg   = STLToString(self.cartViewModel.cartModel.discountMsg);

    if (!STLIsEmptyString(discountMsg)) {
        self.bottomResultView.tipCoinView.hidden = NO;
    
        if ([OSSVAccountsManager sharedManager].isSignIn && ![discountValue isEqualToString:@"0%"]) {
            //是否包含这个字符串
            if ([discountMsg rangeOfString:@"{value}"].location != NSNotFound && !STLIsEmptyString(discountValue)) {
                NSRange range = [discountMsg rangeOfString:@"{"];
                if (range.location != NSNotFound) {
                    NSLog(@"位置在： %ld, 长度==%ld", range.location, range.length);
                }
                NSString *rea = [discountMsg stringByReplacingOccurrencesOfString:@"{value}" withString:discountValue];
                NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:rea];
                [att addAttribute:NSForegroundColorAttributeName value: APP_TYPE == 3 ? OSSVThemesColors.col_9F5123: OSSVThemesColors.col_B62B21 range:NSMakeRange(range.location, discountValue.length)];
                [att addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(range.location, discountValue.length)];

                self.bottomResultView.tipMsgLabel.attributedText = att;
            } else {
                self.bottomResultView.tipMsgLabel.text = STLToString(discountMsg);
            }
        }else{
            self.bottomResultView.tipMsgLabel.text = STLToString(discountMsg);
        }
        
    } else {
        self.bottomResultView.tipMsgLabel.text = @"";
        self.bottomResultView.tipCoinView.hidden = YES;
    }
}

#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"---点击了第%ld张图片", (long)index);
}

#pragma  mark --OSSVCartHeaderFreeShippingViewDelegate ---跳转专题页
- (void)rightButtonAction {
    
    [OSSVAnalyticsTool analyticsGAEventWithName:@"Cart_action" parameters:@{
           @"screen_group":@"Cart",
           @"action":@"Free Shipping_Pick"}];
    
    if (self.specialId.length) {
        OSSVAppNewThemeVC *themeVc = [[OSSVAppNewThemeVC alloc] init];
        themeVc.customId = self.specialId;
        themeVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:themeVc animated:YES];
        
        NSDictionary *paraDic = @{@"balance_price": STLToString(self.cartViewModel.cartModel.discountValue),
                                  @"total_price_of_goods" : STLToString(self.cartViewModel.cartModel.cartInfo.total),
                                  @"currency" : @"USD"
        };
        
        [OSSVAnalyticsTool analyticsSensorsEventWithName:@"AddFreeShipping" parameters:paraDic];
    } else {
        return;
    }
}
#pragma mark - Notification
/** 通知*/
- (void)refreshCartNotify:(NSNotification *)notify {
    [self requestDataShowLoading:NO];
}

/** 货币改变通知*/
- (void)changeCurrency:(NSNotification *)notify {
    [self.tableView reloadData];
}

#pragma mark - LazyLoad
- (OSSVCartViewModel *)cartViewModel {
    if (!_cartViewModel) {
        _cartViewModel = [[OSSVCartViewModel alloc] init];
        _cartViewModel.controller = self;
        @weakify(self)
        //获取当前cell的位置
        _cartViewModel.swipeCallback = ^(UITableViewCell *cell) {
            @strongify(self)
            return [self.tableView indexPathForCell:cell];
        };
        _cartViewModel.updateResultBlock = ^(CartInfoModel *cartPriceInfo, NSInteger count, BOOL isSelectAll) {
            @strongify(self)
            [self updateCartView];
            [self.tableView reloadData];
            [self.bottomResultView updateSelect:isSelectAll cartInfor:cartPriceInfo count:count];
        };
        _cartViewModel.emptyJumpOperationBlock = ^{
            @strongify(self)
            if (self.navigationController) {//先回到顶级
                if (self.navigationController.viewControllers.count > 1) {
                    [self.navigationController popToRootViewControllerAnimated:NO];
                }
            }
            self.tabBarController.selectedIndex = 0;
        };
        _cartViewModel.emptyOperationBlock = ^{
            @strongify(self)
            [self.tableView.mj_header beginRefreshing];
        };
    }
    return _cartViewModel;
}

- (NSMutableArray *)cycleTitlesArray {
    if (!_cycleTitlesArray) {
        _cycleTitlesArray = [[NSMutableArray alloc] init];
    }
    return _cycleTitlesArray;
}

- (UIView *)tableHeaderView {
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
//        _tableHeaderView.backgroundColor = [OSSVThemesColors stlClearColor];
        _tableHeaderView.backgroundColor = [UIColor redColor];

//        _tableHeaderView.hidden = YES;
    }
    return _tableHeaderView;
}

- (OSSVCartHeaderFreeShippingView *)freeShipView {
    if (!_freeShipView) {
        _freeShipView = [[OSSVCartHeaderFreeShippingView alloc] initWithFrame:CGRectZero];
//        _freeShipView.backgroundColor = OSSVThemesColors.col_FFF5DF;
        _freeShipView.backgroundColor = [UIColor clearColor];
        _freeShipView.delegate = self;
        _freeShipView.userInteractionEnabled = YES;
        _freeShipView.hidden = YES;
    }
    return _freeShipView;
}

- (UIView *)topCodBgView {
    if (!_topCodBgView) {
        _topCodBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _topCodBgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _topCodBgView.layer.cornerRadius = 6;
        _topCodBgView.layer.masksToBounds = YES;
        _topCodBgView.hidden = YES;
    }
    return _topCodBgView;
}
- (SDCycleScrollView *)topCycleView {
    if (!_topCycleView) {
        _topCycleView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectZero delegate:self placeholderImage:nil];
        _topCycleView.scrollDirection = UICollectionViewScrollDirectionVertical;
        _topCycleView.onlyDisplayText = YES;
        _topCycleView.titleLabelBackgroundColor = [UIColor clearColor];
        _topCycleView.titleLabelTextFont = [UIFont systemFontOfSize:14];
        _topCycleView.titleLabelTextColor = OSSVThemesColors.col_FF9522;
        _topCycleView.titleLabelHeight = 44;
        [_topCycleView disableScrollGesture];
    }
    return _topCycleView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.frame = self.view.bounds;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = OSSVThemesColors.col_F7F7F7;
        _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedSectionHeaderHeight = UITableViewAutomaticDimension;
        _tableView.estimatedSectionFooterHeight = UITableViewAutomaticDimension;
        _tableView.showsVerticalScrollIndicator = NO;
        if(@available(iOS 15.0,*)){_tableView.sectionHeaderTopPadding=0;}
        if (APP_TYPE == 3) {
            _tableView.estimatedRowHeight = 128;
        } else {
            _tableView.estimatedRowHeight = 145;
        }
        _tableView.estimatedSectionHeaderHeight = 60;
        _tableView.dataSource = self.cartViewModel;
        _tableView.delegate = self.cartViewModel;
//        _tableView.emptyDataSetDelegate = self.cartViewModel;
//        _tableView.emptyDataSetSource = self.cartViewModel;
        _tableView.hidden = YES;
        @weakify(self)
        
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self)
            [self requestDataShowLoading:NO];
        }];
        // 隐藏时间
        header.lastUpdatedTimeLabel.hidden = YES;

        // 隐藏状态
        header.stateLabel.hidden = YES;
        self.tableView.mj_header = header;
        
        self.tableView.emptyDataTitle    = STLLocalizedString_(@"cart_blank",nil);
        self.tableView.blankPageImageViewTopDistance = 40;
        self.tableView.isIgnoreHeaderOrFooter = YES;
        self.tableView.emptyDataImage = [UIImage imageNamed:@"cart_bank"];
        
        
    }
    return _tableView;
}

- (void)handleEmptyButton:(BOOL)hasTopSpace {
    
    CGFloat tableHeaderHeight = self.tableHeaderView.size.height;
    self.tableView.blankPageTipViewTopDistance = tableHeaderHeight;
    
    if ([OSSVAccountsManager sharedManager].isSignIn) {
        self.tableView.emptyDataBtnTitle = nil;
        self.tableView.blankPageViewActionBlcok = nil;
        
    } else {
        self.tableView.emptyDataBtnTitle = APP_TYPE == 3 ? STLLocalizedString_(@"Login/Register", nil) : STLLocalizedString_(@"Login/Register", nil).uppercaseString;
        @weakify(self)
        self.tableView.blankPageViewActionBlcok = ^(STLBlankPageViewStatus status) {
            @strongify(self)
            
            [OSSVAnalyticsTool analyticsGAEventWithName:@"Cart_action" parameters:@{
                   @"screen_group":@"Cart",
                   @"action":@"Login"}];
            
            if (![OSSVAccountsManager sharedManager].isSignIn) {
                SignViewController *sign = [SignViewController new];
                sign.modalPresentationStyle = UIModalPresentationFullScreen;
                sign.signBlock = ^{
                    
                };
                [self presentViewController:sign animated:YES completion:nil];
                
            }
        };
    }
}

- (OSSVCartSelectCodGoodsView *)selectCodGoodsView {
    if (!_selectCodGoodsView) {
        _selectCodGoodsView = [[OSSVCartSelectCodGoodsView alloc] initWithFrame:CGRectZero];
        _selectCodGoodsView.hidden = YES;
        @weakify(self)
        _selectCodGoodsView.operateBlock = ^{
            @strongify(self)
            [self tailorCodGoods];
        };
    }
    return _selectCodGoodsView;
}

- (OSSVCartBottomResultView *)bottomResultView {
    if (!_bottomResultView) {
        _bottomResultView = [[OSSVCartBottomResultView alloc] initWithFrame:CGRectZero];
        _bottomResultView.delegate = self.cartViewModel;
        self.cartViewModel.bottomView = _bottomResultView;
        _bottomResultView.hidden = YES;
    }
    return _bottomResultView;
}


- (UIView *)flashTipView {
    if (!_flashTipView) {
        _flashTipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        _flashTipView.backgroundColor = [OSSVThemesColors col_FFE9ED];
        _flashTipView.layer.cornerRadius = 6;
        _flashTipView.layer.masksToBounds = YES;
        _flashTipView.hidden = YES;
    }
    return _flashTipView;
}

- (UILabel *)flashTipLabel {
    if (!_flashTipLabel) {
        _flashTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _flashTipLabel.textColor = [OSSVThemesColors col_FF4E6A];
        _flashTipLabel.font = [UIFont systemFontOfSize:11];
        _flashTipLabel.numberOfLines = 2;
    }
    return _flashTipLabel;
}

- (OSSVTopSignInView *)topSignInView {
    if (!_topSignInView) {
        _topSignInView = [OSSVTopSignInView new];
        if (APP_TYPE == 3) {
            _topSignInView.backgroundColor = [OSSVThemesColors col_FF9318];
        } else {
            _topSignInView.backgroundColor = [OSSVThemesColors col_FFF3E4];
        }
        _topSignInView.hidden = YES;
        @weakify(self)
        _topSignInView.jumpIntoSignViewController = ^{
            @strongify(self)
            SignViewController *signVC = [SignViewController new];
            signVC.modalPresentationStyle = UIModalPresentationFullScreen;
            signVC.modalBlock = ^{
                [OSSVCommonnRequestsManager checkUpdateUserInfo:nil];
                [self.cartViewModel cartCheckOrderAddress:@""];
            };
            [self presentViewController:signVC animated:YES completion:nil];

        };
    }
    return _topSignInView;
}
@end
