//
//  ZFCommentListViewController.m
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommentListViewController.h"
#import "ZFWaitCommentSubVC.h"
#import "ZFMyCommentSubVC.h"

#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "UIView+LayoutMethods.h"
#import "ZFThemeManager.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"

@interface ZFCommentListViewController()
@property (nonatomic, copy) NSString *firstMenuTitle;
@property (nonatomic, copy) NSString *secondMenuTitle;
@end

@implementation ZFCommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFLocalizedString(@"GoodsReviews_VC_Title",nil);
    
    //添加一个透明视图让事件传递到顶层,使其能够侧滑返回
    [self shouldShowLeftHoledSliderView:self.view.height];
    
    [self arMenuViewHandle];
}

- (instancetype)init {
    if (self = [super init]) {
        self.viewControllerClasses = @[
            [ZFWaitCommentSubVC class],
            [ZFMyCommentSubVC class],
        ];
        self.keys = @[@"kind",@"kind",@"kind"].mutableCopy;
        self.titles = @[
            ZFLocalizedString(@"Order_Awaiting_Comment",nil),
            ZFLocalizedString(@"Order_My_Comment",nil)
        ];
        self.pageAnimatable                     = YES;
        self.postNotification                   = YES;
        self.bounces                            = YES;
        self.menuItemWidth                      = KScreenWidth/2.0;
        self.titleSizeNormal                    = 14;
        self.titleSizeSelected                  = 14;
//        self.automaticallyCalculatesItemWidths  = YES;
        self.menuViewStyle                      = WMMenuViewStyleLine;
        self.menuViewLayoutMode                 = WMMenuViewLayoutModeScatter;
        self.preloadPolicy                      = WMPageControllerPreloadPolicyNeighbour;
        self.titleColorSelected                 = ZFC0x2D2D2D();
        self.titleColorNormal                   = ZFCOLOR(153, 153, 153, 1.0);
        self.progressColor                      = ZFC0x2D2D2D();
        self.progressHeight                     = 2;
    }
    return self;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    menuView.backgroundColor = ZFCOLOR_WHITE;
    return CGRectMake(0, 0, KScreenWidth, 48);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat originY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    CGFloat height = KScreenHeight - originY - NAVBARHEIGHT - STATUSHEIGHT;
    return CGRectMake(0, originY, KScreenWidth, height);
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index
{
    if (index == 0) {
        ZFWaitCommentSubVC *waitCommentVC = [[ZFWaitCommentSubVC alloc] init];
        @weakify(self)
        waitCommentVC.waitCommentCountBlock = ^(NSString *title) {
            @strongify(self)
            [self updatePageTitle:title atIndex:index];
        };
        return waitCommentVC;
    } else {
        ZFMyCommentSubVC *myCommentVC = [[ZFMyCommentSubVC alloc] init];
        @weakify(self)
        myCommentVC.myCommentCountBlock = ^(NSString *title) {
            @strongify(self)
            [self updatePageTitle:title atIndex:index];
        };
        return myCommentVC;
    }
}

- (void)updatePageTitle:(NSString *)title atIndex:(NSUInteger)index {
    [self.menuView updateTitle:title atIndex:index andWidth:NO];
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
}


@end
