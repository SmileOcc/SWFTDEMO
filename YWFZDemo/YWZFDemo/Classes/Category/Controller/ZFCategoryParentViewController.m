//
//  ZFCategoryParentViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/11/20.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCategoryParentViewController.h"
#import "CategoryListPageViewController.h"
#import "ZFSearchViewController.h"
#import "ZFSuperCateViewCell.h"
#import "ZFChildCateCollectionViewCell.h"
#import "ZFBannerCollectionView.h"
#import "ZFBannerModel.h"
#import "BannerManager.h"
#import "CategoryParentViewModel.h"
#import "ZFCategoryNavigationView.h"
#import "LBXPermission.h"
#import "LBXPermissionSetting.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFAnalytics.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFStatistics.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFCommonRequestManager.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFCategoryParentBannerCell.h"
#import "ZFCategoryParentModel.h"
#import "ZFApiDefiner.h"
#import "ZFPorpularSearchManager.h"
#import "ZFTimerManager.h"
#import "ZFGrowingIOAnalytics.h"
#import "ZFCategoryParentAnalyticsAOP.h"

@interface ZFCategoryParentViewController ()<UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) ZFCategoryNavigationView  *navigationView;
@property (nonatomic, strong) UITableView *superCategoryTableView;
@property (nonatomic, strong) UICollectionView          *subCategoryView;
@property (nonatomic, strong) CategoryParentViewModel   *viewModel;
@property (nonatomic, assign) NSInteger timeCount;//搜索热词计时更换
@property (nonatomic, strong) ZFCategoryParentAnalyticsAOP *categoryParentAnalyticsAOP;
@end

@implementation ZFCategoryParentViewController

- (void)dealloc {
    HideLoadingFromView(self.view);
    HideLoadingFromView(nil);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.categoryParentAnalyticsAOP];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    self.superCategoryTableView.hidden = YES;
    [self addNotification];
    [self setupView];
    [self layout];
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    //购物车数量
    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
    self.navigationView.badgeCount = [NSString stringWithFormat:@"%lu", (long)[badgeNum integerValue]];
}

- (void)setupView {
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.superCategoryTableView];
    [self.view addSubview:self.subCategoryView];
}

- (void)layout {
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
        make.height.mas_equalTo((STATUSHEIGHT + 44.0));
    }];
    
    [self.superCategoryTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.navigationView.mas_bottom);
        make.width.mas_equalTo(kSuperCategoryTableWidth);
    }];
    
    CGFloat margin = kCollectionViewMargin;
    [self.subCategoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navigationView.mas_bottom);
        make.leading.mas_equalTo(self.superCategoryTableView.mas_trailing).offset(margin);
        make.bottom.mas_equalTo(self.view);
        make.trailing.mas_equalTo(self.view).offset(-margin);
    }];
    [self.view layoutIfNeeded];
}

- (void)setHotSearchKeyword {
    NSString *keyword = [[ZFPorpularSearchManager sharedManager] getRandomPorpularSearchKey];
    self.navigationView.inputPlaceHolder = keyword;
}

- (void)searchNavTitleChange {
    self.timeCount ++;
    if (self.timeCount % 5 == 0) {  // 每5秒更换搜索热词
        [self setHotSearchKeyword];
    }
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchNavTitleChange) name:kTimerManagerUpdate object:nil];
}

#pragma mark ---------- request
- (void)requestData {
    if ([ZFPorpularSearchManager sharedManager].homePorpularSearchArray.count < 1) {
        @weakify(self)
        [ZFCommonRequestManager requestHotSearchKeyword:nil completion:^(NSArray *array) {
            @strongify(self)
            [ZFPorpularSearchManager sharedManager].homePorpularSearchArray = array;
            [self setHotSearchKeyword];
        }];
    } else {
        [self setHotSearchKeyword];
    }
    
    [self loadSuperCate];
}

/**
 加载父分类
 */
