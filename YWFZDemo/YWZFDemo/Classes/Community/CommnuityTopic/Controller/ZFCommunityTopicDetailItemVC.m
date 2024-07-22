//
//  ZFCommunityTopicDetailVC.m
//  ZZZZZ
//
//  Created by YW on 2018/9/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityTopicDetailItemVC.h"
#import "TZImagePickerController.h"
#import "ZFCommunityAccountViewController.h"
#import "ZFCommunityPostListViewController.h"
#import "ZFCommunityOutfitPostVC.h"
#import "ZFCommunityPostDetailPageVC.h"
#import "ZFCommunityPostReplyViewController.h"

#import "ZFCommunityTopicDetailListCell.h"
#import "ZFShareView.h"
#import "ZFNativeCollectionHeaderView.h"
#import "PostPhotosManager.h"
#import "ZFShare.h"
#import "ZFCommunityPictureModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityPostDetailNavigationView.h"
#import "ZFCommunityZShowView.h"
#import "ZFCommnuityTopicDetailBigCCell.h"

#import "CHTCollectionViewWaterfallLayout.h"

#import "UIViewController+YNPageExtend.h"
#import "YWLocalHostManager.h"
#import "CommunityEnumComm.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

#import "ZFCommunityImageLayoutView.h"
#import "ZFCommunityTopicDetailAOP.h"

@interface ZFCommunityTopicDetailItemVC ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
TZImagePickerControllerDelegate,
ZFShareViewDelegate,
ZFInitViewProtocol,
CHTCollectionViewDelegateWaterfallLayout
>

@property (nonatomic, strong) ZFShareView                           *shareView;
@property (nonatomic, strong) UICollectionView                      *collectionView;

@property (nonatomic, strong) ZFCommunityTopicDetailHeadLabelModel             *topicDetailHeadModel;
@property (nonatomic, strong) ZFCommunityTopicDetailListModel                  *shareDataModel;

@property (nonatomic, strong) ZFCommunityTopicDetailAOP              *analyticsAOP;

@end

@implementation ZFCommunityTopicDetailItemVC

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (self.operateRefreshBlock) {
        self.operateRefreshBlock(NO);
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];

    if (!self.sort) {
        self.sort = @"0";
    }
    
    if (!self.collectionView.superview) {
        [self firstLoadView];
    }
    
    if (!_viewModel) {
        [self.collectionView.mj_header beginRefreshing];
    } else {
        
        [self resetCollection:_viewModel.topicDetailHeadModel];
        NSDictionary *pageInfo = @{kTotalPageKey  : @(self.viewModel.topicDetailModel.pageCount),
                                   kCurrentPageKey: @(self.viewModel.topicDetailModel.curPage) };
        [self.collectionView showRequestTip:pageInfo];
    }
}

- (void)firstLoadView {
    [self zfInitView];
    [self zfAutoLayoutView];
    [self addNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Public method
- (UICollectionView *)querySubScrollView {
    return self.collectionView;
}

- (void)zfInitView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}


/**
 * 注册通知
 */
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStatusChangeValue:) name:kFollowStatusChangeNotification object:nil];
    //接收点赞状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatusChangeValue:) name:kLikeStatusChangeNotification object:nil];
    //接收评论状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviewCountsChangeValue:) name:kReviewCountsChangeNotification object:nil];
    //接收登录状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kLoginNotification object:nil];
    //刷新topicDetail页面
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTopicValue:) name:kRefreshTopicNotification object:nil];
    //接收删除状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteChangeValue:) name:kDeleteStatusChangeNotification object:nil];
    //发帖成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(communityPostSuccessAction) name:kCommunityPostSuccessNotification object:nil];
}

#pragma mark - Request


/**
 topicType 类型不一致,重置创建collection
 */
