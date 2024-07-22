
//
//  ZFSearchResultViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/12/13.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchViewController.h"
#import "ZFInitViewProtocol.h"
#import "UICollectionViewLeftAlignedLayout.h"
#import "ZFSearchMatchResultView.h"
#import "ZFSearchPopularHeaderView.h"
#import "ZFSearchHistroyHeaderView.h"
#import "ZFSearchHistoryFooterView.h"
#import "ZFSearchMatchCollectionViewCell.h"
#import "SearchResultViewController.h"
#import "ZFSearchInputView.h"
#import "ZFSearchMatchViewModel.h"
#import "ZFSearchTypeModel.h"
#import "ZFSearchHistoryInfoModel.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFPictureSearchToolView.h"
#import "LBXPermission.h"
#import "LBXPermissionSetting.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFAnalytics.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFCommonRequestManager.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "Masonry.h"
#import "Constants.h"
#import "Configuration.h"
#import "ZFAppsflyerAnalytics.h"
#import "IQKeyboardManager.h"
#import <YYModel/YYModel.h>
#import "JumpManager.h"
#import "BannerManager.h"
#import "ZFPorpularSearchManager.h"
#import "ZFTimerManager.h"
#import "ZFGrowingIOAnalytics.h"

static NSString *const kZFSearchPopularHeaderViewIdentifier = @"kZFSearchPopularHeaderViewIdentifier";
static NSString *const kZFSearchHistroyHeaderViewIdentifier = @"kZFSearchHistroyHeaderViewIdentifier";
static NSString *const kZFSearchMatchCollectionViewCellIdentifier = @"kZFSearchMatchCollectionViewCellIdentifier";
static NSString *const kZFSearchHistoryFooterViewIdentifier = @"kZFSearchHistoryFooterViewIdentifier";

@interface ZFSearchViewController () <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateLeftAlignedLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) ZFSearchInputView                     *searchInputView;
@property (nonatomic, strong) UICollectionViewLeftAlignedLayout     *flowLayout;
@property (nonatomic, strong) UICollectionView                      *collectionView;
@property (nonatomic, strong) ZFSearchMatchResultView               *matchView;
@property (nonatomic, strong) NSArray                               *porpularSearchArray;
@property (nonatomic, strong) NSMutableArray                        *searchHistoryArray;
@property (nonatomic, strong) ZFSearchMatchViewModel                *viewModel;
@property (nonatomic, strong) NSMutableArray<ZFSearchTypeModel *>   *typeArray;
@property (nonatomic, strong) ZFPictureSearchToolView               *pictureSearchToolView;
@property (nonatomic, assign) NSInteger timeCount;// 搜索热词计时更换
@property (nonatomic, assign) NSInteger hideIndex; // 历史搜索点击展开的位置
@property (nonatomic, assign) BOOL hadClickButton; // 是否展示more按钮
@property (nonatomic, strong) NSMutableArray *analyticsArray;
@end

@implementation ZFSearchViewController
#pragma mark - Life Cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    [self addNotification];
    [self dealWithSearchDataSource];
    [self fetchRecommendSearchWord];
    [self requestGetHotWordData];
    [self zfInitView];
    [self zfAutoLayoutView];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

//- (UIStatusBarStyle)preferredStatusBarStyle {
//    return UIStatusBarStyleDefault;
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;//IQKeyboard会导致第一次点击图片失效
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;//回复IQKeyboard
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

/**
 * 请求热词接口
 */
- (void)fetchRecommendSearchWord {
    @weakify(self)
    [ZFCommonRequestManager requestHotSearchKeyword:self.cateId completion:^(NSArray *array) {
        @strongify(self)
        [ZFPorpularSearchManager sharedManager].porpularSearchArray = array;
        [self setHotSearchKeyword];
    }];
}

- (void)setHotSearchKeyword {
    NSString *keyword = [[ZFPorpularSearchManager sharedManager] getRandomPorpularSearchKeyWithArray:[ZFPorpularSearchManager sharedManager].porpularSearchArray];
    self.searchInputView.inputPlaceHolder = keyword;
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

#pragma mark - private methods
- (CGFloat)calculateAttrInfoWidthWithAttrName:(NSString *)attrName {
    if (attrName.length > 35) {
        attrName = [attrName substringToIndex:35];
    }
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGSize  size = [attrName boundingRectWithSize:CGSizeMake(MAXFLOAT, 30)  options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)   attributes:attribute context:nil].size;
    //  size.width + 16 <= 64 ? 64 : size.width + 16;
    return size.width + 16;
}