- (void)loadSuperCate {
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.viewModel requestParentsCategoryData:nil completion:^(NSArray *parentModelArray){
        @strongify(self)
        HideLoadingFromView(self.view);
        self.superCategoryTableView.hidden = NO;
        [self.superCategoryTableView reloadData];
        [self.subCategoryView reloadData];
        [self showEmptyView];
        
    } failure:^(NSError *error) {
        @strongify(self)
        [self.superCategoryTableView reloadData];
        [self.subCategoryView reloadData];
        [self showEmptyView];
        HideLoadingFromView(self.view);
    }];
    // 添加一个占位的返回按钮
    [self bringTempBackButtonToFront];
}

- (void)showEmptyView {
    self.edgeInsetTop = (STATUSHEIGHT + 45.0);
    if ([self.viewModel superCateCount] <= 0) {
        @weakify(self)
        [self showEmptyViewHandler:^{
            @strongify(self)
            [self loadSuperCate];
        }];
    } else {
        [self removeEmptyView];
    }
}

#pragma mark ---------- UITableViewDelegate/UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel superCateCount];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFSuperCateViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFSuperCateViewCell class])];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.cateTabNav = [self.viewModel superCateWithIndex:indexPath.row];
    [cell configData:[self.viewModel superCateNameWithIndex:indexPath.row]
          isSelected:indexPath.row == [self.viewModel selectedCateIndex]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.viewModel selectedCateIndex] != indexPath.row) {
        [self.viewModel setselectedCateIndex:indexPath.row];
        [self.superCategoryTableView reloadData];
        [self.subCategoryView reloadData];
        self.subCategoryView.contentOffset = CGPointMake(0.0, 0.0);
        
        // 判断空白页
        if (self.viewModel.subCateSectionModelArray.count == 0) {
            NSString *categoryTitle = [self.viewModel superCateNameWithIndex:indexPath.row];
            self.subCategoryView.emptyDataTitle = [NSString stringWithFormat:ZFLocalizedString(@"CategoryNoDate",nil),ZFToString(categoryTitle)];
        }
        [self.subCategoryView showRequestTip:@{}];
        
        if (self.superCategoryTableView.contentSize.height > self.superCategoryTableView.height) {
            ZFSuperCateViewCell *cell = [self.superCategoryTableView cellForRowAtIndexPath:indexPath];
            CGFloat maxOffsetY        = self.superCategoryTableView.contentSize.height - self.superCategoryTableView.height;
            CGFloat midY              = self.superCategoryTableView.height / 2;
            CGFloat helfHeight        = cell.height / 2;
            CGFloat willOffsetY       = cell.y - midY + helfHeight;
            if (willOffsetY > 0.0f && willOffsetY <= maxOffsetY) {
                self.superCategoryTableView.contentOffset = CGPointMake(0.0, willOffsetY);
            } else if (willOffsetY > maxOffsetY) {
                self.superCategoryTableView.contentOffset = CGPointMake(0.0, maxOffsetY);
            } else {
                self.superCategoryTableView.contentOffset = CGPointMake(0.0, 0.0);
            }
        }
    }
}