- (void)resetCollection:(ZFCommunityTopicDetailHeadLabelModel *)topicDetailHeadModel {
    if (topicDetailHeadModel) {
        
        //occ: topicType 类型不一致,重置创建collection
        if ([ZFToString(self.topicType) isEqualToString:@"2"]) {
            if (![ZFToString(topicDetailHeadModel.activity.type) isEqualToString:self.topicType]) {
                
                self.topicType = ZFToString(topicDetailHeadModel.activity.type);
                CHTCollectionViewWaterfallLayout *waterFallLayout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
                waterFallLayout.columnCount = 2;
                waterFallLayout.minimumInteritemSpacing = 12;
            }
        } else if ([ZFToString(topicDetailHeadModel.activity.type) isEqualToString:@"2"] && ([ZFToString(self.sort) isEqualToString:@"0"] || [ZFToString(self.sort) isEqualToString:@"1"])) {
            
            self.topicType = ZFToString(topicDetailHeadModel.activity.type);
            CHTCollectionViewWaterfallLayout *waterFallLayout = (CHTCollectionViewWaterfallLayout *)self.collectionView.collectionViewLayout;
            waterFallLayout.columnCount = 1;
            waterFallLayout.minimumInteritemSpacing = 0;

        }
    }
}

- (void)requestTopicPageData:(BOOL)isFirstPage {
    
    if (isFirstPage) { //同时发送两个请求
        @weakify(self)
        [self.viewModel requestCommunityTopicPageData:ZFToString(self.topicId) reviewId:ZFToString(self.reviewId)
                                             sortType:ZFToString(self.sort)
                                          isFirstPage:YES
                                           completion:^(ZFCommunityTopicDetailHeadLabelModel *topicDetailHeadModel, NSDictionary *pageInfo) {
                                               
                                               @strongify(self)
                                               if ([topicDetailHeadModel isKindOfClass:[ZFCommunityTopicDetailHeadLabelModel class]]) {
                                                   self.topicDetailHeadModel = topicDetailHeadModel;
                                               }
                                               
                                               [self resetCollection:topicDetailHeadModel];
                                               
                                               [self.collectionView reloadData];
                                               [self.collectionView showRequestTip:pageInfo];
                                               if (self.operateRefreshBlock) {
                                                   self.operateRefreshBlock(NO);
                                               }
        }];
        
    } else {
        [self requestTopicCategory:NO];
    }
}

- (void)requestTopicCategory:(BOOL)isFirstPage {
    
    @weakify(self)
    [self.viewModel requestTopicDetailListNetwork:ZFToString(self.topicId)
                                         sortType:ZFToString(self.sort)
                                        topicType:ZFToString(self.topicType)
                                      isFirstPage:isFirstPage completion:^(NSDictionary *pageInfo) {
                                          
                                          @strongify(self)
                                          HideLoadingFromView(self.view);
                                          
                                          [self.collectionView reloadData];
                                          [self.collectionView showRequestTip:pageInfo];
    }];
}

#pragma mark - Notification
/**
 * 发帖成功
 */
- (void)communityPostSuccessAction {
    ShowToastToViewWithText(self.view, ZFLocalizedString(@"Success",nil));
}

/**
 * 刷新topicDetail页面
 */
- (void)refreshTopicValue:(NSNotification *)nofi {
    [self requestTopicPageData:YES];
}

/**
 * 接收关注通知
 */
- (void)followStatusChangeValue:(NSNotification *)noti {
    //接收通知传过来的两个值 dict[@"isFollow"],dict[@"userId"]
    NSDictionary *dict = noti.object;
    BOOL isFollow = [dict[@"isFollow"] boolValue];
    NSString *followedUserId = dict[@"userId"];
    //遍历当前列表数组找到相同userId改变关注按钮状态
    [self.viewModel.dataArray enumerateObjectsUsingBlock:^(ZFCommunityTopicDetailListModel  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:followedUserId]) {
            obj.isFollow = isFollow;
        }
    }];
    [self.collectionView reloadData];
}

/**
 * 接收删除通知
 */
- (void)deleteChangeValue:(NSNotification *)nofi {
    [self requestTopicPageData:YES];
}

