//
//  CouponViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/6/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "CouponViewController.h"
#import "CouponItemViewController.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFFrameDefiner.h"
#import "UIView+LayoutMethods.h"

@implementation CouponViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = ZFLocalizedString(@"MyCoupon_VC_Title",nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] init];
    
    //添加一个透明视图让事件传递到顶层,使其能够侧滑返回
    [self shouldShowLeftHoledSliderView:self.view.height];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (instancetype)init {
    if (self = [super init]) {
        NSArray *viewControllers = @[[CouponItemViewController class],
                                     [CouponItemViewController class],
                                     [CouponItemViewController class]];
        
        NSArray *titles = @[ZFLocalizedString(@"MyCoupon_Coupon_Unused",nil),
                            ZFLocalizedString(@"MyCoupon_Coupon_Used",nil),
                            ZFLocalizedString(@"MyCoupon_Coupon_Expired",nil)];

        self.viewControllerClasses = viewControllers;
        self.keys = @[@"kind",@"kind",@"kind"].mutableCopy;
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            titles = @[ ZFLocalizedString(@"MyCoupon_Coupon_Expired",nil),
                        ZFLocalizedString(@"MyCoupon_Coupon_Used",nil),
                        ZFLocalizedString(@"MyCoupon_Coupon_Unused",nil)];
            
            self.values = @[@"3",@"2",@"1"].mutableCopy;
            self.selectIndex = (int)titles.count - 1;
        } else {
            self.values = @[@"1",@"2",@"3"].mutableCopy;
            self.selectIndex = 0;
        }
        self.titles = titles;
        
        self.pageAnimatable                    = YES;
        self.postNotification                  = YES;
        self.bounces                           = YES;
        self.titleSizeNormal                   = 14;
        self.titleSizeSelected                 = 14;
        self.automaticallyCalculatesItemWidths = YES;
        self.menuViewStyle                     = WMMenuViewStyleLine;
        self.menuViewLayoutMode                = WMMenuViewLayoutModeScatter;
        
        self.titleColorSelected = ZFC0x2D2D2D();
        self.titleColorNormal = ZFCOLOR(153, 153, 153, 1.0);
        self.progressColor = ZFC0x2D2D2D();
        self.progressHeight = 2;
    }
    return self;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    menuView.backgroundColor = ZFCOLOR_WHITE;
    return CGRectMake(0, 0, KScreenWidth, 44);
    
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat originY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    return CGRectMake(0, originY, KScreenWidth, KScreenHeight - originY - NAVBARHEIGHT - STATUSHEIGHT);
}

@end
