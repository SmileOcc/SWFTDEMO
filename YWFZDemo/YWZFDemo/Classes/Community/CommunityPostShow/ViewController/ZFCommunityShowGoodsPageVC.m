//
//  ZFCommunityShowGoodsPageVC.m
//  ZZZZZ
//
//  Created by YW on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityShowGoodsPageVC.h"
#import "ZFCommunityShowHotVC.h"
#import "ZFCommunityShowWishlistVC.h"
#import "ZFCommunityShowBagVC.h"
#import "ZFCommunityShowOrderVC.h"
#import "ZFCommunityShowRecentVC.h"
#import "GoodListModel.h"
#import "ZFCommunityPostShowOrderListModel.h"
#import "ZFGoodsModel.h"
#import "ZFCommunityPostShowSelectGoodsModel.h"
#import "PostGoodsManager.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "Masonry.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFCommunityNavBarView.h"

static NSInteger const KMenuHeight = 44;

@interface ZFCommunityShowGoodsPageVC ()

@property (nonatomic, strong) ZFCommunityNavBarView      *showNavigationBar;
@property (nonatomic, strong) UIView                     *navTitleView;
@property (nonatomic, strong) UILabel                    *navTitleLable;;
@property (nonatomic, strong) UILabel                    *navTitleCountsLabel;



@property (nonatomic, strong) NSArray                    *pageArray;
@property (nonatomic, strong) NSMutableArray             *hotArray;
@property (nonatomic, strong) NSMutableArray             *wishArray;
@property (nonatomic, strong) NSMutableArray             *bagArray;
@property (nonatomic, strong) NSMutableArray             *orderArray;
@property (nonatomic, strong) NSMutableArray             *recentArray;
@property (nonatomic, strong) NSMutableArray             *selectArray;
@property (nonatomic, assign) BOOL                       isFirstTimeEnter;
@end

@implementation ZFCommunityShowGoodsPageVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - Life cycle

- (void)showParentController:(UIViewController *)parentViewController topGapHeight:(CGFloat)topGapHeight {
    
    dispatch_async(dispatch_get_main_queue(), ^{

        ZFCommunityShowPostTransitionDelegate *transitionDelegate = [[ZFCommunityShowPostTransitionDelegate alloc] init];
        self.modalTransitionStyle = UIModalPresentationCustom;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        self.transitionDelegate = transitionDelegate;
        self.transitioningDelegate = transitionDelegate;
        self.topGapHeight = topGapHeight;
        transitionDelegate.height = KScreenHeight - self.topGapHeight;
        
        if (parentViewController) {
            [parentViewController presentViewController:self animated:YES completion:nil];
        }
    });
}

- (instancetype)init {
    NSArray *viewControllers = @[
        [ZFCommunityShowOrderVC class],
        [ZFCommunityShowBagVC class],
        [ZFCommunityShowWishlistVC class],
        [ZFCommunityShowRecentVC class],
//        [ZFCommunityShowHotVC class],

    ];

    NSArray *titles = @[
        ZFLocalizedString(@"GoodsPage_VC_Order",nil),
        ZFLocalizedString(@"GoodsPage_VC_Bag",nil),
        ZFLocalizedString(@"GoodsPage_VC_WishList",nil),
        ZFLocalizedString(@"GoodsPage_VC_Recent",nil),
//        ZFLocalizedString(@"Post_Goods_Hot", nil),
    ];
    
    self = [super initWithViewControllerClasses:viewControllers andTheirTitles:titles];
    if (self) {
        self.menuViewStyle = WMMenuViewStyleLine;
        self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
        self.progressViewIsNaughty = YES;
        self.bounces = YES;
        self.pageAnimatable = YES;
        self.titleSizeNormal = 14;
        self.titleSizeSelected = 14;
        self.titleColorSelected = ZFCOLOR(51, 51, 51, 1);
        self.titleColorNormal = ZFCOLOR(153, 153, 153, 1);
        self.menuItemWidth = KScreenWidth / self.pageArray.count;
        self.progressWidth = KScreenWidth / self.pageArray.count;
        self.progressHeight = 2;
        
        self.hotArray = [PostGoodsManager sharedManager].hotArray;
        self.wishArray = [PostGoodsManager sharedManager].wishArray;
        self.bagArray = [PostGoodsManager sharedManager].bagArray;
        self.orderArray = [PostGoodsManager sharedManager].orderArray;
        self.recentArray = [PostGoodsManager sharedManager].recentArray;
        self.isFirstTimeEnter = [PostGoodsManager sharedManager].isFirstTimeEnter;
        
        NSDictionary *hotDict = @{@"selectArray":self.hotArray,
                                   @"wishArray":self.wishArray,
                                   @"bagArray":self.bagArray,
                                   @"orderArray":self.orderArray,
                                   @"recentArray":self.recentArray,
                                   @"isFirstTimeEnter":@(self.isFirstTimeEnter)
                                   };
        
        NSDictionary *wishDict = @{@"selectArray":self.wishArray,
                                   @"hotArray":self.hotArray,
                                   @"bagArray":self.bagArray,
                                   @"orderArray":self.orderArray,
                                   @"recentArray":self.recentArray
                                   };
        NSDictionary *bagDict = @{@"selectArray":self.bagArray,
                                   @"hotArray":self.hotArray,
                                   @"wishArray":self.wishArray,
                                   @"orderArray":self.orderArray,
                                   @"recentArray":self.recentArray
                                   };
        NSDictionary *orderDict = @{@"selectArray":self.orderArray,
                                    @"hotArray":self.hotArray,
                                  @"wishArray":self.wishArray,
                                  @"bagArray":self.bagArray,
                                  @"recentArray":self.recentArray
                                  };
        NSDictionary *recentDict = @{@"selectArray":self.recentArray,
                                     @"hotArray":self.hotArray,
                                    @"wishArray":self.wishArray,
                                    @"bagArray":self.bagArray,
                                    @"orderArray":self.orderArray
                                    };

//        self.values = @[hotDict, wishDict, bagDict, orderDict,recentDict].mutableCopy;
//        self.keys = @[@"hotDict", @"wishDict", @"bagDict",@"orderDict",@"recentDict"].mutableCopy;
        self.values = @[orderDict,bagDict, wishDict,recentDict].mutableCopy;
        self.keys = @[@"orderDict",@"bagDict",@"wishDict",@"recentDict"].mutableCopy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = ZFCClearColor();
    [self.view addSubview:self.showNavigationBar];
    
    [self.showNavigationBar addSubview:self.navTitleView];
    [self.navTitleView addSubview:self.navTitleLable];
    [self.navTitleView addSubview:self.navTitleCountsLabel];
    
    [self.navTitleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.showNavigationBar.mas_centerY);
        make.centerX.mas_equalTo(self.showNavigationBar.mas_centerX);
    }];
    
    [self.navTitleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.navTitleView.mas_leading);
        make.top.bottom.mas_equalTo(self.navTitleView);
    }];
    
    [self.navTitleCountsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.navTitleLable.mas_trailing);
        make.trailing.mas_equalTo(self.navTitleView.mas_trailing);
        make.centerY.mas_equalTo(self.navTitleView);
    }];

    
    [self reloadData];