/**
 * 接收登录通知
 */
- (void)loginChangeValue:(NSNotification *)nofi {
    [self requestTopicPageData:YES];
}

/**
 * 接收点赞通知
 */
- (void)likeStatusChangeValue:(NSNotification *)nofi {
    //接收通知传过来的model StyleLikesModel
    ZFCommunityStyleLikesModel *likesModel = nofi.object;
    //遍历当前列表数组找到相同reviewId改变点赞按钮状态并且增加或减少点赞数
    [self.viewModel.dataArray enumerateObjectsUsingBlock:^(ZFCommunityTopicDetailListModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reviewsId isEqualToString:likesModel.reviewId]) {
            if (likesModel.isLiked) {
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]+1];
            }else{
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]-1];
            }
            obj.isLiked = likesModel.isLiked;
            *stop = YES;
        }
    }];
    [self.collectionView reloadData];
}

/**
 * 接收评论通知
 */
- (void)reviewCountsChangeValue:(NSNotification *)nofi {
    //接收通知传过来的model StyleLikesModel
    ZFCommunityStyleLikesModel *reviewsModel = nofi.object;
    //遍历当前列表数组找到相同reviewId增加评论数
    [self.viewModel.dataArray enumerateObjectsUsingBlock:^(ZFCommunityTopicDetailListModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reviewsId isEqualToString:reviewsModel.reviewId]) {
            obj.replyCount = [NSString stringWithFormat:@"%d", [obj.replyCount intValue] +1];
        }
    }];
    [self.collectionView reloadData];
}

#pragma mark - 分享相关

- (ZFShareView *)shareView {
    if (!_shareView) {
        _shareView = [[ZFShareView alloc] init];
        _shareView.delegate = self;
        
        ZFShareTopView *shareTopView = [[ZFShareTopView alloc] init];
        [shareTopView updateImage:self.topicDetailHeadModel.iosDetailpic
                            title:ZFLocalizedString(@"ZFShare_Community_topic", nil)
                          tipType:ZFShareDefaultTipTypeCommon];
        _shareView.topView = shareTopView;
        [ZFShareManager authenticatePinterest];
    }
    return _shareView;
}

- (void)zfShsreView:(ZFShareView *)shareView didSelectItemAtIndex:(NSUInteger)index {
    NativeShareModel *model = [[NativeShareModel alloc] init];
    NSString *appCommunityShareURL = [YWLocalHostManager appCommunityShareURL];
    model.share_url = [NSString stringWithFormat:@"%@?actiontype=6&url=3,%@&name=@""&source=sharelink&lang=%@",appCommunityShareURL,self.topicId,[ZFLocalizationString shareLocalizable].nomarLocalizable];
    model.share_imageURL = shareView.topView.imageName;
    model.share_description = shareView.topView.title;
    model.sharePageType = ZFSharePage_CommunityTopicsDetailType;
    model.fromviewController = self;
    [ZFShareManager shareManager].model = model;
    [ZFShareManager shareManager].currentShareType = index;
    switch (index) {
        case ZFShareTypeWhatsApp: {
            [[ZFShareManager shareManager] shareToWhatsApp];
        }
            break;
        case ZFShareTypeFacebook:
        {
            [[ZFShareManager shareManager] shareToFacebook];
        }
            break;
        case ZFShareTypeMessenger:
        {
            [[ZFShareManager shareManager] shareToMessenger];
        }
            break;
        case ZFShareTypePinterest: {
            [[ZFShareManager shareManager] shareToPinterest];
        }
            break;
        case ZFShareTypeCopy:
        {
            [[ZFShareManager shareManager] copyLinkURL];
        }
            break;
        case ZFShareTypeMore: {
            [[ZFShareManager shareManager] shareToMore];
        }
            break;
        case ZFShareTypeVKontakte: {
            [[ZFShareManager shareManager] shareVKontakte];
        }
            break;
    }
}

#pragma mark - action
/**
 * 处理Cell操作事件
 */