- (CGFloat)calculateAttrInfoWidthWithBanner:(JumpModel *)model {
    NSInteger imageLength = model.img_is_show ? 16 : 0;
    NSString *attrName = model.name;
    if (attrName.length > 35) {
        attrName = [attrName substringToIndex:35];
    }
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGSize  size = [attrName boundingRectWithSize:CGSizeMake(MAXFLOAT, 30)  options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin)   attributes:attribute context:nil].size;
    //  size.width + 16 + imageLength <= 64 ? 64 : size.width + 16 + imageLength;
    return size.width + 16 + imageLength;
}

- (void)dealWithSearchDataSource {  //初始化数据源，包含热门搜索 和 搜索历史
    for (ZFSearchTypeModel *model in self.typeArray) {
        if (model.type == ZFSearchTypeHistory) {
            [self.typeArray removeObject:model];
            break;
        }
    }
    
    NSMutableDictionary *historyInfo = (NSMutableDictionary *)[[[NSUserDefaults standardUserDefaults] valueForKey:kSearchHistoryKey] mutableCopy];
    NSMutableArray<ZFSearchHistoryInfoModel *> *sortArray = [NSMutableArray array];

    [historyInfo enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        ZFSearchHistoryInfoModel *model = [[ZFSearchHistoryInfoModel alloc] init];
        model.addTime = [obj doubleValue];
        model.searchKey = key;
        [sortArray addObject:model];
    }];
    
    [sortArray sortUsingComparator:^NSComparisonResult(ZFSearchHistoryInfoModel *obj1, ZFSearchHistoryInfoModel *obj2) {
        return obj1.addTime < obj2.addTime;
    }];
    
    [self.searchHistoryArray removeAllObjects];
    
    // 计算more按钮位置
    __block NSInteger lineNum = 1;
    __block CGFloat lineWidth = 0;
    __block BOOL hadCalculate = NO; // 是否计算结束
    [sortArray enumerateObjectsUsingBlock:^(ZFSearchHistoryInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.searchHistoryArray.count < 10) {
            [self.searchHistoryArray addObject:obj.searchKey];
            // 计算位置
            if (!hadCalculate) {
                if (idx == 0) {
                    lineWidth = [self calculateAttrInfoWidthWithAttrName:obj.searchKey];
                } else {
                    lineWidth += [self calculateAttrInfoWidthWithAttrName:obj.searchKey] + 10;
                }
                if (lineWidth >= KScreenWidth - 32) {
                    lineWidth = [self calculateAttrInfoWidthWithAttrName:obj.searchKey];
                    lineNum += 1;  // 第三行显示more按钮
                    if (lineNum >= 3) {
                        hadCalculate = YES;
                        self.hideIndex = idx;
                    }
                }
            }
        }
    }];
    
    self.matchView.historyArray = self.searchHistoryArray;
    
    if (self.searchHistoryArray.count > 0) {
        ZFSearchTypeModel *typeModel = [[ZFSearchTypeModel alloc] init];
        typeModel.type = ZFSearchTypeHistory;
        [self.typeArray insertObject:typeModel atIndex:0];
    }
    [self.collectionView reloadData];
}

- (void)jumpToSearchResultWithKeyword:(NSString *)keyword sourceType:(ZFAppsflyerInSourceType)sourceType {
    if ([NSStringUtils isEmptyString:keyword]) {
        return ;
    }
    SearchResultViewController *searchResultVC = [[SearchResultViewController alloc] init];
    searchResultVC.searchString = keyword;
    searchResultVC.sourceType = sourceType;
    @weakify(self);
    searchResultVC.searchResultLoadHistoryCompletionHandler = ^{
        @strongify(self);
        [self dealWithSearchDataSource];
        [self.collectionView reloadData];
    };
    [self.navigationController pushViewController:searchResultVC animated:YES];
    
    [ZFAnalytics clickButtonWithCategory:@"Search" actionName:@"Search - Perform the search" label:keyword];
}

- (void)requestGetHotWordData {
    [self.viewModel requestGetHotWordData:@{@"catId" : NullFilter(self.cateId)} completion:^(id responseObject) {
        self.porpularSearchArray = [NSArray yy_modelArrayWithClass:[JumpModel class] json:responseObject];
        
        if (self.porpularSearchArray.count > 0) {
            ZFSearchTypeModel *typeModel = [[ZFSearchTypeModel alloc] init];
            typeModel.type = ZFSearchTypePorpular;
            for (ZFSearchTypeModel *model in self.typeArray) {
                // 因为缓存会回调两次，所以先将上一次的数据清除再重新添加
                if (model.type == ZFSearchTypePorpular) {
                    [self.typeArray removeObject:model];
                    break;
                }
            }
            [self.typeArray addObject:typeModel];
            [self.collectionView reloadData];
        }
    } failure:nil];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.typeArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    ZFSearchTypeModel *model = self.typeArray[section];
    if (model.type == ZFSearchTypePorpular) {
        return self.porpularSearchArray.count;
    } else {
        return (self.hideIndex > 1 && !self.hadClickButton) ? self.hideIndex : self.searchHistoryArray.count;
    }
}

//- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
//    ZFSearchTypeModel *model = self.typeArray[indexPath.section];
//    if (model.type == ZFSearchTypeHistory && !self.hadClickButton) {
//        CGRect rect = [cell convertRect:cell.bounds toView:collectionView];
//        CGFloat cellHeight = 40;//45  85  125
//        if (rect.origin.y > cellHeight + 45 + 20) {
//            if (self.hideIndex < 1) {  // 没值
//                self.hadClickButton = YES;
//                self.hideIndex = indexPath.item;
//                [collectionView reloadData];
//            } else if (self.hideIndex > indexPath.item) {
//                self.hadClickButton = YES;
//                self.hideIndex = indexPath.item;
//                [collectionView reloadData];
//            }
//        }
//    }
//}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFSearchTypeModel *model = self.typeArray[indexPath.section];
    ZFSearchMatchCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFSearchMatchCollectionViewCellIdentifier forIndexPath:indexPath];
    if (model.type == ZFSearchTypePorpular) {
        JumpModel *model = self.porpularSearchArray[indexPath.item];
        cell.model = model;
        
        if (![self.analyticsArray containsObject:ZFToString(model.name)]) {
            [self.analyticsArray addObject:ZFToString(model.name)];
            //广告类型
            //Appfly 统计
            NSDictionary *appsflyerParams =  @{
                                               @"af_content_type" : @"popular search banner",
                                               @"af_banner_name" : ZFToString(model.name),
                                               @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type) //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                               };
            [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_impression" withValues:appsflyerParams];
            
            ZFBannerModel *bannerModel = [ZFBannerModel new];
            bannerModel.banner_id = model.bannerId;
            bannerModel.name = model.name;
            [ZFGrowingIOAnalytics ZFGrowingIOBannerImpWithBannerModel:bannerModel page:GIOSourceSearch];
        }
    } else if (model.type == ZFSearchTypeHistory) {
        cell.searchKey = self.searchHistoryArray[indexPath.item];
        cell.showHotImage = NO;
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    ZFSearchTypeModel *model = self.typeArray[indexPath.section];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if (model.type == ZFSearchTypePorpular) {
            ZFSearchPopularHeaderView *popularView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSearchPopularHeaderViewIdentifier forIndexPath:indexPath];
            return popularView;
        } else if (model.type == ZFSearchTypeHistory) {
            ZFSearchHistroyHeaderView *historyView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSearchHistroyHeaderViewIdentifier forIndexPath:indexPath];
            @weakify(self);
            historyView.searchHistoryClearCompletionHandler = ^{
                @strongify(self);
                [self.searchHistoryArray removeAllObjects];
                [self dealWithSearchDataSource];
                [self.collectionView reloadData];
            };
            return historyView;
        }
    } else {
        if (model.type == ZFSearchTypeHistory && !self.hadClickButton && self.hideIndex > 1) {
            ZFSearchHistoryFooterView *historyFooter = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kZFSearchHistoryFooterViewIdentifier forIndexPath:indexPath];
            historyFooter.searchHistoryMoreCompletionHandler = ^{
                // 点击more
                self.hadClickButton = YES;
                self.hideIndex = 0;
                [collectionView reloadData];
            };
            return historyFooter;
        }
    }
    
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    //记录搜索记录，这里需要去重处理，并本地化，点击分两种，点击热门搜索关键词 和 搜索历史关键词
    //跳转到搜索结果页面。
    ZFSearchTypeModel *model = self.typeArray[indexPath.section];
    if (model.type == ZFSearchTypePorpular) {
        JumpModel *jumpModel = self.porpularSearchArray[indexPath.item];
        NSString *source = ZFToString(jumpModel.source);
        if (!source.length) {
            source = @"deeplink";
        }
        NSString *deeplink = [NSString stringWithFormat:@"ZZZZZ://action?actiontype=%ld&url=%@&source=%@",(long)jumpModel.actionType, ZFToString(ZFEscapeString(jumpModel.url, YES)), source];
        //如果actionType=-2,则特殊处理自定义完整ddeplink
        if (jumpModel.actionType == JumpCustomDeeplinkActionType) {
            deeplink = ZFToString(ZFEscapeString(jumpModel.url, YES));
            if (ZFIsEmptyString(deeplink)) return;
        }
        
        NSMutableDictionary *paramDict = [BannerManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:deeplink]];
        NSString *name = paramDict[@"name"];
        if (ZFIsEmptyString(name)) {
            paramDict[@"name"] = ZFToString(jumpModel.name);
        }
        [BannerManager jumpDeeplinkTarget:self deeplinkParam:paramDict];
        
        // appflyer统计
        NSDictionary *appsflyerParams = @{
                                          @"af_content_type" : @"popular search banner",
                                          @"af_banner_name" : ZFToString(jumpModel.name),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"search_page",
                                          @"af_first_entrance" : @"search"
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_banner_click" withValues:appsflyerParams];
        
        ZFBannerModel *bannerModel = [ZFBannerModel new];
        bannerModel.banner_id = jumpModel.bannerId;
        bannerModel.name = jumpModel.name;
        [ZFGrowingIOAnalytics ZFGrowingIObannerClickWithBannerModel:bannerModel page:GIOSourceSearch sourceParams:@{
            GIOFistEvar : GIOSourceSearch
        }];
    } else {
        [self jumpToSearchResultWithKeyword:self.searchHistoryArray[indexPath.item] sourceType:ZFAppsflyerInSourceTypeSearchHistory];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - <UICollectionViewDelegateLeftAlignedLayout>
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(KScreenWidth, 45);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    ZFSearchTypeModel *model = self.typeArray[section];
    if (model.type == ZFSearchTypeHistory && !self.hadClickButton && self.hideIndex > 1) {
        return CGSizeMake(KScreenWidth, 25);
    } else {
        return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFSearchTypeModel *model = self.typeArray[indexPath.section];
    if (model.type == ZFSearchTypePorpular) {
        return CGSizeMake([self calculateAttrInfoWidthWithBanner:self.porpularSearchArray[indexPath.row]], 30);
    } else if (model.type == ZFSearchTypeHistory) {
        return CGSizeMake([self calculateAttrInfoWidthWithAttrName:self.searchHistoryArray[indexPath.row]], 30);
    }
    return CGSizeZero;
}

- (void)showAlbum {
    @weakify(self)
    [LBXPermission authorizeWithType:LBXPermissionType_Photos completion:^(BOOL granted, BOOL firstTime) {
        @strongify(self)
        if (granted) {
            [self openLocalPhoto];
            [self.pictureSearchToolView changeContainView];
        } else if (!firstTime) {
            [LBXPermissionSetting showAlertToDislayPrivacySettingWithTitle:@"" msg:[NSString stringWithFormat:ZFLocalizedString(@"photoPermisson", nil),[LBXPermission queryAppName]] cancel:ZFLocalizedString(@"Cancel", nil) setting:ZFLocalizedString(@"Setting_VC_Title", nil)];
        }
    }];
}

- (void)openLocalPhoto {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.navigationBar.translucent = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)takePhotoes {
    @weakify(self)
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
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *sourceImage = [info objectForKey:UIImagePickerControllerOriginalImage];

    [self pushToViewController:@"ZFSearchMapPageViewController"
                   propertyDic:@{@"sourceImage" : sourceImage,
                                 @"sourceType"  : @(ZFAppsflyerInSourceTypeSearchImagePhotos)
                                 }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.searchInputView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.matchView];
    [self.view addSubview:self.pictureSearchToolView];
}

- (void)zfAutoLayoutView{
    
    [self.searchInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
        if (IPHONE_X_5_15) {
            make.height.mas_equalTo(88);
        } else {
            make.height.mas_equalTo(64);
        }
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchInputView.mas_bottom);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-self.pictureSearchToolView.height);
    }];
    
    [self.matchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.searchInputView.mas_bottom);
    }];
    [self.view sendSubviewToBack:self.searchInputView];
}

