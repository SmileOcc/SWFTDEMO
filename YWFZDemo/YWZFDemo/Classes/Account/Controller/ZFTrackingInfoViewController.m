//
//  ZFTrackingInfoViewController.m
//  ZZZZZ
//
//  Created by Tsang_Fa on 2017/9/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFTrackingInfoViewController.h"
#import "ZFTrackingPackageViewController.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"

@implementation ZFTrackingInfoViewController

#pragma mark - Life cycle
- (instancetype)init {
    if (self = [super init]) {
        self.pageAnimatable = YES;
        self.bounces = YES;
        self.titleSizeNormal = 14;
        self.titleSizeSelected = 14;
        self.menuViewStyle = WMMenuViewStyleLine;
        self.menuViewLayoutMode = WMMenuViewLayoutModeScatter;
        self.automaticallyCalculatesItemWidths = YES;
        self.titleColorSelected = ZFCOLOR(183, 96, 42, 1.0);
        self.titleColorNormal = ZFCOLOR(153, 153, 153, 1.0);
        self.progressColor = ZFCOLOR(183, 96, 42, 1.0);
        self.progressHeight = 2;
    }
    
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    /**
     *  此方法是为了防止控制器的title发生偏移，造成这样的原因是因为返回按钮的文字描述占位
     */
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    
    if ([viewControllerArray containsObject:self]) {
        long previousViewControllerIndex = [viewControllerArray indexOfObject:self] - 1;
        UIViewController *previous;
        if (previousViewControllerIndex >= 0) {
            previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
            previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                         initWithTitle:@"" style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:nil];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = ZFLocalizedString(@"ZFTracking_information_title", nil);
}

#pragma mark - WMPageControllerDataSource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.packages.count;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    ZFTrackingPackageViewController *packageVC =  [[ZFTrackingPackageViewController alloc] init];
    if (self.packages.count > index) {
        packageVC.model = self.packages[index];
    }
    return packageVC;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    return [NSString stringWithFormat:ZFLocalizedString(@"ZFPackage", nil),index + 1];
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    menuView.backgroundColor = ZFCOLOR_WHITE;
    CGFloat height = 44;
    if (self.packages.count == 1) {
        height = 0;
    }
    return CGRectMake(0, 0, KScreenWidth, height);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat originY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    return CGRectMake(0, originY, KScreenWidth, KScreenHeight - originY);
}

@end