- (void)dealWithCellButtonAction:(UIButton *)cellButton detailListModel:(ZFCommunityTopicDetailListModel *)model
{
    switch (cellButton.tag) {
        case likeBtnTag:
        {
            //点击点赞
            [self clickLikeBtnAction:cellButton reviewsModel:model];
        }
            break;
            
        case reviewBtnTag:
        {
            //点击评论
            [self clickReviewBtnAction:model];
        }
            break;
            
        case shareBtnTag:
        {
            //点击分享
            [self clickShareBtnAction:model];
        }
            break;
            
        case followBtnTag:
        {
            //点击关注
            [self clickFollowBtnAction:model];
        }
            break;
        default:
            break;
    }
}


/**
 * 点击头像
 */
- (void)clickUserImage:(ZFCommunityTopicDetailListModel *)reviewsModel
{
    if ([reviewsModel.userId isEqualToString:USERID]) return;
    ZFCommunityAccountViewController *myStyleVC = [ZFCommunityAccountViewController new];
    myStyleVC.userName = ZFToString(reviewsModel.nickname);
    myStyleVC.userId = reviewsModel.userId;
    [self.navigationController pushViewController:myStyleVC animated:YES];
    
    // firebase
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"click_account_%@", reviewsModel.userId] itemName:@"Account" ContentType:@"explore_topic_detail" itemCategory:@"Button"];
}

/**
 * 标签事件
 */
- (void)topicDetailAction:(NSString *)labName
{
    ZFCommunityPostListViewController *topic = [ZFCommunityPostListViewController new];
    topic.topicTitle = labName;
    [self.navigationController pushViewController:topic animated:YES];
}

/**
 * 点击点赞
 */
- (void)clickLikeBtnAction:(UIButton *)btn reviewsModel:(ZFCommunityTopicDetailListModel *)reviewsModel
{    
    @weakify(self)
    [self judgePresentLoginVCCompletion :^{
        @strongify(self)
        
        NSDictionary *dict = @{kLoadingView : self.view,
                               kRequestModelKey  : reviewsModel};
        [self.viewModel requestLikeNetwork:dict completion:^(id obj) {
        } failure:^(id obj) {
        }];
    } cancelCompetion:^{
    }];
    
    // firebase
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"click_like_%@", reviewsModel.reviewsId] itemName:@"like" ContentType:@"explore_topic_detail" itemCategory:@"Button"];
}

/**
 * 点击评论
 */
- (void)clickReviewBtnAction:(ZFCommunityTopicDetailListModel *)reviewsModel
{
    @weakify(self)
    [self judgePresentLoginVCCompletion:^{
        @strongify(self)

        ZFCommunityPostReplyViewController *replyCtrl = [[ZFCommunityPostReplyViewController alloc] initWithReviewID:reviewsModel.reviewsId];
        [self.navigationController pushViewController:replyCtrl animated:YES];
    }];
    
    // firebase
    [ZFFireBaseAnalytics selectContentWithItemId:@"click_review" itemName:@"review" ContentType:@"explore_topic_detail" itemCategory:@"Button"];
}

/**
 * 点击分享
 */
- (void)clickShareBtnAction:(ZFCommunityTopicDetailListModel *)reviewsModel
{
    self.shareDataModel = reviewsModel;
    [self configureShareTopView];
    [self.shareView open];
    
    // firebase
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"click_share_%@", reviewsModel.reviewsId] itemName:@"share" ContentType:@"explore_topic_detail" itemCategory:@"Button"];
}


- (void)configureShareTopView {
    ZFCommunityPictureModel *model = self.shareDataModel.reviewPic.firstObject;
    ZFShareTopView *shareTopView = [[ZFShareTopView alloc] init];
    [shareTopView updateImage:model.bigPic
                        title:self.shareDataModel.content
                      tipType:ZFShareDefaultTipTypeCommon];
    self.shareView.topView = shareTopView;
}


/**
 * 点击关注
 */
