//
//  OSSVWMCouponVC.m
// XStarlinkProject
//
//  Created by 10010 on 2017/9/20.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//  个人中心， 我的优惠券

#import "OSSVWMCouponVC.h"
#import "OSSVMyCouponsItemVC.h"
/*优惠券提示框*/
#import "STLAlertView.h"
#import "Adorawe-Swift.h"

@interface OSSVWMCouponVC ()<UIAlertViewDelegate>
@property (nonatomic, strong) NSArray       *titleArray;
@property (nonatomic, strong) UIButton      *couponBtn;
@property (nonatomic, strong) UIView        *panBackView;

@end

@implementation OSSVWMCouponVC

- (void)dealloc {
    STLLog(@"-------  OSSVWMCouponVC dealloc");
}
- (instancetype)init {
    if (self = [super init]) {
        self.pageAnimatable = YES;
//        self.menuHeight = 40;
        self.showOnNavigationBar = NO;
        self.postNotification = YES;
        self.bounces = YES;
        self.titleSizeNormal = 16;
        self.titleSizeSelected = 16;
        self.menuViewStyle = WMMenuViewStyleLine;
        self.itemMargin = 0;
        self.menuItemWidth = SCREEN_WIDTH/3;
        self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
        self.titleColorSelected = [OSSVThemesColors col_0D0D0D];
        self.titleColorNormal = [OSSVThemesColors col_6C6C6C];
        self.progressColor = [OSSVThemesColors col_0D0D0D];
        self.progressViewBottomSpace = 8;
        self.scrollView.backgroundColor = [OSSVThemesColors col_F5F5F5];
        self.menuView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            self.titleFontName = @"Almarai-Bold";
        } else {
            self.titleFontName = @"Lato-Bold";
        }
        
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        
        [self.titleArray enumerateObjectsUsingBlock:^(NSString *  _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
            
            UIFont *titleFont = [UIFont fontWithName:self.titleFontName size:16];
            NSDictionary *attrs = @{NSFontAttributeName: titleFont};
            CGFloat itemWidth = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attrs context:nil].size.width /* + 20*/;;
            NSString *itemWidthStr = [NSString stringWithFormat:@"%.2f",ceil(itemWidth)];
            [arr addObject:itemWidthStr];
        }];
        
        self.progressViewWidths = arr;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"myCoupons",nil);
    
    self.view.backgroundColor = [OSSVThemesColors col_F5F5F5];
    //需要更新文案
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.couponBtn];
    
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
    self.menuView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    [self.view addSubview:self.panBackView];
    [self.panBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.bottom.mas_equalTo(self.view);
        make.width.mas_equalTo(12);
    }];

}
//点击？图标
- (void)touchCoupon:(UIButton*)sender {
    [GATools logCouponPageEventWithAction:@"Application"];
    [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:[NSString couponUseDesc] buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"confirm",nil)]: @[STLLocalizedString_(@"confirm",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
        
    }];
}

#pragma mark - WMPageControllerDataSource

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    
    return CGRectMake(0, 0, SCREEN_WIDTH, 40);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    self.scrollView.backgroundColor = [OSSVThemesColors col_F5F5F5];
    self.menuView.backgroundColor = [OSSVThemesColors stlWhiteColor];
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
    OSSVMyCouponsItemVC *vc = [[OSSVMyCouponsItemVC alloc] init];
    switch (index) {
        case 0:
            vc.identifier = @"unused";
            break;
        case 1:
            vc.identifier = @"expired";
            break;
        default:
            vc.identifier = @"used";
            break;
    }
    return vc;
}

- (void)pageController:(WMPageController *)pageController didEnterViewController:(__kindof UIViewController *)viewController withInfo:(NSDictionary *)info {
    if ([viewController isKindOfClass:OSSVMyCouponsItemVC.class]) {
        [GATools logCouponPageEventWithAction:((OSSVMyCouponsItemVC *)viewController).identifier];
    }
}

#pragma mark - LazyLoad

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[[STLLocalizedString_(@"unused",nil) capitalizedString],
                        [STLLocalizedString_(@"expired",nil) capitalizedString],
                        [STLLocalizedString_(@"used",nil) capitalizedString]];
    }
    return _titleArray;
}

- (UIButton *)couponBtn {
    if (!_couponBtn) {
        _couponBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _couponBtn.frame = CGRectMake(0, 0, 24, 24);
        [_couponBtn setImage:[UIImage imageNamed:@"help_Black_24"] forState:UIControlStateNormal];
        [_couponBtn addTarget:self action:@selector(touchCoupon:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _couponBtn;
}

- (UIView *)panBackView {
    if (!_panBackView) {
        _panBackView = [[UIView alloc] initWithFrame:CGRectZero];
        _panBackView.backgroundColor = [OSSVThemesColors stlClearColor];
    }
    return _panBackView;
}
@end
