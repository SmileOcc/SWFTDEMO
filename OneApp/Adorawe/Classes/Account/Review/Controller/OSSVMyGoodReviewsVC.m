//
//  OSSVMyGoodReviewsVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMyGoodReviewsVC.h"
#import "OSSVMyGoodReviewItemsVC.h"
#import "Adorawe-Swift.h"

@interface OSSVMyGoodReviewsVC ()<STLMyGoodsReviewItemCtrlDelegate>

@property (nonatomic, strong) NSArray       *titleArray;

@property (nonatomic, strong) NSArray       *viewCtrlsArray;

@property (nonatomic, strong) UIView         *panBackView;

@end

@implementation OSSVMyGoodReviewsVC



- (instancetype)init {
    if (self = [super init]) {
        self.pageAnimatable = YES;
//        self.menuHeight = 40;
        self.showOnNavigationBar = NO;
        self.postNotification = YES;
        self.bounces = YES;
        self.titleSizeNormal = 16;
        self.titleSizeSelected = 16;
        //self.progressWidth = 80;
        self.menuViewStyle = WMMenuViewStyleLine;
        
        UILabel *temp = [[UILabel alloc] init];
        temp.font = [UIFont boldSystemFontOfSize:16];
        CGFloat width = 0;
        for (NSString *title in self.titleArray) {
            temp.text = title;
            width += [temp sizeThatFits:CGSizeMake(MAXFLOAT, 18)].width;
        }
        width = (SCREEN_WIDTH - width) / 3;
        self.itemMargin = width;
//        self.menuItemWidth = SCREEN_WIDTH/2;
        self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
        self.automaticallyCalculatesItemWidths = YES;
        self.titleColorSelected = [OSSVThemesColors col_0D0D0D];
        self.titleColorNormal = [OSSVThemesColors col_6C6C6C];
        self.progressColor = [OSSVThemesColors col_0D0D0D];
        self.progressViewBottomSpace = 6;
//        self.menuBGColor = OSSVThemesColors.col_FFFFFF;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            self.titleFontName = @"Almarai-Bold";
        } else {
            self.titleFontName = @"Lato-Bold";
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = STLLocalizedString_(@"My_Reviews",nil);
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        self.menuView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        self.scrollView.transform = CGAffineTransformMakeScale(-1.0,1.0);
        NSArray *subMenuViews = self.menuView.scrollView.subviews;
        for (UIView *subView in subMenuViews) {
            if ([subView isKindOfClass:[WMMenuItem class]]) {
                subView.transform = CGAffineTransformMakeScale(-1.0,1.0);
            }
        }
    }
    
    [self.view addSubview:self.panBackView];
    [self.panBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.mas_equalTo(self.view);
        make.width.mas_equalTo(12);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - WMPageControllerDataSource

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, 0, SCREEN_WIDTH, 44);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    
    CGFloat menuMaxY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    return CGRectMake(0, menuMaxY, SCREEN_WIDTH, SCREEN_HEIGHT - menuMaxY - self.tabBarController.tabBar.bounds.size.height);
}

- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.titleArray.count;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return self.titleArray[index];
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    if (self.viewCtrlsArray.count > index) {
        return self.viewCtrlsArray[index];
    }
    return [UIViewController new];
}

- (void)pageController:(WMPageController *)pageController willEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info{
    NSInteger index = [[info objectForKey:@"index"] integerValue];
    NSString *status = @"";
    if (index == 0) {
        status = @"Reviewed";
    }else{
        status = @"WaitingForReview";
    }
    [GATools logReviewsWithAction:@"Reviews Status" content:[NSString stringWithFormat:@"Status_%@",status]];
}

#pragma mark - STL_MyGoodsReviewItemViewControllerDelegate

- (void)STL_MyGoodsReviewItemViewController:(OSSVMyGoodReviewItemsVC *)goodsReviewController refresh:(BOOL)refresh {

    if (goodsReviewController.type == 0) {
        OSSVMyGoodReviewItemsVC *reviewedCtrl = self.viewCtrlsArray[1];
        [reviewedCtrl refreshData];
    }
}

#pragma mark - LazyLoad

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[STLLocalizedString_(@"Waiting_for_review",nil),
                        STLLocalizedString_(@"Reviewed",nil)];
    }
    return _titleArray;
}

- (NSArray *)viewCtrlsArray {
    if (!_viewCtrlsArray) {
        
        OSSVMyGoodReviewItemsVC *vc1 = [[OSSVMyGoodReviewItemsVC alloc] init];
        vc1.type = 0;
        vc1.myDelegate = self;
        OSSVMyGoodReviewItemsVC *vc2 = [[OSSVMyGoodReviewItemsVC alloc] init];
        vc2.type = 1;
        vc2.myDelegate = self;
        _viewCtrlsArray = @[vc1,vc2];
    }
    return _viewCtrlsArray;
}

- (UIView *)panBackView {
    if (!_panBackView) {
        _panBackView = [[UIView alloc] initWithFrame:CGRectZero];
        _panBackView.backgroundColor = [OSSVThemesColors stlClearColor];
    }
    return _panBackView;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.scrollView.backgroundColor = OSSVThemesColors.col_F5F5F5;
}
@end
