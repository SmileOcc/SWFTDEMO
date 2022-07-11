//
//  OSSVAccountOrdersPageVC.m
// XStarlinkProject
//
//  Created by odd on 2020/12/9.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVAccountOrdersPageVC.h"
#import "STLMyGoodsReviewCtrl.h"
#import "OSSVAccountsMyOrderVC.h"
#import "OSSVMyHelpVC.h"
#import "STLOrderMenuItemModel.h"

@interface OSSVAccountOrdersPageVC ()

@property (nonatomic, strong) NSArray                  *menuTitlesArray;
@property (nonatomic, strong) UIView                   *menuLineView;
@property (nonatomic, strong) UIView                   *panBackView;

@end

@implementation OSSVAccountOrdersPageVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        self.pageAnimatable = NO;
//        self.menuHeight = 40;
//        self.showOnNavigationBar = YES;
        self.postNotification = YES;
        self.bounces = YES;
        self.titleSizeNormal = 16;
        self.titleSizeSelected = 16;
        if ([SystemConfigUtils isCustomizeFontLanguageAR]) {
            self.titleFontName = @"Almarai-Bold";
        } else {
            self.titleFontName = @"Lato-Bold";
        }

        self.menuViewStyle = WMMenuViewStyleLine;
        self.itemMargin = 24;
//        self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
        self.automaticallyCalculatesItemWidths = YES;
        self.titleColorSelected = STLThemeColor.col_0D0D0D;
        self.titleColorNormal = STLThemeColor.col_666666;
        self.progressColor = [STLThemeColor col_0D0D0D];
        self.progressViewBottomSpace = 10;
//        self.menuBGColor = [UIColor clearColor];;
//        self.viewFrame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - kTabHeight - 40 - 20 - kIPHONEX_TOP_SPACE);
        
        self.menuView.backgroundColor = [STLThemeColor stlWhiteColor];
        self.scrollView.backgroundColor = [STLThemeColor col_F5F5F5];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"My_Orders",nil);
    UIButton *helpButton = [[UIButton alloc] init];
    [helpButton setImage:[UIImage imageNamed:@"chat_new"] forState:UIControlStateNormal];
    [helpButton addTarget:self action:@selector(clickButtonAction) forControlEvents:UIControlEventTouchUpInside];
    helpButton.imageView.contentMode = UIViewContentModeCenter;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:helpButton];

    [self arMenuViewHandle];
    
    [self.view addSubview:self.panBackView];
    [self.panBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.mas_equalTo(self.view);
        make.width.mas_equalTo(12);
    }];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(switchToAllordertab:) name:@"SwitchToAllOrdertab" object:nil];
}
- (void)clickButtonAction {

    OSSVMyHelpVC *helpVC = [[OSSVMyHelpVC alloc] init];
    [self.navigationController pushViewController:helpVC animated:YES];
    
}

-(void)switchToAllordertab:(NSNotification *)notif{
    self.choiceIndex = @"";
    if( [self.childViewControllers.firstObject isKindOfClass:OSSVAccountsMyOrderVC.class]){
        OSSVAccountsMyOrderVC *vc = self.childViewControllers.firstObject;
        [vc.tableView.mj_header beginRefreshing];
    }
}


- (void)setChoiceIndex:(NSString *)choiceIndex {
    _choiceIndex = choiceIndex;
    if (STLIsEmptyString(choiceIndex)) {
        self.selectIndex = 0;
    } else {
        self.selectIndex = [choiceIndex intValue];
    }
}
//occ阿语适配
- (void)arMenuViewHandle {
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.menuView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        self.scrollView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        
        NSArray *subMenuViews = self.menuView.scrollView.subviews;
        for (UIView *subView in subMenuViews) {
            if ([subView isKindOfClass:[WMMenuItem class]]) {
                subView.transform = CGAffineTransformMakeScale(-1.0,1.0);
            }
        }
    }
    
    self.menuLineView = [[UIView alloc] initWithFrame:CGRectZero];
    self.menuLineView.backgroundColor = [STLThemeColor col_EEEEEE];
    self.menuView.backgroundColor = [STLThemeColor stlWhiteColor];
    
    if (self.menuView) {
        [self.menuView addSubview:self.menuLineView];
        [self.menuLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.bottom.trailing.mas_equalTo(self.menuView);
            make.height.mas_equalTo(0.5);
        }];
    }
}

