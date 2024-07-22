//
//  ZFOutfitGoodsPageViewController.m
//  Zaful
//
//  Created by TsangFa on 16/11/28.
//  Copyright © 2016年 Y001. All rights reserved.
//

#import "ZFCommunityShowGoodsPageVC.h"
#import "ZFOutfitCommunityShowHotVC.h"
#import "ZFOutfitWishlistViewController.h"
#import "ZFCommunityShowBagVC.h"
#import "ZFOutfitOrderViewController.h"
#import "ZFOutfitRecentViewController.h"
#import "GoodListModel.h"
#import "PostOrderListModel.h"
#import "ZFGoodsModel.h"
#import "SelectGoodsModel.h"
#import "PostGoodsManager.h"

static NSInteger const KMenuHeight = 44;

@interface ZFCommunityShowGoodsPageVC ()

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
- (instancetype)init {
    NSArray *viewControllers = @[[ZFOutfitCommunityShowHotVC class],
                                 [ZFOutfitWishlistViewController class],
                                 [ZFCommunityShowBagVC class],
                                 [ZFOutfitOrderViewController class],
                                 [ZFOutfitRecentViewController class]];

    NSArray *titles = @[ZFLocalizedString(@"Post_Goods_Hot", nil),
                        ZFLocalizedString(@"GoodsPage_VC_WishList",nil),
                        ZFLocalizedString(@"GoodsPage_VC_Bag",nil),
                        ZFLocalizedString(@"GoodsPage_VC_Order",nil),
                        ZFLocalizedString(@"GoodsPage_VC_Recent",nil)];
    
    self = [super initWithViewControllerClasses:viewControllers andTheirTitles:titles];
    if (self) {
        self.menuViewStyle = WMMenuViewStyleLine;
        self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
        self.progressViewIsNaughty = YES;
        self.bounces = YES;
        self.pageAnimatable = YES;
        self.titleSizeNormal = 15;
        self.titleSizeSelected = 16;
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

        self.values = @[hotDict, wishDict, bagDict, orderDict,recentDict].mutableCopy;
        self.keys = @[@"hotDict", @"wishDict", @"bagDict",@"orderDict",@"recentDict"].mutableCopy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadData];
    [self setNavagationBarDefaultBackButton];
    [self createNavagationBarRight:self.hasSelectGoods];
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

- (void)createNavagationBarRight:(BOOL)hasSelect {
    
    UIColor *color = hasSelect ? ZFCOLOR(255, 168, 0, 1) : [UIColor grayColor];
    BOOL enable = hasSelect;
    [self setNavagationBarRightButtonWithTitle:ZFLocalizedString(@"GoodsPage_VC_Done",nil)
                                          font:[UIFont systemFontOfSize:18]
                                         color:color
                                       enabled:enable];
}
- (void)actionGoodsCountChangeNotific:(NSNotification *)notif {
    NSInteger count = [notif.object integerValue];
    BOOL enable = count > 0 ? YES : NO;
    [self createNavagationBarRight:enable];
}
#pragma mark - WMPageControllerDelegate
- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    menuView.backgroundColor = ZFCOLOR(245, 245, 245, 1);;
    return CGRectMake(0, 0, KScreenWidth, KMenuHeight);
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
            SelectGoodsModel *selectModel = [[SelectGoodsModel alloc] init];
            selectModel.imageURL = model.wp_image;
            selectModel.goodsID = model.goods_id;
            selectModel.goodsType = CommunityGoodsTypeHot;
            [self.selectArray addObject:selectModel];
        }];
        
        [self.wishArray enumerateObjectsUsingBlock:^(ZFGoodsModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            SelectGoodsModel *selectModel = [[SelectGoodsModel alloc] init];
            selectModel.imageURL = model.wp_image;
            selectModel.goodsID = model.goods_id;
            selectModel.goodsType = CommunityGoodsTypeWish;
            [self.selectArray addObject:selectModel];
        }];
        
        [self.bagArray enumerateObjectsUsingBlock:^(GoodListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            SelectGoodsModel *selectModel = [[SelectGoodsModel alloc] init];
            selectModel.imageURL = model.goods_img;
            selectModel.goodsID = model.goods_id;
            selectModel.goodsType = CommunityGoodsTypeBag;
            [self.selectArray addObject:selectModel];
        }];
        
        [self.orderArray enumerateObjectsUsingBlock:^(PostOrderListModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            SelectGoodsModel *selectModel = [[SelectGoodsModel alloc] init];
            selectModel.imageURL = model.goods_thumb;
            selectModel.goodsID = model.goods_id;
            selectModel.goodsType = CommunityGoodsTypeOrder;
            [self.selectArray addObject:selectModel];
        }];
        
        [self.recentArray enumerateObjectsUsingBlock:^(ZFGoodsModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            SelectGoodsModel *selectModel = [[SelectGoodsModel alloc] init];
            selectModel.imageURL = model.wp_image;
            selectModel.goodsID = model.goods_id;
            selectModel.goodsType = CommunityGoodsTypeRecent;
            [self.selectArray addObject:selectModel];
        }];
        if (self.doneBlock) {
            self.doneBlock(self.selectArray);
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - Setter/Getter
-(NSArray *)pageArray {
    if (!_pageArray) {
        _pageArray = @[ZFLocalizedString(@"Post_Goods_Hot", nil),
                       ZFLocalizedString(@"GoodsPage_VC_WishList",nil),
                       ZFLocalizedString(@"GoodsPage_VC_Bag",nil),
                       ZFLocalizedString(@"GoodsPage_VC_Order",nil),
                       ZFLocalizedString(@"GoodsPage_VC_Recent",nil)];
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

@end