- (void)clickFollowBtnAction:(ZFCommunityTopicDetailListModel *)reviewsModel
{
    @weakify(self)
    [self judgePresentLoginVCCompletion:^{
        @strongify(self)
        
        NSDictionary *dict = @{kLoadingView : self.view,
                               @"model"  : reviewsModel };
        [self.viewModel requestFollowNetwork:dict completion:^(id obj) {
            // [tableView reloadData];
        } failure:^(id obj) {
            
        }];
    }];
    
    // firebase
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"click_follow_%@", reviewsModel.userId] itemName:@"follow" ContentType:@"explore_topic_detail" itemCategory:@"Button"];
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityTopicDetailListModel *reviewsModel;
    
    if (self.viewModel.dataArray.count > indexPath.row) {
        reviewsModel = self.viewModel.dataArray[indexPath.row];
    }
    
    // 话题是穿搭，且是 RANKING/LATEAST列表
    if (reviewsModel.isABBigCell) {//穿搭话题贴
        ZFCommnuityTopicDetailBigCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommnuityTopicDetailBigCCell class]) forIndexPath:indexPath];
        
        // Rank 前3个显示标识
        reviewsModel.isShowMark = [ZFToString(self.sort) integerValue] == TopicDetailSortTypeRanking ? YES : NO;
        cell.model = reviewsModel;

        @weakify(self)
        cell.tapEventBlock = ^(CommunityTopicDetailCellEvent event, ZFCommunityTopicDetailListModel *model, UIButton *sender) {
            @strongify(self)
            if (event == CommunityTopicDetailCellEventUserImage) {
                [self clickUserImage:model];
                
            } else if (event == CommunityTopicDetailCellEventFllow) {
                [self clickFollowBtnAction:model];
                
            } else if (event == CommunityTopicDetailCellEventLike) {
                [self clickLikeBtnAction:sender reviewsModel:model];
                
            } else if (event == CommunityTopicDetailCellEventReview) {
                [self clickReviewBtnAction:model];
                
            } else if (event == CommunityTopicDetailCellEventShare) {
                [self clickShareBtnAction:model];
            }
        };
        
        cell.tapLabBlock = ^(NSString *labName) {
            @strongify(self)
            [self topicDetailAction:labName];
        };
        return cell;
    }
    
    ZFCommunityTopicDetailListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityTopicDetailListCell class]) forIndexPath:indexPath];
    if (self.viewModel.dataArray.count > indexPath.row) {
        reviewsModel = self.viewModel.dataArray[indexPath.row];
        cell.model = reviewsModel;
    }
    
    @weakify(self)
    /*-*-*-*-*-*-*-*-*-*点击头像判断是否要跳转-*-*-*-*-*-*-*-*-*/
    cell.communtiyMyStyleBlock = ^{
        @strongify(self)
        [self clickUserImage:reviewsModel];
    };
    /*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*/
    
    cell.topicDetailBlock = ^(NSString *labName){
        @strongify(self)
        [self topicDetailAction:labName];
    };
    
    /*-*-*-*-*-*-*-*-*-*点赞,评论,分享点击事件-*-*-*-*-*-*-*-*-*/
    cell.clickEventBlock = ^(UIButton *btn, ZFCommunityTopicDetailListModel *model) {
        @strongify(self)
        [self dealWithCellButtonAction:btn detailListModel:model];
    };
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.viewModel.dataArray.count > indexPath.row) {
        ZFCommunityTopicDetailListModel *reviewsModel = self.viewModel.dataArray[indexPath.row];
        ZFCommunityPostDetailPageVC *detailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:reviewsModel.reviewsId title:ZFLocalizedString(@"Community_Videos_DetailTitle",nil)];

        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}


#pragma mark -===CHTCollectionViewDelegateWaterfallLayout===


