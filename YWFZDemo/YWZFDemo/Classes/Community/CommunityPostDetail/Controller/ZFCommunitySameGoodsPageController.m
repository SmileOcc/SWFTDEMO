//
//  ZFCommunitySameGoodsPageController.m
//  ZZZZZ
//
//  Created by YW on 2018/6/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunitySameGoodsPageController.h"
#import "ZFCommunityPostSameGoodsViewModel.h"
#import "ZFListGoodsNumberHeaderView.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFCommunitySameGoodsPageItemVC.h"
#import "ZFCommunityGoodsInfosModel.h"
#import "ZFThemeManager.h"
#import "ZFProgressHUD.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"

@interface ZFCommunitySameGoodsPageController ()
@property (nonatomic, strong) ZFCommunityPostSameGoodsViewModel                   *viewModel;
@property (nonatomic, copy) NSString                                    *reviewID;
@property (nonatomic, strong) NSArray<ZFCommuitySameGoodsCatModel *>    *tagLabelArray;
@end

@implementation ZFCommunitySameGoodsPageController

- (instancetype)initWithReviewID:(NSString *)reviewID {
    if (self = [super init]) {
        self.reviewID = reviewID;
        self.titleSizeNormal    = 14.0f;
        self.titleSizeSelected  = 14.0f;
        self.menuViewStyle      = WMMenuViewStyleLine;
        self.itemMargin         = 20.0f;
        self.titleColorSelected = ColorHex_Alpha(0x2D2D2D, 1);
        self.titleColorNormal   = ColorHex_Alpha(0x999999, 1);
        self.progressColor      = ColorHex_Alpha(0x2D2D2D, 1);
        self.progressHeight     = 2.0f;
        self.automaticallyCalculatesItemWidths = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = ZFLocalizedString(@"Community_post_all_Items", nil);
    self.viewModel = [[ZFCommunityPostSameGoodsViewModel alloc] init];
    //获取第一页数据的标签数组
    [self requestSameGoodsData:YES];
    
    //添加一个透明视图让事件传递到顶层,使其能够侧滑返回
    [self shouldShowLeftHoledSliderView:KScreenHeight - kiphoneXTopOffsetY - 44];
}

#pragma mark - 网络请求
- (void)requestSameGoodsData:(BOOL)isFirstpage {
    ShowLoadingToView(self.view);
    
    @weakify(self)
    [ZFCommunityPostSameGoodsViewModel requesttagLabelReviewID:self.reviewID
                                     finishedHandle:^(NSArray *tagDataArray){
                                         @strongify(self)
                                         HideLoadingFromView(self.view);
                                         
                                         if (tagDataArray.count == 0) {
                                             [self showAgainRequestView];
                                         } else {
                                             self.tagLabelArray = tagDataArray;
                                             [self reloadData];
                                             UIView *line = [self.menuView addLineToPosition:(ZFDrawLine_bottom) lineWidth:MIN_PIXEL];
                                             line.backgroundColor = ColorHex_Alpha(0xDDDDDD, 1);;
                                         }
                                     }];
}

#pragma mark - privete method
- (void)showAgainRequestView {
    @weakify(self)
    self.emptyImage = [UIImage imageNamed:@"blankPage_requestFail"];
    self.emptyTitle = ZFLocalizedString(@"Search_ResultViewModel_Tip",nil);
    self.edgeInsetTop = -TabBarHeight;
    [self showEmptyViewHandler:^{
        @strongify(self)
        //获取第一页数据的标签数组
        [self requestSameGoodsData:YES];
    }];
}

#pragma mark -WMPageControllerDelegate / WMPageControllerDatasource
- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    return self.tagLabelArray.count;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    if (self.tagLabelArray.count > index) {
        ZFCommuitySameGoodsCatModel *catModel = self.tagLabelArray[index];
        return catModel.catName;
    }
    return nil;
}

- (UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {
    if (self.tagLabelArray.count > index) {
        ZFCommuitySameGoodsCatModel *catModel = self.tagLabelArray[index];
        ZFCommunitySameGoodsPageItemVC *sameGoodsSubVC   = [[ZFCommunitySameGoodsPageItemVC alloc] init];
        sameGoodsSubVC.reviewID               = self.reviewID;
        sameGoodsSubVC.catId                  = catModel.catId;
        sameGoodsSubVC.cateName               = catModel.catName;
        return sameGoodsSubVC;
    }
    return nil;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return CGRectMake(0, 0, KScreenWidth, 44);
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    CGFloat menuMaxY = CGRectGetMaxY([self pageController:pageController preferredFrameForMenuView:self.menuView]);
    return CGRectMake(0, menuMaxY, KScreenWidth, self.view.height-44);
}

@end