#pragma mark - getter
- (NSMutableArray *)analyticsArray {
    if (!_analyticsArray) {
        _analyticsArray = [NSMutableArray array];
    }
    return _analyticsArray;
}

- (NSMutableArray *)searchHistoryArray {
    if (!_searchHistoryArray) {
        _searchHistoryArray = [NSMutableArray array];
    }
    return _searchHistoryArray;
}

- (NSMutableArray<ZFSearchTypeModel *> *)typeArray {
    if (!_typeArray) {
        _typeArray = [NSMutableArray array];
    }
    return _typeArray;
}

- (ZFSearchMatchViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFSearchMatchViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (ZFSearchMatchResultView *)matchView {
    if (!_matchView) {
        _matchView = [[ZFSearchMatchResultView alloc] initWithFrame:CGRectZero];
        _matchView.hidden = YES;
        @weakify(self);
        _matchView.searchMatchCloseKeyboardCompletionHandler = ^{
            @strongify(self);
            [self.view endEditing:YES];
        };
        
        _matchView.searchMatchResultSelectCompletionHandler = ^(NSString *matchKey) {
            @strongify(self);
            [self jumpToSearchResultWithKeyword:matchKey sourceType:ZFAppsflyerInSourceTypeSearchAssociation];
        };
        
        _matchView.searchMatchHideMatchViewCompletionHandler = ^{
            @strongify(self);
            self.matchView.hidden = YES;
            [self.view endEditing:YES];
        };
    }
    return _matchView;
}

- (ZFSearchInputView *)searchInputView {
    if (!_searchInputView) {
        _searchInputView = [[ZFSearchInputView alloc] initWithFrame:CGRectZero];
        // 换肤: by maownagxin
        [_searchInputView zfChangeSkinToCustomNavgationBar];
        
        @weakify(self);
        _searchInputView.searchInputCancelCompletionHandler = ^{
            @strongify(self);
            self.matchView.hidden = YES;
            [self.navigationController popViewControllerAnimated:YES];

        };
        
        _searchInputView.searchInputSearchKeyCompletionHandler = ^(NSString *searchKey) {
            @strongify(self);
            if ([NSStringUtils isEmptyString:searchKey]) {
                self.matchView.hidden = YES;
            } else {
                self.matchView.searchKey = searchKey;
                [self.viewModel requestNetwork:searchKey completion:^(id obj) {
                    NSArray *searchResult = obj;
                    self.matchView.matchResult = searchResult;
                    self.matchView.hidden = NO;
                } failure:^(id obj) {
                    
                }];
            }
        };
        
        _searchInputView.searchInputReturnCompletionHandler = ^(NSString *searchKey) {
            @strongify(self);
            if (self.matchView.matchResult.count <= 0) {
                self.matchView.hidden = YES;
            }
            [self jumpToSearchResultWithKeyword:searchKey sourceType:ZFAppsflyerInSourceTypeSearchDirect];
        };
    }
    return _searchInputView;
}

- (UICollectionViewLeftAlignedLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewLeftAlignedLayout alloc] init];
        _flowLayout.minimumLineSpacing = 10;
        _flowLayout.minimumInteritemSpacing = 10;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 12, 16);
        
        if ( [SystemConfigUtils isRightToLeftShow]) {
            _flowLayout.alignedLayoutType = UICollectionViewLeftAlignedLayoutTypeRight;
        } else {
            _flowLayout.alignedLayoutType = UICollectionViewLeftAlignedLayoutTypeLeft;
        }
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = YES;
        _collectionView.backgroundColor = ZFCOLOR_WHITE;
        [_collectionView registerClass:[ZFSearchMatchCollectionViewCell class] forCellWithReuseIdentifier:kZFSearchMatchCollectionViewCellIdentifier];
        [_collectionView registerClass:[ZFSearchHistroyHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSearchHistroyHeaderViewIdentifier];
        [_collectionView registerClass:[ZFSearchPopularHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kZFSearchPopularHeaderViewIdentifier];
        [_collectionView registerClass:[ZFSearchHistoryFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kZFSearchHistoryFooterViewIdentifier];
        _collectionView.alwaysBounceVertical = YES;

    }
    return _collectionView;
}

- (ZFPictureSearchToolView *)pictureSearchToolView {
    if (!_pictureSearchToolView) {
        _pictureSearchToolView = [[ZFPictureSearchToolView alloc] initWithFrame:CGRectZero];
        
        @weakify(self)
        _pictureSearchToolView.takePhotosHandle = ^{
            @strongify(self)
            [self takePhotoes];
        };
        
        _pictureSearchToolView.getPhotosHandle = ^{
            @strongify(self)
            [self showAlbum];
        };
        
        _pictureSearchToolView.selectedPhotoHandle = ^(UIImage *image) {
            @strongify(self)
            [self pushToViewController:@"ZFSearchMapPageViewController" propertyDic:@{@"sourceImage" : image,
                                                                                      @"sourceType"  : @(ZFAppsflyerInSourceTypeSearchImagePhotos)
                                                                                      }];
        };
    }
    return _pictureSearchToolView;
}

@end