//    [self setNavagationBarDefaultBackButton];
    [self updateNavagationBarDoneEnable:self.hasSelectGoods];
    @weakify(self)
    self.rightBarItemBlock = ^{
        @strongify(self)
        [self sendSelectGoods];
    };
    
    self.leftBarItemBlock = ^{
        //[[PostGoodsManager sharedManager] clearData];
    };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionGoodsCountChangeNotific:) name:kPostSelectGoodsCountNotification object:nil];
}

- (void)updateNavagationBarDoneEnable:(BOOL)hasSelect {
    UIColor *color = hasSelect ? ZFC0x2D2D2D() : ZFC0xCCCCCC();
    [self.showNavigationBar.confirmButton setTitleColor:color forState:UIControlStateNormal];
    self.showNavigationBar.confirmButton.enabled = hasSelect;
}

- (void)actionGoodsCountChangeNotific:(NSNotification *)notif {
    NSInteger count = [notif.object integerValue];
    BOOL enable = count > 0 ? YES : NO;
    [self updateNavagationBarDoneEnable:enable];
    self.navTitleCountsLabel.text = [NSString stringWithFormat:@"(%li/6)",(long)count];
}
#pragma mark - WMPageControllerDelegate
- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    menuView.backgroundColor = ZFC0xFFFFFF();
    return CGRectMake(0, CGRectGetHeight(self.showNavigationBar.frame), KScreenWidth, KMenuHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat originY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    return CGRectMake(0, originY, KScreenWidth, KScreenHeight - originY);
}