#pragma mark ---------- UICollectionViewDataSource/UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.viewModel.subCateSectionModelArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.viewModel.subCateSectionModelArray.count > section) {
        ZFSubCategorySectionModel *sectionModel = self.viewModel.subCateSectionModelArray[section];
        return sectionModel.sectionModelarray.count;
    } else {
        return 0;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.subCateSectionModelArray.count > indexPath.section) {
        ZFSubCategorySectionModel *sectionModel = self.viewModel.subCateSectionModelArray[indexPath.section];
        return sectionModel.sectionItemSize;
    } else {
        return CGSizeZero;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.viewModel.subCateSectionModelArray.count <= section) return UIEdgeInsetsZero;
    
    ZFSubCategorySectionModel *sectionModel = self.viewModel.subCateSectionModelArray[section];
    if (sectionModel.sectionType == ZFSubCategoryModel_GoodsType) {
        return UIEdgeInsetsMake(kImageMarginSpace, 0.0, kImageMarginSpace, 0.0);
    } else {
        return UIEdgeInsetsMake(kImageMarginSpace, 0.0, 0.0, 0.0);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.subCateSectionModelArray.count <= indexPath.section) {
         return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    }
    ZFSubCategorySectionModel *sectionModel = self.viewModel.subCateSectionModelArray[indexPath.section];

    if (sectionModel.sectionType == ZFSubCategoryModel_BannerType) {
        ZFCategoryParentBannerCell *bannerCell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCategoryParentBannerCell class]) forIndexPath:indexPath];
        
        if (sectionModel.sectionModelarray.count > indexPath.item) {
            ZFCategoryTabContainer *tabContainer = sectionModel.sectionModelarray[indexPath.item];
            bannerCell.tabContainer = tabContainer;
            [bannerCell configWithImageUrl:tabContainer.img];
        }
        return bannerCell;        
    } else {
        ZFChildCateCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFChildCateCollectionViewCell class]) forIndexPath:indexPath];
        
        if (sectionModel.sectionModelarray.count > indexPath.item) {
            ZFCategoryTabContainer *tabContainer = sectionModel.sectionModelarray[indexPath.item];
            cell.tabContainer = tabContainer;
            [cell configWithImageUrl:tabContainer.img cateName:tabContainer.text];
        }
        return cell;
    }
}

// 两行之间的上下间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    if (self.viewModel.subCateSectionModelArray.count <= section) return 0;
    ZFSubCategorySectionModel *sectionModel = self.viewModel.subCateSectionModelArray[section];
    if (sectionModel.sectionType == ZFSubCategoryModel_BannerType) {
        return kImageMarginSpace;
    } else {
        return 0;
    }
}

// 两个cell之间的左右间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.viewModel.subCateSectionModelArray.count <= indexPath.section) return;
    
    ZFSubCategorySectionModel *sectionModel = self.viewModel.subCateSectionModelArray[indexPath.section];
    if (sectionModel.sectionModelarray.count <= indexPath.item) return;
    
    ZFCategoryTabContainer *tabContainer = sectionModel.sectionModelarray[indexPath.item];
    if (ZFIsEmptyString(tabContainer.actionType)) return;
    
    NSString *name = ZFToString(ZFEscapeString(tabContainer.text, YES));
    NSString *deeplink = [NSString stringWithFormat:ZFCMSConvertDeepLinkString,tabContainer.actionType, ZFToString(ZFEscapeString(tabContainer.actionUrl, YES)), name];
    
    if (tabContainer.actionType.integerValue == -2) {
        deeplink = ZFToString(ZFEscapeString(tabContainer.actionUrl, YES));
        if (ZFIsEmptyString(deeplink)) return;
    }
    NSMutableDictionary *paramDict = [BannerManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:deeplink]];
    [BannerManager jumpDeeplinkTarget:self deeplinkParam:paramDict];
    // GA
    [self.viewModel clickBannerAdvertisementWithIndex:tabContainer bannerIndex:indexPath.item];
    // GIO
    ZFCategoryTabNav *selectedTabNav = [self.viewModel getSlectedCategoryTabNav];
    [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOFistEvar : GIOSourceCategory,
                                               GIOSndIdEvar : @(selectedTabNav.tabNavId),
                                               GIOSndNameEvar : ZFToString(selectedTabNav.text),
                                               GIOThirdIdEvar : ZFToString(tabContainer.tabContainerId),
                                               GIOThirdNameEvar : ZFToString(tabContainer.text)
                                             }];
}

