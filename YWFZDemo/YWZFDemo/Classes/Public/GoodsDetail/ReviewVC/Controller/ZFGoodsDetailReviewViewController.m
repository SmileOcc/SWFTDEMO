
//
//  ZFGoodsDetailReviewViewController.m
//  ZZZZZ
//
//  Created by YW on 2017/11/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsDetailReviewViewController.h"
#import "ZFInitViewProtocol.h"
#import "YYPhotoBrowseView.h"
#import "ZFGoodsDetailReviewInfoTableViewCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ZFReviewDetailHeaderView.h"
#import "ZFGoodsReviewFilterView.h"
#import "UIScrollView+ZFBlankPageView.h"

#import "ZFGoodsDetailReviewsViewModel.h"
#import "GoodsDetailsReviewsModel.h"
#import "GoodsDetailFirstReviewModel.h"
#import "GoodsDetailsReviewsImageListModel.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFBTSManager.h"
#import "ZFBlankPageTipView.h"
#import "ZFAnalytics.h"
#import "ZFReviewPhotoBrowseView.h"
#import "GoodsDetailFirstReviewImgListModel.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFProgressHUD.h"
#import "NSString+Extended.h"
#import "ZFAppsflyerAnalytics.h"

static NSInteger kReviewHeaderHeight = 115;
static NSString *const kZFReviewDetailHeaderViewIdentifier = @"kZFReviewDetailHeaderViewIdentifier";
static NSString *const kZFGoodsDetailReviewInfoTableViewCellIdentifier = @"kZFGoodsDetailReviewInfoTableViewCellIdentifier";

@interface ZFGoodsDetailReviewViewController () <ZFInitViewProtocol, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView                                       *tableView;
@property (nonatomic, strong) GoodsDetailsReviewsModel                          *reviewsModel;
@property (nonatomic, strong) ZFReviewDetailHeaderView                          *headerView;

@property (nonatomic, strong) NSMutableArray<GoodsDetailFirstReviewModel *>     *dataArray;
@property (nonatomic, strong) NSMutableArray                                    *imageViews;
@property (nonatomic, strong) NSMutableArray<YYPhotoGroupItem *>                *items;

@property (nonatomic, strong) NSArray                                           *filterArray;
@property (nonatomic, copy) NSString                                            *sort;
@property (nonatomic, assign) BOOL                                              hasTrackReviewList;
@property (nonatomic, strong) ZFReviewPhotoBrowseView                           *photoBrowseView;
@property (nonatomic, assign) BOOL                                              needAppendMorePhotoBrowse;
@property (nonatomic, assign) BOOL                                              isOpenPhotoBrows;
@end

@implementation ZFGoodsDetailReviewViewController

#pragma mark - Life cycle

- (void)dealloc {
    if (_photoBrowseView) {
        [self.photoBrowseView removeFromSuperview];
        self.photoBrowseView = nil;
    }
    // 统计
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_exit_comment" withValues:@{
        @"af_content_type" : @"exit comment",
        @"af_content_id" : ZFToString(self.goodsSn)
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.isOpenPhotoBrows) {
        return UIStatusBarStyleLightContent;
    } else {
        return [super preferredStatusBarStyle];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 统计
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_enter_comment" withValues:@{
        @"af_content_type" : @"enter comment",
        @"af_content_id" : ZFToString(self.goodsSn)
    }];
    self.sort = @"5";
    [self zfInitView];
    [self zfAutoLayoutView];
}

#pragma mark - Request