#pragma mark - DoneButton Action
- (void)sendSelectGoods {
    [PostGoodsManager sharedManager].hotArray = self.hotArray;
    [PostGoodsManager sharedManager].wishArray = self.wishArray;
    [PostGoodsManager sharedManager].bagArray = self.bagArray;
    [PostGoodsManager sharedManager].orderArray = self.orderArray;
    [PostGoodsManager sharedManager].recentArray = self.recentArray;
    
    [self.selectArray removeAllObjects];
    @autoreleasepool {
        
        [self.hotArray enumerateObjectsUsingBlock:^(ZFGoodsModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            ZFCommunityPostShowSelectGoodsModel *selectModel = [[ZFCommunityPostShowSelectGoodsModel alloc] init];
            selectModel.imageURL = model.wp_image;
            selectModel.goodsID = model.goods_id;
            selectModel.shop_price = model.shop_price;
            selectModel.goodsType = CommunityGoodsTypeHot;
            [self.selectArray addObject:selectModel];
        }];
        
        [self.wishArray enumerateObjectsUsingBlock:^(ZFGoodsModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            ZFCommunityPostShowSelectGoodsModel *selectModel = [[ZFCommunityPostShowSelectGoodsModel alloc] init];
            selectModel.imageURL = model.wp_image;
            selectModel.goodsID = model.goods_id;
            selectModel.shop_price = model.shop_price;
            selectModel.goodsType = CommunityGoodsTypeWish;
            [self.selectArray addObject:selectModel];
        }];
        
        [self.bagArray enumerateObjectsUsingBlock:^(GoodListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            ZFCommunityPostShowSelectGoodsModel *selectModel = [[ZFCommunityPostShowSelectGoodsModel alloc] init];
            selectModel.imageURL = model.goods_img;
            selectModel.goodsID = model.goods_id;
            selectModel.shop_price = model.shop_price;
            selectModel.goodsType = CommunityGoodsTypeBag;
            [self.selectArray addObject:selectModel];
        }];
        
        [self.orderArray enumerateObjectsUsingBlock:^(ZFCommunityPostShowOrderListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            ZFCommunityPostShowSelectGoodsModel *selectModel = [[ZFCommunityPostShowSelectGoodsModel alloc] init];
            selectModel.imageURL = model.goods_thumb;
            selectModel.goodsID = model.goods_id;
            selectModel.shop_price = model.shop_price;
            selectModel.goodsType = CommunityGoodsTypeOrder;
            [self.selectArray addObject:selectModel];
        }];
        
        [self.recentArray enumerateObjectsUsingBlock:^(ZFGoodsModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            ZFCommunityPostShowSelectGoodsModel *selectModel = [[ZFCommunityPostShowSelectGoodsModel alloc] init];
            selectModel.imageURL = model.wp_image;
            selectModel.goodsID = model.goods_id;
            selectModel.shop_price = model.shop_price;
            selectModel.goodsType = CommunityGoodsTypeRecent;
            [self.selectArray addObject:selectModel];
        }];
        if (self.doneBlock) {
            self.doneBlock(self.selectArray);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Setter/Getter
-(NSArray *)pageArray {
    if (!_pageArray) {
//        _pageArray = @[ZFLocalizedString(@"Post_Goods_Hot", nil),
//                       ZFLocalizedString(@"GoodsPage_VC_WishList",nil),
//                       ZFLocalizedString(@"GoodsPage_VC_Bag",nil),
//                       ZFLocalizedString(@"GoodsPage_VC_Order",nil),
//                       ZFLocalizedString(@"GoodsPage_VC_Recent",nil)];
        _pageArray = @[
            ZFLocalizedString(@"GoodsPage_VC_Order",nil),
            ZFLocalizedString(@"GoodsPage_VC_Bag",nil),
            ZFLocalizedString(@"GoodsPage_VC_WishList",nil),
            ZFLocalizedString(@"GoodsPage_VC_Recent",nil),
        ];
    }
    return _pageArray;
}

- (NSMutableArray *)hotArray {
    if (!_hotArray) {
        _hotArray = [NSMutableArray array];
    }
    return _hotArray;
}
-(NSMutableArray *)wishArray {
    if (!_wishArray) {
        _wishArray = [NSMutableArray array];
    }
    return _wishArray;
}

-(NSMutableArray *)bagArray {
    if (!_bagArray) {
        _bagArray = [NSMutableArray array];
    }
    return _bagArray;
}

-(NSMutableArray *)orderArray {
    if (!_orderArray) {
        _orderArray = [NSMutableArray array];
    }
    return _orderArray;
}

-(NSMutableArray *)recentArray {
    if (!_recentArray) {
        _recentArray = [NSMutableArray array];
    }
    return _recentArray;
}

-(NSMutableArray *)selectArray {
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}

- (ZFCommunityNavBarView *)showNavigationBar {
    if (!_showNavigationBar) {
        _showNavigationBar = [[ZFCommunityNavBarView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
        [_showNavigationBar zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(22, 22)];
        _showNavigationBar.backgroundColor = ZFC0xFFFFFF();
        [_showNavigationBar.confirmButton setTitle:ZFLocalizedString(@"GoodsPage_VC_Done",nil) forState:UIControlStateNormal];
        _showNavigationBar.confirmButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        
        @weakify(self)
        _showNavigationBar.closeBlock = ^(BOOL flag) {
            @strongify(self)
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        _showNavigationBar.confirmBlock = ^(BOOL flag) {
            @strongify(self)
            [self sendSelectGoods];
        };
    }
    return _showNavigationBar;
}

- (UIView *)navTitleView {
    if (!_navTitleView) {
        _navTitleView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _navTitleView;
}

- (UILabel *)navTitleLable {
    if (!_navTitleLable) {
        _navTitleLable = [[UILabel alloc] initWithFrame:CGRectZero];
        _navTitleLable.textColor = ZFC0x2D2D2D();
        _navTitleLable.font = [UIFont systemFontOfSize:18];
        _navTitleLable.text = ZFLocalizedString(@"Post_VC_Post_AddItems", nil);
    }
    return _navTitleLable;
}

- (UILabel *)navTitleCountsLabel {
    if (!_navTitleCountsLabel) {
        _navTitleCountsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _navTitleCountsLabel.textColor = ZFC0x2D2D2D();
        _navTitleCountsLabel.font = [UIFont systemFontOfSize:14];
    }
    return _navTitleCountsLabel;
}

@end
