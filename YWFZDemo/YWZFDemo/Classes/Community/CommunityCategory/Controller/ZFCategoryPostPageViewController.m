//
//  ZFCategoryWaterfallViewController.m
//  Zaful
//
//  Created by occ on 2018/8/15.
//  Copyright © 2018年 Zaful. All rights reserved.
//

#import "ZFCommunityPostCategoryViewController.h"
#import "UIViewController+ZFShowEmptyVeiw.h"
#import "ZFCategroyWaterfallItemViewController.h"

#import "ZFCategroyPostViewModel.h"


@interface ZFCommunityPostCategoryViewController ()

@property (nonatomic, strong) ZFCategroyPostViewModel         *viewModel;
@property (nonatomic, strong) ZFCategoryPostModel             *postModel;

@end

@implementation ZFCategoryPostPageViewController

- (instancetype)init {
    if (self = [super init]) {
        self.pageAnimatable = YES;
        self.showOnNavigationBar = NO;
        self.postNotification = YES;
        self.bounces = YES;
        self.titleSizeNormal = 16;
        self.titleSizeSelected = 17;
        self.menuViewStyle = WMMenuViewStyleLine;
        self.itemMargin = 16;
        self.titleColorNormal = ColorHex_Alpha(0x999999, 1.0);
        self.titleColorSelected = ColorHex_Alpha(0xB85F25, 1.0);
        self.menuViewLayoutMode = WMMenuViewLayoutModeCenter;
        self.progressColor = ColorHex_Alpha(0xB85F25, 1.0);
        self.progressHeight = 3;
        self.automaticallyCalculatesItemWidths = YES;
        self.titleSizeNormal = 14.0;
        self.titleSizeSelected = 16.0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = ZFToString(self.jumpModel.name);
    
    [self requestCategoryDatas];
}

#pragma mark - Request

- (void)requestCategoryDatas {
    
    ShowLoadingToView(self.view);

    NSArray *communityInfo = [ZFToString(self.jumpModel.url) componentsSeparatedByString:@","];
    @weakify(self)
    [self.viewModel requestCategroyWaterData:@{@"cat_id":ZFToString(communityInfo.lastObject)} Completion:^(ZFCategoryPostModel *postModel) {
        
        @strongify(self)
        HideLoadingFromView(self.view);
        self.postModel = postModel;
        NSString *titleStr = ZFToString(self.postModel.cat_name);
        if (self.title.length <= 0 && titleStr.length > 0) {
            self.title = ZFToString(self.postModel.cat_name);
        }
        
        if (self.postModel.cat_id == nil
            && self.postModel.sonList == nil) { //无数据
            [self showNoDataView];
        } else {
            [self reloadData];
            [self removeEmptyView];
        }
        
    } failure:^(id obj) {
        @strongify(self)
        [self showAgainRequestView];
        HideLoadingFromView(self.view);
    }];
    
}

- (void)showAgainRequestView {
    self.emptyImage = [UIImage imageNamed:@"blankPage_networkError"];
    self.emptyTitle = ZFLocalizedString(@"BlankPage_NetworkError_tipTitle",nil);
    self.edgeInsetTop = -TabBarHeight;
    @weakify(self)
    [self showEmptyViewHandler:^{
        @strongify(self)
        [self requestCategoryDatas];
    }];
}

- (void)showNoDataView {
    self.emptyImage = [UIImage imageNamed:@"blankPage_noPicture"];
    self.emptyTitle = ZFLocalizedString(@"No_content",nil);
    self.edgeInsetTop = -TabBarHeight - 80;
    [self showEmptyViewHandler:nil];
}



#pragma mark - WMPageControllerDataSource

- (NSInteger)numbersOfChildControllersInPageController:(WMPageController *)pageController {
    if (self.postModel.sonList.count > 0) {
        return self.postModel.sonList.count;
    }
    return 1;
}

- (NSString *)pageController:(WMPageController *)pageController titleAtIndex:(NSInteger)index {
    if (self.postModel.sonList.count > index) {
        ZFCategoryPostChannelModel *channelModel = self.postModel.sonList[index];
        return NullFilter(channelModel.cat_name);
    }
    return @"";
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForMenuView:(WMMenuView *)menuView {
    return self.postModel.sonList > 0 ? CGRectMake(0, 0, KScreenWidth, 44) : CGRectZero;
}

- (CGRect)pageController:(WMPageController *)pageController preferredFrameForContentView:(WMScrollView *)contentView {
    return self.postModel.sonList > 0 ? CGRectMake(0, 44, KScreenWidth, self.view.bounds.size.height - 44) :  self.view.bounds;
}

- (__kindof UIViewController *)pageController:(WMPageController *)pageController viewControllerAtIndex:(NSInteger)index {

    ZFCategroyWaterfallItemViewController *vc = [[ZFCategroyWaterfallItemViewController alloc] init];
    if (self.postModel.sonList.count > index) {//有子频道
        ZFCategoryPostChannelModel *channelModel = self.postModel.sonList[index];
        vc.channelModel = channelModel;
        vc.tipMoveHeight = TabBarHeight + 44;
        
    } else {//无子频道
        
        ZFCategoryPostChannelModel *channelModel = [[ZFCategoryPostChannelModel alloc] init];
        channelModel.cat_name = ZFToString(self.postModel.cat_name);
        channelModel.channel_id = ZFToString(self.postModel.cat_id);
        channelModel.parent_id = ZFToString(self.postModel.parent_id);
        vc.channelModel = channelModel;
    }
    return vc;
}

#pragma mark - LazyLoad

- (ZFCategroyPostViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCategroyPostViewModel alloc] init];
    }
    return _viewModel;
}

- (ZFCategoryPostModel *)postModel {
    if (!_postModel) {
        _postModel = [[ZFCategoryPostModel alloc] init];
    }
    return _postModel;
}

@end