- (void)requestReviewListLoadMore:(BOOL)loadMore
                      showLoading:(BOOL)showLoading {
    if (loadMore) {
        self.reviewsModel.page += 1;
    } else {
        self.reviewsModel.page = 1;
    }
    NSDictionary *parmaters = @{
        @"goods_id"    : ZFToString(self.goodsId),
        @"goods_sn"    : ZFToString(self.goodsSn),
        @"sort"        : ZFToString(self.sort),
        @"page"        : @(self.reviewsModel.page),
        @"page_size"   : @(10),
    };
    if (showLoading) {
        ShowLoadingToView(self.view);
    }
    self.tableView.backgroundView = nil;
    [ZFGoodsDetailReviewsViewModel requestReviewsData:parmaters completion:^(id obj) {
        HideLoadingFromView(self.view);
        
        self.reviewsModel = obj;
        if (loadMore) {
            [self.dataArray addObjectsFromArray:self.reviewsModel.reviewList];
            // 累加下一页图片
            if (self.needAppendMorePhotoBrowse && self.photoBrowseView) {
                [self calculateShowBrowseImage:self.reviewsModel.reviewList
                                   reviewModel:nil
                                     showIndex:-1];
            }
        } else {
            self.dataArray = [NSMutableArray arrayWithArray:self.reviewsModel.reviewList];
            if (!self.headerView.rankingModel) {
                self.headerView.points = [NSString stringWithFormat:@"%.1lf", self.reviewsModel.agvRate];
                self.headerView.reviewsCount = self.reviewsModel.reviewCount;
                self.headerView.rankingModel = self.reviewsModel.size_over_all;//显示rank积分
                self.headerView.hidden = NO;
            }
            if (showLoading) {
                [self.tableView setContentOffset:CGPointMake(0, kReviewHeaderHeight)];
            }
        }
        [self.tableView reloadData];
        NSDictionary *pageDic = @{kTotalPageKey:@(self.reviewsModel.pageCount),
                                  kCurrentPageKey:@(self.reviewsModel.page)};
        [self.tableView showRequestTip:pageDic];
        [self showEmptyView:(self.dataArray.count == 0)];
        
    } failure:^(id obj) {
        [self.tableView reloadData];
        [self.tableView showRequestTip:nil];
        if (!loadMore) {
            [self showEmptyView:YES];
        }
    }];
}

- (void)showEmptyView:(BOOL)show {
    self.tableView.backgroundView = nil;
    if (show) {
        UIImage *emptyImage = [UIImage imageNamed:@"blankPage_favorites"];
        NSString *emptyTitle = ZFLocalizedString(@"EmptyCustomViewHasNoData_titleLabel",nil);
        CGFloat tipHeiht = self.tableView.bounds.size.height-115;
        CGRect rect = CGRectMake(0, 115 + (self.view.bounds.size.height - tipHeiht) / 2, self.tableView.bounds.size.width, tipHeiht);
        ZFBlankPageTipView *tipView = [ZFBlankPageTipView tipViewByFrame:rect
                                                             moveOffsetY:0
                                                                topImage:emptyImage
                                                                   title:emptyTitle
                                                                subTitle:nil
                                                             actionTitle:nil
                                                             actionBlock:nil];
        UIView *contenView = [[UIView alloc] initWithFrame:self.view.bounds];
        contenView.backgroundColor = [UIColor whiteColor];
        [contenView addSubview:tipView];
        self.tableView.backgroundView = contenView;
    }
}

/**
 * 统计:商详页评论模块曝光
 * 统计:商详页评论列表页曝光
 */
- (void)analyticsAFProductReview {
    NSString *goodsSN = self.goodsSn;
    NSString *spuSN = goodsSN;
    if (goodsSN.length > 7) {  // sn的前7位为同款id
        spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
    }
    NSMutableDictionary *valuesDic      = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId]    = ZFToString(goodsSN);
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_review_list" withValues:valuesDic];
}

#pragma mark - private methods

- (void)handleFilterEvent {
    [self.filterArray enumerateObjectsUsingBlock:^(ZFReviewFilterModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.selectState) {
            if(obj.type == ZFReviewFilterTypeLatest) {
                self.sort = @"1";
            } else if(obj.type == ZFReviewFilterPicture) {
                self.sort = @"4";
            } else {
                self.sort = @"5";//最优排序，图片优先
            }
            *stop = YES;
        }
    }];
    [self requestReviewListLoadMore:NO showLoading:YES];
}

//文案翻译事件处理
- (void)translateCellIndex:(NSIndexPath *)index reviewModel:(GoodsDetailFirstReviewModel *)model {
    model.isTranslate = !model.isTranslate;
    [self.tableView reloadRowsAtIndexPaths:@[index] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - <UITableViewDataSource>

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (!self.reviewsModel) ? 0 : 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ZFGoodsReviewFilterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kZFReviewDetailHeaderViewIdentifier];
    headerView.filterArray = self.filterArray;
    @weakify(self)
    headerView.filterBlock = ^(NSArray *filterArray) {
        @strongify(self)
        self.filterArray = filterArray.copy;
        [self handleFilterEvent];
    };
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *identify = kZFGoodsDetailReviewInfoTableViewCellIdentifier;
    if (self.dataArray.count <= indexPath.row) {
        identify = NSStringFromClass([UITableViewCell class]);
    }
    ZFGoodsDetailReviewInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identify];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([cell isKindOfClass:[ZFGoodsDetailReviewInfoTableViewCell class]]) {
        cell.isShowSizeView = YES;
        cell.model = self.dataArray[indexPath.row];
        
        @weakify(self);
        cell.goodsDetailReviewImageCheckCompletionHandler = ^(NSInteger index, NSArray *imageViewArr) {
            @strongify(self);
            GoodsDetailFirstReviewModel *reviewModel = self.dataArray[indexPath.row];
            [self openPhotosBrowseViewModel:reviewModel andIndex:index showImageViewArr:imageViewArr];
            self.photoBrowseView.hidden = NO;
            self.photoBrowseView.frame = self.view.window.bounds;
        };
        cell.reviewTranslateBlcok = ^(GoodsDetailFirstReviewModel *reviewModel) {
            @strongify(self);
            [self translateCellIndex:indexPath reviewModel:reviewModel];
        };
    }
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.hasTrackReviewList) {
        self.hasTrackReviewList = YES;
        [self analyticsAFProductReview];
    }
}