- (NSArray *)menuTitlesArray {
    if (!_menuTitlesArray) {
        NSString *allOrder   = STLLocalizedString_(@"allOrder",nil);
        NSString *unpaid     = STLLocalizedString_(@"Unpaid",nil);
        NSString *processing = STLLocalizedString_(@"Processing",nil);
        NSString *shipped    = STLLocalizedString_(@"Shipped",nil);
        NSString *review     = STLLocalizedString_(@"Reviewed",nil);

        NSArray *tempArray = @[allOrder, unpaid, processing, shipped, review];
        NSMutableArray *mutArray = [[NSMutableArray alloc] init];
        for (int i=0; i<tempArray.count; i++) {
            STLOrderMenuItemModel *itemModel = [[STLOrderMenuItemModel alloc] init];
            itemModel.title = tempArray[i];
            itemModel.index = [NSString stringWithFormat:@"%i",i-1];
            if (i==0) {
                itemModel.index = @"";
            }else if(i == 1) {
                itemModel.index = @"0";
            } else if(i == 2) {
                itemModel.index = @"2";
            } else if(i == 3) {
                itemModel.index = @"3";
            } else if(i == 4) {
                itemModel.index = @"4";
            }
            [mutArray addObject:itemModel];
        }
        _menuTitlesArray = [[NSMutableArray alloc] initWithArray:mutArray];
    }
    return _menuTitlesArray;
}

- (UIView *)panBackView {
    if (!_panBackView) {
        _panBackView = [[UIView alloc] initWithFrame:CGRectZero];
        _panBackView.backgroundColor = [STLThemeColor stlClearColor];
    }
    return _panBackView;
}

#pragma mark - WMPageControllerDataSource

- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.menuTitlesArray.count;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    
    if (self.menuTitlesArray.count > index) {
        STLOrderMenuItemModel *item = self.menuTitlesArray[index];
        return STLToString(item.title);
    }
    return @"";
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    
    STLOrderMenuItemModel *item;
    if (self.menuTitlesArray.count > index) {
        item = self.menuTitlesArray[index];
    }
    
    //status参数:默认为0)[0-未付款，1-已支付，2-备货，3-已完全发货，4-已取消]
    NSString *status = STLToString(item.index);
    OSSVAccountsMyOrderVC *orderVC = [[OSSVAccountsMyOrderVC alloc] init];
    orderVC.status = status;
    orderVC.orderTitle = STLToString(item.title);
    orderVC.isNeedTransform = YES;
    
    if (index == 0) {
        orderVC.codOrderAddressModel = self.codOrderAddressModel;
        orderVC.isConcelCodEnter = self.isConcelCodEnter;
    }

    return orderVC;
}
//当viewController完全显示时调用 --info包含了（index， title）
- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    NSInteger index = [info[@"index"] integerValue];
    if (self.menuTitlesArray.count > index) {
        STLOrderMenuItemModel *item = self.menuTitlesArray[index];
        
        [STLAnalytics analyticsGAEventWithName:@"order_action" parameters:@{
            @"screen_group":@"MyOrder",
            @"action":[NSString stringWithFormat:@"Status_%@",STLToString(item.index)]}];
    }
    STLLog(@"%@",info);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    CGFloat menuHeight = self.menuTitlesArray.count == 1 ? 0.0f : 44;
    return CGRectMake(0, 0, SCREEN_WIDTH, menuHeight);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    
    self.menuView.backgroundColor = [STLThemeColor stlWhiteColor];
    self.scrollView.backgroundColor = [STLThemeColor col_F5F5F5];
    CGFloat menuMaxY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    return CGRectMake(0, menuMaxY, SCREEN_WIDTH, SCREEN_HEIGHT - menuMaxY - kNavHeight);
}


@end