#pragma mark ---------- getter/setter
- (ZFCategoryNavigationView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[ZFCategoryNavigationView alloc] init];
        
        // 换肤: by maownagxin
        [_navigationView zfChangeSkinToCustomNavgationBar];
        
        _navigationView.showBackButton = (self.navigationController.viewControllers.count>1);
        
        @weakify(self);
        _navigationView.categoryBackCompletionHandler = ^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        };
        
        _navigationView.categoryJumpCartCompletionHandler = ^{
            @strongify(self);
            [ZFStatistics eventType:ZF_Category_Cars_type];
            [self pushToViewController:@"ZFCartViewController" propertyDic:nil];
        };
        
        _navigationView.categoryActionSearchInputCompletionHandler = ^{
            @strongify(self);
            [ZFStatistics eventType:ZF_Category_Search_type];
            ZFSearchViewController *searchVC = [[ZFSearchViewController alloc] init];
//            searchVC.placeholder = self.navigationView.inputPlaceHolder;
            [self.navigationController pushViewController:searchVC animated:YES];
        };
        
        _navigationView.categoryActionSearchImageCompletionHandler = ^{
            @strongify(self);
            [ZFStatistics eventType:ZF_Category_SearchImage_type];
            [LBXPermission authorizeWithType:LBXPermissionType_Camera completion:^(BOOL granted, BOOL firstTime) {
                @strongify(self)
                if (granted) {
                    [self pushToViewController:@"ZFCameraViewController" propertyDic:nil];
                }
                else if(!firstTime) {
                    NSString *msg = [NSString stringWithFormat:ZFLocalizedString(@"cameraPermisson", nil), @"ZZZZZ"];
                    [LBXPermissionSetting showAlertToDislayPrivacySettingWithTitle:ZFLocalizedString(@"Can not use camera", nil) msg:msg cancel:ZFLocalizedString(@"Cancel", nil) setting:ZFLocalizedString(@"Setting_VC_Title", nil)];
                }
            }];
        };
    }
    return _navigationView;
}

- (UITableView *)superCategoryTableView {
    if (!_superCategoryTableView) {
        _superCategoryTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _superCategoryTableView.delegate           = self;
        _superCategoryTableView.dataSource         = self;
        _superCategoryTableView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
        _superCategoryTableView.tableFooterView    = [UIView new];
        _superCategoryTableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
        _superCategoryTableView.showsVerticalScrollIndicator = NO;
        
        [_superCategoryTableView registerClass:[ZFSuperCateViewCell class] forCellReuseIdentifier:NSStringFromClass([ZFSuperCateViewCell class])];
    }
    return _superCategoryTableView;
}

- (UICollectionView *)subCategoryView {
    if (!_subCategoryView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 0.f;
        layout.minimumLineSpacing = 0.f;
        
        _subCategoryView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _subCategoryView.backgroundColor = [UIColor whiteColor];
        _subCategoryView.delegate   = self;
        _subCategoryView.dataSource = self;
        _subCategoryView.alwaysBounceVertical = YES;
        _subCategoryView.showsVerticalScrollIndicator = NO;
        
        _subCategoryView.emptyDataImage = ZFImageWithName(@"blankPage_noCart");
        _subCategoryView.emptyDataTitle = ZFLocalizedString(@"EmptyCustomViewHasNoData_titleLabel",nil);
        
        [_subCategoryView registerClass:[ZFChildCateCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFChildCateCollectionViewCell class])];
        [_subCategoryView registerClass:[ZFCategoryParentBannerCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCategoryParentBannerCell class])];
        
        [_subCategoryView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
    }
    return _subCategoryView;
}

- (CategoryParentViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [CategoryParentViewModel new];
        _viewModel.loadingView = self.view;
        _viewModel.controller = self;
        @weakify(self)
        _viewModel.subCateRequestHandler = ^{
            @strongify(self)
            HideLoadingFromView(self.view);
            HideLoadingFromView(nil);
            [self.subCategoryView reloadData];
            [self.subCategoryView showRequestTip:@{}];
        };
    }
    return _viewModel;
}

- (ZFCategoryParentAnalyticsAOP *)categoryParentAnalyticsAOP {
    if (!_categoryParentAnalyticsAOP) {
        _categoryParentAnalyticsAOP = [[ZFCategoryParentAnalyticsAOP alloc] init];
    }
    return _categoryParentAnalyticsAOP;
}

@end