#pragma mark - <PhotosBrowse>

- (void)openPhotosBrowseViewModel:(GoodsDetailFirstReviewModel *)reviewModel
                         andIndex:(NSInteger)index
                 showImageViewArr:(NSArray *)showImageViewArr {
    [self calculateShowBrowseImage:self.dataArray
                       reviewModel:reviewModel
                         showIndex:index];
}

/**
 * 计算图片浏览器的图片
 */
- (void)calculateShowBrowseImage:(NSArray *)dataArray
                     reviewModel:(GoodsDetailFirstReviewModel *)reviewModel
                       showIndex:(NSInteger)index
{
    __block NSInteger showIndex = index;
    NSMutableArray *imageUrllArray = [NSMutableArray array];
    NSMutableArray *reviewTextArray = [NSMutableArray array];
    [dataArray enumerateObjectsUsingBlock:^(GoodsDetailFirstReviewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *picModelArray = obj.imgList;
        if ([picModelArray isKindOfClass:[picModelArray class]]) {
            if ([reviewModel isEqual:obj]) {
                showIndex = imageUrllArray.count + index;
            }
            for (GoodsDetailFirstReviewImgListModel *picModel in picModelArray) {
                if (!ZFIsEmptyString(picModel.originPic)) {
                    [imageUrllArray addObject:picModel.originPic];
                    
                    NSMutableString *reviewsText = [NSMutableString string];
                    NSString *overallFit = [obj.review_size reviewsOverallContent];
                    
                    if (!ZFIsEmptyString(obj.attr_strs)) {
                        if ([obj.review_size isShowOverall] && !ZFIsEmptyString(overallFit)) {
                            [reviewsText appendString:[self configuEmptyChar:obj.attr_strs]];
                        } else {
                            [reviewsText appendFormat:@"%@\n", obj.attr_strs];
                        }
                    }
                    
                    if ([obj.review_size isShowOverall]){
                        if(!ZFIsEmptyString(overallFit)) {
                            [reviewsText appendFormat:@"%@: %@\n", ZFLocalizedString(@"Reviews_OverallFit", nil), overallFit];
                        }
                    }
                    // 是否显示评论Size
                    if ([obj.review_size isShowReviewsSize] ) {
                        NSString *height = ZFIsEmptyString(obj.review_size.height) ? @"-" : ZFToString(obj.review_size.height);
                        
                        NSString *heightText = [self configuEmptyChar:[NSString stringWithFormat:@"%@: %@", ZFLocalizedString(@"Reviews_Height", nil), height]];
                        [reviewsText appendString:heightText];
                        
                        NSString *waist = ZFIsEmptyString(obj.review_size.waist) ? @"-" : ZFToString(obj.review_size.waist);
                        [reviewsText appendFormat:@"%@: %@\n", ZFLocalizedString(@"Reviews_Waist", nil), waist];
                        
                        NSString *hips = ZFIsEmptyString(obj.review_size.hips) ? @"-" : ZFToString(obj.review_size.hips);
                        NSString *hipsText = [self configuEmptyChar:[NSString stringWithFormat:@"%@: %@", ZFLocalizedString(@"Reviews_Hips", nil), hips]];
                        [reviewsText appendString:hipsText];
                        
                        NSString *bust = ZFIsEmptyString(obj.review_size.bust) ? @"-" : ZFToString(obj.review_size.bust);
                        [reviewsText appendFormat:@"%@: %@\n", ZFLocalizedString(@"Reviews_BustSize", nil), bust];
                    }
                    [reviewsText appendString:obj.content];
                    [reviewTextArray addObject:reviewsText];
                }
            }
        }
    }];
    if (!reviewModel && index == -1) { // 请求更多图片
        if (imageUrllArray.count > 0) {
            [self.photoBrowseView setReviewBrowseData:imageUrllArray
                                           reviewText:reviewTextArray
                                          currentPage:-1
                                         isAppendData:YES];
        } else { // 如果此页没有请求到图片,则继续请求下一页
            if (self.reviewsModel.page < self.reviewsModel.pageCount) {
                [self requestReviewListLoadMore:YES showLoading:NO];
            }
        }
    } else { // 第一次显示
        [self.photoBrowseView setReviewBrowseData:imageUrllArray
                                       reviewText:reviewTextArray
                                      currentPage:showIndex
                                     isAppendData:NO];
    }
}