/**
 * 每个Item的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.viewModel.dataArray.count <= indexPath.row) return CGSizeZero;
    ZFCommunityTopicDetailListModel *showsModel = self.viewModel.dataArray[indexPath.row];
    if (showsModel) {
        if (showsModel.isABBigCell) {
            return showsModel.oneColumnCellSize;
        }
        return showsModel.twoColumnCellSize;
    }
    return CGSizeZero;
}

/**
 * 每个section之间的缩进间距
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{

    if ([ZFToString(self.topicType) isEqualToString:@"2"] && ([ZFToString(self.sort) isEqualToString:@"0"] || [ZFToString(self.sort) isEqualToString:@"1"])) {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    return UIEdgeInsetsMake(12, 12, 12, 12);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section {

//    return KScreenHeight - NAVBARHEIGHT - kiphoneXTopOffsetY - 44;
    if (self.viewModel.dataArray.count > 0) {
        return 0;
    }
//    return [self placeHolderCellHeight];

    
    return  KScreenHeight - NAVBARHEIGHT - kiphoneXTopOffsetY - 44;
}


#pragma mark - 求出占位cell高度 未用
- (CGFloat)placeHolderCellHeight {
    
    NSMutableArray *attributeList = [NSMutableArray arrayWithCapacity:self.viewModel.dataArray.count];
    CGFloat bottomOffset = 0.0;
    for (int i = 0; i < self.viewModel.dataArray.count; i++) {
        
        ZFCommunityTopicDetailListModel *showsModel = self.viewModel.dataArray[0];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        CGFloat x = 0.0;
        if (i == 0) {
            x = 10;
            
        }else{
            UICollectionViewLayoutAttributes *lastattributes = attributeList[i - 1];
            x = CGRectGetMaxX(lastattributes.frame);
        }
        
        UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributes.frame = CGRectMake(x, bottomOffset, showsModel.twoColumnCellSize.width, showsModel.twoColumnCellSize.height);
        bottomOffset = floorf(CGRectGetMaxY(attributes.frame));
        [attributeList addObject:attributes];
    }
    
    CGFloat height = self.config.contentHeight - bottomOffset;
    height = height < 0 ? 0 : height;
    return height;
}

#pragma mark - getter/setter

- (ZFCommunityTopicDetailNewViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityTopicDetailNewViewModel alloc] init];
    }
    return _viewModel;
}

- (UICollectionView *)collectionView {
    if(!_collectionView){
        
        CHTCollectionViewWaterfallLayout *waterfallLayout = [[CHTCollectionViewWaterfallLayout alloc] init]; //创建布局
        waterfallLayout.minimumColumnSpacing = 13;
        waterfallLayout.minimumInteritemSpacing = 12;
        waterfallLayout.headerHeight = 0;
        
        if ([ZFToString(self.topicType) isEqualToString:@"2"] && ([ZFToString(self.sort) isEqualToString:@"0"] || [ZFToString(self.sort) isEqualToString:@"1"])) {
            waterfallLayout.columnCount = 1;
            waterfallLayout.minimumInteritemSpacing = 0;
        }
        
        
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:waterfallLayout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = YES;
        
        _collectionView.blankPageTipViewOffsetY = 200;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_collectionView registerClass:[ZFCommunityTopicDetailListCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityTopicDetailListCell class])];
        [_collectionView registerClass:[ZFCommnuityTopicDetailBigCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommnuityTopicDetailBigCCell class])];
        
        @weakify(self);
        [self.collectionView addCommunityHeaderRefreshBlock:^{
            @strongify(self);
            [self requestTopicPageData:YES];
            if (self.operateRefreshBlock) {
                self.operateRefreshBlock(YES);
            }
            
        } footerRefreshBlock:^{
            @strongify(self);
            [self requestTopicCategory:NO];
            
        } startRefreshing:NO];
    }
    return _collectionView;
}

- (ZFCommunityTopicDetailAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCommunityTopicDetailAOP alloc] init];
        [_analyticsAOP baseConfigureChannelId:self.sort channelName:self.channelName];
    }
    return _analyticsAOP;
}
@end