/**
 * 左右两列对齐,采用拼接空格的方式实现
 */
- (NSString *)configuEmptyChar:(NSString *)appendText {
    if (appendText) {
        CGFloat maxWidth = KScreenWidth - 12 * 2;
        CGSize size = [appendText textSizeWithFont:ZFFontSystemSize(14)
                                 constrainedToSize:CGSizeMake(MAXFLOAT, 40)
                                     lineBreakMode:NSLineBreakByWordWrapping
                                    paragraphStyle:nil];
        if (size.width > maxWidth/2) {
            return appendText;
        } else {
            return [self configuEmptyChar:[appendText stringByAppendingString:@" "]];
        }
    }
    return appendText;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.title = ZFLocalizedString(@"GoodsReviews_VC_Title", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    [self createFilterData];
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)createFilterData {
    if (_filterArray == nil) {
        ZFReviewFilterModel *firstModel = [[ZFReviewFilterModel alloc] init];
        firstModel.type = ZFReviewFilterTypeAll;
        firstModel.selectState = YES;
        
        ZFReviewFilterModel *secondModel = [[ZFReviewFilterModel alloc] init];
        secondModel.type = ZFReviewFilterTypeLatest;
        secondModel.selectState = NO;
        
        ZFReviewFilterModel *thirdModel = [[ZFReviewFilterModel alloc] init];
        thirdModel.type = ZFReviewFilterPicture;
        thirdModel.selectState = NO;
        _filterArray = @[firstModel,secondModel,thirdModel];
    }
}

#pragma mark - getter
- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
    }
    return _imageViews;
}

- (NSMutableArray<YYPhotoGroupItem *> *)items {
    if (!_items) {
        _items = [NSMutableArray array];
    }
    return _items;
}

- (NSMutableArray<GoodsDetailFirstReviewModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (ZFReviewDetailHeaderView *)headerView {
    if (!_headerView) {
        CGRect rect = CGRectMake(0, 0, KScreenWidth, kReviewHeaderHeight);
        _headerView = [[ZFReviewDetailHeaderView alloc] initWithFrame:rect];
        _headerView.hidden = YES;
    }
    return _headerView;
}

- (ZFReviewPhotoBrowseView *)photoBrowseView {
    if (!_photoBrowseView) {
        _photoBrowseView = [[ZFReviewPhotoBrowseView alloc] initWithFrame:self.view.window.bounds];
        [self.view.window addSubview:_photoBrowseView];
        @weakify(self);
        _photoBrowseView.hasShowLastPageBlock = ^{
            @strongify(self);
            self.needAppendMorePhotoBrowse = YES;
            [self requestReviewListLoadMore:YES showLoading:NO];
        };
        _photoBrowseView.refreshStatusBarBlock = ^(BOOL show) {
            @strongify(self);
            self.isOpenPhotoBrows = show;
            [self setNeedsStatusBarAppearanceUpdate];
        };
    }
    return _photoBrowseView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = ZFCOLOR_WHITE;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedRowHeight = 160;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.tableHeaderView = self.headerView;
        
        [_tableView registerClass:[ZFGoodsReviewFilterView class] forHeaderFooterViewReuseIdentifier:kZFReviewDetailHeaderViewIdentifier];
        
        [_tableView registerClass:[ZFGoodsDetailReviewInfoTableViewCell class] forCellReuseIdentifier:kZFGoodsDetailReviewInfoTableViewCellIdentifier];
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        @weakify(self);
        [_tableView addHeaderRefreshBlock:^{
            @strongify(self);
            [self requestReviewListLoadMore:NO showLoading:NO];
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self requestReviewListLoadMore:YES showLoading:NO];
            
        } startRefreshing:YES];
    }
    return _tableView;
}

@end
