//
//  ZFCommunityPostDetailPageItemVC.m
//  ZZZZZ
//
//  Created by YW on 2019/1/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityPostDetailPageItemVC.h"

#import "ZFGoodsDetailViewController.h"
#import "ZFCommunitySameGoodsPageController.h"
#import "ZFCommunityPostListViewController.h"
#import "ZFCommunityAccountViewController.h"
#import "ZFCommunityPostReplyViewController.h"
#import "ZFWebViewViewController.h"
#import "ZFCartViewController.h"
#import "ZFCommunityPostDetailPageVC.h"

#import "CHTCollectionViewWaterfallLayout.h"

#import "ZFCommunityPostDetailUserView.h"
#import "ZFCommunityPostDetailBottomView.h"
#import "ZFPostDetailSimilarGoodsView.h"
#import "YYPhotoBrowseView.h"
#import "ZFShareView.h"
#import "ZFGoodsDetailSelectTypeView.h"
#import "ZFCommunityPostDetailWriteCommentView.h"
#import "ZFCommentPostDetailMoreCommentView.h"


#import "ZFCommunityPostDetailPicCCell.h"
#import "ZFCommunityPostDetailDescriptCollectionReusableView.h"
#import "ZFPostDetailTileCollectionReusableView.h"
#import "ZFPostDetailSimilarGoodsCell.h"
#import "ZFCommunityPostDetailRecommendGoodsCCell.h"
#import "ZFCommunityPostCollectionViewCell.h"
#import "ZFCommunityPostDetailCommentCCell.h"
#import "ZFActionSheetView.h"

#import "ZFShareManager.h"
#import "NativeShareModel.h"
#import "ZFGoodsDetailViewModel.h"
#import "ZFCommunityPostDetailViewModel.h"
#import "ZFCommunityPostOperateViewModel.h"
#import "ZFCommunityStyleLikesModel.h"
#import "ZFCommunityPostDetailModel.h"
#import "ZFCommunityGoodsInfosModel.h"
#import "ZFCommunityGoodsOperateViewModel.h"
#import "ZFCommentPostReviewCommentViewModel.h"

#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFInitViewProtocol.h"
#import "ZFPopDownAnimation.h"
#import "SystemConfigUtils.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "YWCFunctionTool.h"
#import "YWLocalHostManager.h"
#import "UIView+LayoutMethods.h"
#import "ZFFrameDefiner.h"
#import "MF_Base64Additions.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "ZFApiDefiner.h"
#import "ZFProgressHUD.h"
#import <Masonry/Masonry.h>
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFGrowingIOAnalytics.h"
#import "BannerManager.h"
#import "JumpManager.h"
#import "NSString+Extended.h"
#import "ZFBTSManager.h"
#import "ZFThemeManager.h"
#import "ZFBranchAnalytics.h"
#import "ZFCommunityPostDetailAOP.h"

#import "ZFCommunityLikeAnimateView.h"
#import "ZFFireBaseAnalytics.h"

static CGFloat const kUserInfoHeight = 64.0;

@interface ZFCommunityPostDetailPageItemVC ()
<
ZFInitViewProtocol,
UICollectionViewDelegate,
UICollectionViewDataSource,
CHTCollectionViewDelegateWaterfallLayout,
ZFShareViewDelegate>

@property (nonatomic, strong) UICollectionView                      *detailCollectionView;
@property (nonatomic, strong) ZFCommunityPostDetailUserView        *userInfoView;
@property (nonatomic, strong) ZFCommunityPostDetailBottomView      *bottomView;
@property (nonatomic, strong) ZFPostDetailSimilarGoodsView         *similarGoodsView;
/*分享视图*/
@property (nonatomic, strong) ZFShareView                           *shareView;
@property (nonatomic, strong) ZFGoodsDetailSelectTypeView           *attributeView;

@property (nonatomic, strong) ZFCommunityPostDetailViewModel       *viewModel;
@property (nonatomic, strong) ZFCommunityPostOperateViewModel              *interfaceViewModel;
@property (nonatomic, strong) ZFGoodsDetailViewModel                *goodsDetailViewModel;

@property (nonatomic, assign) BOOL                                  isMyTopic;
@property (nonatomic, assign) CGFloat                               currentOffsetY;
@property (nonatomic, strong) NSIndexPath                           *userInfoIndexPath;
@property (nonatomic, copy) NSArray                                 *relatedArray;

@property (nonatomic, strong) ZFCommunityGoodsInfosModel                       *currentSelectSimilarGoodsModel;
@property (nonatomic, strong) UIButton                              *imageViewAllButton;

@property (nonatomic, assign) BOOL                                  isLikeHandling;

@property (nonatomic, strong) ZFCommunityPostDetailAOP              *analyticsAOP;

@property (nonatomic, strong) ZFCommentPostReviewCommentViewModel   *commentViewModel;


@end

@implementation ZFCommunityPostDetailPageItemVC

#pragma mark - Life Cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_shareView) {
        [self.shareView removeFromSuperview];
        self.shareView.delegate = nil;
        self.shareView = nil;
    }
}

- (instancetype)initWithReviewID:(NSString *)reviewID title:(NSString *)titleString {
    if (self = [super init]) {
        self.reviewID = reviewID;
        self.title    = titleString;
    }
    return self;
}


- (instancetype)initWithReviewID:(NSString *)reviewID {
    if (self = [self initWithReviewID:reviewID title:@""]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.fd_prefersNavigationBarHidden = YES;
    self.currentOffsetY = 0;
    
    self.commentViewModel = [[ZFCommentPostReviewCommentViewModel alloc] init];

    [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:self.analyticsAOP];

    [self zfInitView];
    [self zfAutoLayoutView];
    
    if (_viewModel) {
        self.viewModel.sourceType = self.sourceType;
        [self handleTopicDetailResult];
    } else {
        self.viewModel = [[ZFCommunityPostDetailViewModel alloc] init];
        self.viewModel.sourceType = self.sourceType;
        self.viewModel.controller = self;
        [self requestDatas];
    }
    
    [self addNotification];
    [self analyticsCheckPostView];
    
    // 阿语时: 外部容器控制器已翻转, 自控制器需要再次翻转显示才正确
    if ([SystemConfigUtils isRightToLeftShow]) {
        self.view.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self permitScrollSetting];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 收起弹窗
    [self.similarGoodsView dismiss];
    [self.bottomView setRelateUnselected];
    [self.attributeView hideSelectTypeView];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.viewModel sectionCount];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel baseSectionWithSection:section].rowCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFTopicSectionType sectionType = [self.viewModel sectionTypeInSection:indexPath.section];
    switch (sectionType) {
        case ZFTopicSectionTypePic: {
            ZFCommunityPostDetailPicCCell *cell = [ZFCommunityPostDetailPicCCell picCellWithCollectionView:collectionView indexPath:indexPath];
            [cell configWithPicURL:[self.viewModel picURLInIndexPath:indexPath]];
            @weakify(self);
            cell.picTapBlock = ^(BOOL isDouble) {
                @strongify(self);
                [self actionPicCellIndexPath:indexPath tapState:isDouble];
            };
            return cell;
            break;
        }
        case ZFTopicSectionTypeSimilar: {
            
            ZFCommunityTopicDetailSimilarSection *similarSection = [self.viewModel similarSectionWithSection:indexPath.section];
            
            ZFCommunityPostDetailRecommendGoodsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFCommunityPostDetailRecommendGoodsCCell" forIndexPath:indexPath];
            cell.similarSection = similarSection;
            @weakify(self)
            cell.recommendGoodsClick = ^(ZFCommunityGoodsInfosModel *infosModel) {
                @strongify(self)
                ZFGoodsDetailViewController *goodsDetailViewController = [[ZFGoodsDetailViewController alloc] init];
                goodsDetailViewController.goodsId = ZFToString(infosModel.goodsId);
                //occ v3.7.0hacker 添加 ok
                goodsDetailViewController.analyticsProduceImpression = self.viewModel.analyticsProduceImpression;
                goodsDetailViewController.sourceType = ZFAppsflyerInSourceTypeZMePostDetailRecommend;
                goodsDetailViewController.sourceID = ZFToString(self.reviewID);
                [self.navigationController pushViewController:goodsDetailViewController animated:YES];
                [self.viewModel clickGoodsAdGAWithIndexPath:indexPath];
            
                // appflyer统计
                NSString *spuSN = @"";
                if (infosModel.goods_sn.length > 7) {  // sn的前7位为同款id
                    spuSN = [infosModel.goods_sn substringWithRange:NSMakeRange(0, 7)];
                }else{
                    spuSN = infosModel.goods_sn;
                }
                NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(infosModel.goods_sn),
                                                  @"af_spu_id" : ZFToString(spuSN),
                                                  @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                                  @"af_page_name" : @"post_detail",    // 当前页面名称
                                                  };
                [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
                
                [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{
                    GIOGoodsTypeEvar : GIOGoodsTypeCommunity,
                    GIOGoodsNameEvar : [NSString stringWithFormat:@"recommend_zme_%@_%@", [self getGrowingPostType:self.sourceType], self.reviewID]
                }];
                
                // 请求统计商品点击
                [ZFCommunityGoodsOperateViewModel requestGoodsTap:@{@"reviewId":ZFToString(self.reviewID),
                                                                    @"goods_sku":ZFToString(infosModel.goods_sn)} completion:nil];
            };
            return cell;
           
            break;
        }
        case ZFTopicSectionTypeRelated: {
            ZFCommunityPostCollectionViewCell *cell = [ZFCommunityPostCollectionViewCell topicCellWithCollectionView:collectionView indexPath:indexPath];
            
            [cell configWithViewModel:self.viewModel indexPath:indexPath];
            @weakify(self)
            cell.likeTopicHandle = ^{
                @strongify(self)
                @weakify(self)
                [self judgePresentLoginVCCompletion:^{
                    @strongify(self)
                    [self requestLikeWithIndexPath:indexPath showLoading:YES resultBlock:nil];
                }];
            };
            return cell;
            break;
        }
        case ZFTopicSectionTypeReview: {
            ZFCommunityPostDetailCommentCCell *cell = [ZFCommunityPostDetailCommentCCell commentCellWithCollectionView:collectionView indexPath:indexPath];
            
            ZFCommunityPostDetailReviewsListMode *model = [self.viewModel commentModelWithSection:indexPath];
            [cell configWithViewModel:model];
            return cell;
            break;
        }
        default:
            break;
    }
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        ZFTopicSectionType sectionType = [self.viewModel sectionTypeInSection:indexPath.section];
        switch (sectionType) {
            case ZFTopicSectionTypeDescrip: {
                ZFCommunityPostDetailDescriptCollectionReusableView *headerView = [ZFCommunityPostDetailDescriptCollectionReusableView descriptWithCollectionView:collectionView indexPath:indexPath];
                [self configContenDatas:headerView indexPath:indexPath];
                @weakify(self)
                headerView.tagActionHandle = ^(NSString *tagString) {
                    @strongify(self)
                    ZFCommunityPostListViewController *topic = [ZFCommunityPostListViewController new];
                    topic.topicTitle = tagString;
                    [self.navigationController pushViewController:topic animated:YES];
                };
                headerView.deeplinkHandle = ^(NSString *deeplinkUrl) {
                    @strongify(self)
                    [self jumpDeeplinkUrlAction:deeplinkUrl];
                };
                return headerView;
                break;
            }
            case ZFTopicSectionTypeUserInfo: {
                ZFCommunityPostDetailUserView *headerView = [ZFCommunityPostDetailUserView userHeaderViewWithCollectionView:collectionView indexPath:indexPath];
                [self configUserInfo:headerView indexPath:indexPath];
                self.userInfoIndexPath = indexPath;
                [self userInfoActionWithUserView:headerView];
                return headerView;
                break;
            }
            case ZFTopicSectionTypeSimilar: {
                ZFPostDetailTileCollectionReusableView *headerView = [ZFPostDetailTileCollectionReusableView titleHeaderViewWithCollectionView:collectionView indexPath:indexPath type:ZFTopicDetailTitleTypeSimilar];
                
                @weakify(self)
                headerView.moreActionHandle = ^{
                    @strongify(self)
                    [self jumpToSameGoodsAction];
                };
                return headerView;
                break;
            }
            case ZFTopicSectionTypeRelated: {
                ZFTopicDetailTitleType type = [self.viewModel reviewType] == 0 ? ZFTopicDetailTitleTypeNomarlRelated : ZFTopicDetailTitleTypeOutfitRelated;
                ZFPostDetailTileCollectionReusableView *headerView = [ZFPostDetailTileCollectionReusableView titleHeaderViewWithCollectionView:collectionView indexPath:indexPath type:type];
                return headerView;
                break;
            }
            case ZFTopicSectionTypeReview: {
                ZFCommunityPostDetailWriteCommentView *headerView = [ZFCommunityPostDetailWriteCommentView writeCommentHeaderViewWithCollectionView:collectionView indexPath:indexPath];
                
                ZFCommunityTopicDetailCommentSection *commentSection = [self.viewModel commentSectionWithSection:indexPath.section];
                if (commentSection) {
                    
                    NSString *avatar = ZFToString([AccountManager sharedManager].account.avatar);
                    [headerView configWithImageUrl:avatar text:commentSection.text];
                }
                
//                @weakify(commentSection)
//                headerView.textBlock = ^(NSString *text) {
//                    @strongify(commentSection)
//                    commentSection.text = ZFToString(text);
//                };
                
                @weakify(self)
                headerView.textTapBlock = ^{
                    @strongify(self)
                    [self jumpPostReplyWithEdit:YES];
                };
                return headerView;
                break;
            }
            default:
                break;
        }
    } else {
        ZFTopicSectionType sectionType = [self.viewModel sectionTypeInSection:indexPath.section];
        if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
            if (sectionType == ZFTopicSectionTypeReview) {
                
                ZFCommunityTopicDetailCommentSection *commentSection = [self.viewModel commentSectionWithSection:indexPath.section];
                if (commentSection && commentSection.rowCount >= 2 && commentSection.allCount > 2) {
                    ZFCommentPostDetailMoreCommentView *moreCommentView = [ZFCommentPostDetailMoreCommentView commentPostDetailMoreCommentViewWithCollectionView:collectionView indexPath:indexPath];
                    [moreCommentView configurateNums:commentSection.allCount];
                    
                    @weakify(self)
                    moreCommentView.tapMoreBlock = ^{
                      @strongify(self)
                        [self jumpPostReplyWithEdit:NO];
                    };
                    return moreCommentView;
                }
            }
        }
    }
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
    headerView.backgroundColor = ZFC0xF2F2F2();
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFTopicSectionType sectionType = [self.viewModel sectionTypeInSection:indexPath.section];
    if (sectionType == ZFTopicSectionTypeRelated) {
        NSString *reviewID = [[self.viewModel relateSectionWithSection:indexPath.section] topicIDNumWithIndex:indexPath.item];
        ZFCommunityPostDetailPageVC *detailViewController = [[ZFCommunityPostDetailPageVC alloc] initWithReviewID:reviewID title:ZFLocalizedString(@"Community_Videos_DetailTitle",nil)];
        
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

#pragma mark - CHTCollectionViewDelegateWaterfallLayout
/**
 * 每个section中显示Item的列数, 默认为瀑布流显示两列
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section {
    return [self.viewModel baseSectionWithSection:section].columnCount;
}

/**
 * 每个Item的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel itemSizeWithIndexPath:indexPath];
}

/**
 * 每个section中item的横向间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return [self.viewModel baseSectionWithSection:section].minimumLineSpacing;
}

/**
 * 每个section中item的纵向间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumColumnSpacingForSectionAtIndex:(NSInteger)section {
    return [self.viewModel baseSectionWithSection:section].minimumInteritemSpacing;
}

/**
 * 每个section之间的缩进间距
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return [self.viewModel baseSectionWithSection:section].edgeInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section {
    return [self.viewModel baseSectionWithSection:section].headerSize.height;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section {
    return [self.viewModel baseSectionWithSection:section].footerSize.height;
}

#pragma mark - UIScrollDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.currentOffsetY = self.detailCollectionView.contentOffset.y;
    if (self.contentOffsetBlock) {
        self.contentOffsetBlock(self.currentOffsetY);
    }
    // 用户信息悬浮
    if (self.userInfoIndexPath) {
        UICollectionViewLayoutAttributes *attributes = [self.detailCollectionView layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:self.userInfoIndexPath];
        self.userInfoView.hidden = self.currentOffsetY < (attributes.frame.origin.y - kiphoneXTopOffsetY - 44.0 + self.detailCollectionView.y);
    }
}

#pragma mark - ZFShareViewDelegate
- (void)zfShsreView:(ZFShareView *)shareView didSelectItemAtIndex:(NSUInteger)index
{
    NSString *appCommunityShareURL = [YWLocalHostManager appH5BaseURL];
    
    NSString *postShareLinkId = ZFToString([AccountManager sharedManager].account.link_id);
    NativeShareModel *model = [[NativeShareModel alloc] init];
    model.share_url =  [NSString stringWithFormat:@"%@%@?reviewid=%@&uid=%@&lkid=%@&lang=%@",appCommunityShareURL,ZFCommunityPostsDetail,self.reviewID,ZFToString([self.viewModel userID]).base64String  ,postShareLinkId,[ZFLocalizationString shareLocalizable].nomarLocalizable];
    model.fromviewController = self;
    model.share_imageURL = shareView.topView.imageName;
    model.share_description = shareView.topView.title;
    model.sharePageType = ZFSharePage_CommunityPostDetailType;
    [ZFShareManager shareManager].model = model;
    [ZFShareManager shareManager].currentShareType = index;
    
    switch (index) {
        case ZFShareTypeWhatsApp: {
            [[ZFShareManager shareManager] shareToWhatsApp];
        }
            break;
        case ZFShareTypeFacebook: {
            [[ZFShareManager shareManager] shareToFacebook];
        }
            break;
        case ZFShareTypeMessenger: {
            [[ZFShareManager shareManager] shareToMessenger];
        }
            break;
        case ZFShareTypePinterest: {
            [[ZFShareManager shareManager] shareToPinterest];
        }
            break;
        case ZFShareTypeCopy: {
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
    //需求: 统计分享, 不管成功失败一点击就统计
    [self shareSuccessAppsFlyerEventByType:index];
}

/**
 * 统计分享facebook, Message事件
 */
- (void)shareSuccessAppsFlyerEventByType:(ZFShareType)shareType {
    NSString *share_channel = [ZFShareManager fetchShareTypePlatform:shareType];
    if (ZFIsEmptyString(share_channel)) return;
    
    share_channel = [NSString stringWithFormat:@"Shared on %@", share_channel];
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId] = ZFToString(@"unKnow");//@陈佳佳:说这里没有sn就传空
    valuesDic[AFEventParamContentType] = ZFToString(share_channel);
    valuesDic[@"af_country_code"] = ZFToString([AccountManager sharedManager].accountCountryModel.region_code);
    valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:self.sourceType sourceID:nil];
    [ZFAnalytics appsFlyerTrackEvent:@"af_share" withValues:valuesDic];
    // branch统计
    NSString *type = [ZFShareManager fetchShareTypePlatform:shareType];
    [[ZFBranchAnalytics sharedManager] branchAnalyticsPostShareWithPostId:self.reviewID postType:self.isOutfits ? @"outfit" : @"show" shareType:type];
}

#pragma mark - Notification

/**
 评论数通知响应
 */
- (void)reviewCountsChangeValue:(NSNotification *)note {
    [self requestDatas];
}

/**
 关注通知响应
 */
- (void)followStatusChangeValue:(NSNotification *)note {
    NSDictionary *dict = note.object;
    BOOL isCurrentVC = [dict ds_boolForKey:kIsCurrentVC];
    if (!isCurrentVC) {
        BOOL isFollow = [dict[@"isFollow"] boolValue];
        [self.viewModel setIsFollow:isFollow];
        [self.detailCollectionView reloadData];
    }
}

/**
 接收通知传过来的model StyleLikesModel
 */
- (void)likeStatusChangeValue:(NSNotification *)nofi
{
    ZFCommunityStyleLikesModel *likesModel = nofi.object;
    if (!likesModel.kIsCurrentVC) {
        [self.relatedArray enumerateObjectsUsingBlock:^(ZFCommunityPostListInfoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.reviewId isEqualToString:likesModel.reviewId]) {
                if (likesModel.isLiked) {
                    obj.likeCount = obj.likeCount + 1;
                } else {
                    obj.likeCount = obj.likeCount - 1;
                }
                obj.isLiked = likesModel.isLiked;
            }
        }];
        
        if ([likesModel.reviewId isEqualToString:self.reviewID]) {
            if (likesModel.isLiked) {
                [self.viewModel setLikeNumberWithChangeNumber:1];
            } else {
                [self.viewModel setLikeNumberWithChangeNumber:-1];
            }
            [self.viewModel setIsLike:likesModel.isLiked];
        }
        [self.viewModel setGoodsInfoArray:self.relatedArray];
        [self.detailCollectionView reloadData];
    }
    [self configBottomDatas];
}

- (void)loginChangeValue:(NSNotification *)note {
    [self requestDatas];
}


#pragma mark - Action

- (void)backItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)changeCartNumAction {
    [self.attributeView changeCartNumberInfo];
}

- (void)shopGoodsAction:(ZFCommunityGoodsInfosModel *)goodsModel {
    
    if (self.attributeView.superview) {
        [self.attributeView.superview bringSubviewToFront:self.attributeView];
    }

    
    self.currentSelectSimilarGoodsModel = goodsModel;
    //获取商品详情接口
    @weakify(self)
    [self requestGoodsDetailInfo:ZFToString(goodsModel.goodsId) successBlock:^(GoodsDetailModel *goodsDetailInfo) {
        @strongify(self)
        self.attributeView.model = goodsDetailInfo;
        [self.attributeView openSelectTypeView];
    }];
}

/**
 * 删除帖子
 */
- (void)deleteDetailAction {
    NSDictionary *dic = @{@"model" : [self.viewModel communityDetailModel],
                          kLoadingView : self.view};
    @weakify(self)
    ShowLoadingToView(self.view);
    [self.interfaceViewModel requestDeleteNetwork:dic completion:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
        if ([obj boolValue]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(id obj) {
        @strongify(self)
        HideLoadingFromView(self.view);
    }];
}


- (void)jumpDeeplinkUrlAction:(NSString *)deeplinkUrl {
    if (ZFIsEmptyString(deeplinkUrl)) {
        return;
    }

    NSString *strUrlString = ZFUnescapeString(deeplinkUrl);
    NSURL *banner_url = [NSURL URLWithString:strUrlString];
    
    NSString *scheme = [banner_url scheme];
    
    if ([scheme isEqualToString:kZZZZZScheme]) {
        NSMutableDictionary *deeplinkDic = [BannerManager parseDeeplinkParamDicWithURL:banner_url];
        [BannerManager jumpDeeplinkTarget:self deeplinkParam:deeplinkDic];
        return;
    }
    
    if ([strUrlString hasPrefix:@"http"]) {
        ZFWebViewViewController *webViewVC = [[ZFWebViewViewController alloc] init];
        webViewVC.link_url = strUrlString;
        [self.navigationController pushViewController:webViewVC animated:YES];
    }
    
    
}

- (void)jumpToSameGoodsAction {
    ZFCommunitySameGoodsPageController *theSameGoodsViewController = [[ZFCommunitySameGoodsPageController alloc] initWithReviewID:ZFToString(self.reviewID)];
    [self.navigationController pushViewController:theSameGoodsViewController animated:YES];
}

- (void)actionPicCellIndexPath:(NSIndexPath *)indexPath tapState:(BOOL)isDouble{
    
    //在处理、动画中时，不处理事件
    if ([ZFCommunityLikeAnimateView shareManager].isAnimating) {//
        return;
    }
    
    ZFCommunityPostDetailPicCCell *cell = (ZFCommunityPostDetailPicCCell *)[self.detailCollectionView cellForItemAtIndexPath:indexPath];
    if (isDouble) {
        
        @weakify(self);
        [self judgePresentLoginVCCompletion:^{
            @strongify(self)
            
            [[ZFCommunityLikeAnimateView shareManager] showview:cell.imageView completion:^{
            }];
            
            //震动反馈
            ZFPlaySystemQuake();
            
            if (![self.viewModel isLiked] && !self.isLikeHandling) {//不取消
                self.isLikeHandling = YES;
                @weakify(self);
                [self requestLikeWithIndexPath:nil showLoading:NO resultBlock:^(BOOL state) {
                    @strongify(self);
                    self.isLikeHandling = NO;
                }];
            }
        }];
        
    } else {
        
        CGRect beginFrame = [self.detailCollectionView convertRect:cell.frame toView:[UIApplication sharedApplication].keyWindow];
        
        YYPhotoBrowseView *groupView   = [[YYPhotoBrowseView alloc] initWithGroupItems:[self.viewModel collectionView:self.detailCollectionView picItemWithIndexPath:indexPath beginFrame:beginFrame]];

        groupView.isSaveImage          = YES;
        groupView.blurEffectBackground = NO;
        
        YYAnimatedImageView *currentImageView = [self.viewModel currentShowImageView:indexPath placeHolder:cell.imageView.image];
        if (self.imageViewAllButton.superview) {
            [self.imageViewAllButton removeFromSuperview];
            self.imageViewAllButton.hidden = YES;
        }
        @weakify(groupView)
        groupView.startDismissCompletion = ^(NSInteger currentPage) {
            @strongify(groupView)
            if (self.imageViewAllButton.isHidden) {
                groupView.hidden = YES;
            }
            if (self.imageViewAllButton.superview) {
                [self.imageViewAllButton removeFromSuperview];
                self.imageViewAllButton.hidden = YES;
            }
        };
        [groupView presentFromImageView:currentImageView toContainer:self.navigationController.view animated:YES completion:^{
            @strongify(groupView)
            self.imageViewAllButton.hidden = NO;
            [groupView addSubview:self.imageViewAllButton];
            [self.imageViewAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(groupView.mas_right).offset(-15);
                make.bottom.mas_equalTo(groupView.mas_bottom).offset(-103);
                make.height.mas_equalTo(30);
            }];
        }];
    }
    
}


// 详情图片上的view item事件
- (void)actionViewItems:(UIButton *)sender {
    sender.hidden = YES;

    UIView *viewItemsSuperView = sender.superview;
    if ([viewItemsSuperView isKindOfClass:[YYPhotoBrowseView class]]) {
        YYPhotoBrowseView *phontoBrowsviews = (YYPhotoBrowseView *)viewItemsSuperView;
        [phontoBrowsviews dismiss];
    }
    [self jumpToSameGoodsAction];
}

- (void)jumpPostReplyWithEdit:(BOOL)isEdit {
    
    ZFCommunityPostReplyViewController *topicReplyViewController = [[ZFCommunityPostReplyViewController  alloc] initWithReviewID:self.reviewID];
    topicReplyViewController.isOutfits = [@([self.viewModel reviewType]) boolValue];
    topicReplyViewController.isEditing = isEdit;
    
    topicReplyViewController.replayCommentBlock = ^(ZFCommunityPostDetailReviewsListMode *model) {
    };
    
    ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:topicReplyViewController];
    if (@available(iOS 13.0, *)) {
        topicReplyViewController.is_13PresentationAutomatic = YES;
        nav.modalPresentationStyle = UIModalPresentationAutomatic;
    }
    
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - Private Method

- (void)zfInitView {
    [self.view addSubview:self.detailCollectionView];
    [self.view addSubview:self.userInfoView];
    [self.view addSubview:self.bottomView];
    
    if ([self.parentViewController isKindOfClass:[WMPageController class]]) {
        [self.parentViewController.view addSubview:self.attributeView];
    } else {
        [self.view addSubview:self.attributeView];
    }

}

- (void)zfAutoLayoutView {
    //默认设置隐藏
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset([ZFCommunityPostDetailBottomView defaultHeight]);
        make.height.mas_equalTo([ZFCommunityPostDetailBottomView defaultHeight]);
    }];
    [self.detailCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
        make.top.mas_equalTo(self.view.mas_top).offset(0.0);
    }];

    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view.mas_top).offset(kiphoneXTopOffsetY + 44.0);
        make.height.mas_equalTo(kUserInfoHeight);
    }];
    
    UIView *attributeSupperView = self.attributeView.superview;
    if (self.attributeView) {
        [self.attributeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(attributeSupperView).insets(UIEdgeInsetsZero);
        }];
    }
    

    
    [self.view layoutIfNeeded];
}

- (void)addNotification {
    // 接收点赞状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatusChangeValue:) name:kLikeStatusChangeNotification object:nil];
    // 接收评论状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviewCountsChangeValue:) name:kReviewCountsChangeNotification object:nil];
    // 接收关注状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followStatusChangeValue:) name:kFollowStatusChangeNotification object:nil];
    // 接收登录状态通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kLoginNotification object:nil];
}

- (NSString *)growingPostType:(ZFAppsflyerInSourceType)type {
    
    if (type == ZFAppsflyerInSourceTypeZMeOutfitid) {
        return @"outfits";
    } else if (type == ZFAppsflyerInSourceTypeZMeVideoid) {
        return @"videos";
    } else {
        //ZFAppsflyerInSourceTypeZMeExploreid
        return @"shows";
    }
}

- (NSString *)getGrowingPostType:(ZFAppsflyerInSourceType)type {
    if (type == ZFAppsflyerInSourceTypeZMeOutfitid) {
        return @"outfitid";
    } else if (type == ZFAppsflyerInSourceTypeZMeVideoid) {
        return @"videoid";
    } else {
        //ZFAppsflyerInSourceTypeZMeExploreid
        return @"exploreid";
    }
}

//- (void)navigationBarAlpha {
//    CGFloat contentOffsetY  = self.detailCollectionView.contentOffset.y;
//    CGFloat navigationAlpha = 0.0;
//    navigationAlpha = contentOffsetY > kNavigationAnimationHeight ? 1.0 : contentOffsetY / kNavigationAnimationHeight;
//    navigationAlpha = MAX(navigationAlpha, 0.0);
//    [self.navigaitonView setbackgroundAlpha:navigationAlpha];
//}

// 准许父类page滚动
- (void)permitScrollSetting {
    if (self.canScrollBlock) {
        self.canScrollBlock(YES);
    }
}
// 禁止父类page滚动
- (void)forbidScrollSetting {
    if (self.canScrollBlock) {
        self.canScrollBlock(NO);
    }
}

/**
 设置底部工具栏数据
 */
- (void)configBottomDatas {
    self.bottomView.hidden = NO;
    [self.bottomView setLikeNumber:[self.viewModel likeCount] isMyLiked:[self.viewModel isLiked]];
    
    [self.bottomView setCommentNumber:[self.viewModel replyCount]];
    
    if (self.commentViewModel.isFirstCommentRequestSuccess) {
        [self.bottomView setCommentNumber:[NSString stringWithFormat:@"%li",(long)self.commentViewModel.replyCount]];
    }
    [self.bottomView setCollectNumber:[self.viewModel collectCount] isCollect:[self.viewModel isCollect]];
}

/**
 配置帖子描述数据
 */
- (void)configContenDatas:(ZFCommunityPostDetailDescriptCollectionReusableView *)descripView indexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityTopicDetailBaseSection *baseSection = [self.viewModel descripSectionWithSection:indexPath.section];
    if ([baseSection isKindOfClass:[ZFCommunityTopicDetailDescripSection class]]) {
        ZFCommunityTopicDetailDescripSection *descripSection = (ZFCommunityTopicDetailDescripSection *)baseSection;

        [descripView setContentString:descripSection.topicContentString];
        [descripView setDeepLinkTitle:descripSection.deeplinkTitle url:descripSection.deeplinkUrl];
        [descripView setTagArray:descripSection.tagArray];
        [descripView setReadNumber:descripSection.readNumberString];
        [descripView setPublishTime:descripSection.publishTimeString];
    }
}

/**
 配置用户数据
 */
- (void)configUserInfo:(ZFCommunityPostDetailUserView *)userView indexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityTopicDetailUserInfoSection *userInfoSection = [self.viewModel userInfoSectionWithSection:indexPath.section];
    
    NSString *userAvarteURL = ZFToString(userInfoSection.userAvatarURL);
    NSString *userNickName  = ZFToString(userInfoSection.userNickName);
    NSString *userPostNum   = ZFToString(userInfoSection.postNumber);
    NSString *userTotalLike = ZFToString(userInfoSection.likedNumber);
    BOOL userIsfollow       = [self.viewModel userIsFollowURLInInIndexPath:indexPath];
    
    
    userView.isMyTopic = self.isMyTopic;
    userView.isFollow  = userIsfollow;
    [userView setUserWithAvarteURL:userAvarteURL];
    [userView setUserWithNickName:userNickName];
    [userView setUserWithPost:userPostNum totalLiked:userTotalLike];
    [userView setUserWithRank:[userInfoSection.identify_type integerValue]  imgUrl:userInfoSection.identify_icon content:userInfoSection.identify_content];

    self.userInfoView.isFollow  = userIsfollow;
    self.userInfoView.isMyTopic = self.isMyTopic;
    [self.userInfoView setUserWithAvarteURL:userAvarteURL];
    [self.userInfoView setUserWithNickName:userNickName];
    [self.userInfoView setUserWithPost:userPostNum totalLiked:userTotalLike];
    
    [self.userInfoView setUserWithRank:[userInfoSection.identify_type integerValue]  imgUrl:userInfoSection.identify_icon content:userInfoSection.identify_content];
}

#pragma mark - <request>

- (void)requestDatas {
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.viewModel requestTopicDetailWithReviewID:self.reviewID relateFlag:NO complateHandle:^{
        @strongify(self)
        HideLoadingFromView(self.view);
        [self handleTopicDetailResult];
    }];
}

- (void)requestCommentDatas {
    
    @weakify(self)
    self.commentViewModel.isFirstCommentRequestSuccess = NO;
    [self.commentViewModel refresh];
    [self.commentViewModel reviewCommentListRequesWithReviewID:self.reviewID withPageSize:3 complateHandle:^(BOOL success){
        @strongify(self)
        
        if (self.commentViewModel.replyModelArray.count > 0) {
            for (ZFCommunityTopicDetailBaseSection *baseSection in self.viewModel.sectionArray) {
                if ([baseSection isKindOfClass:[ZFCommunityTopicDetailCommentSection class]]) {
                    self.commentViewModel.isFirstCommentRequestSuccess = YES;
                    ZFCommunityTopicDetailCommentSection *commentSection = (ZFCommunityTopicDetailCommentSection *)baseSection;
                    commentSection.lists = [[NSArray alloc] initWithArray:self.commentViewModel.replyModelArray];
                    commentSection.allCount = self.commentViewModel.replyCount;
                    [self configBottomDatas];
                }
            }
            [self.detailCollectionView reloadData];
        }
    }];
}

- (void)handleTopicDetailResult {

    if ([self.viewModel sectionCount] > 0
        || [self.viewModel isRequestSuccess]) {
        [self configBottomDatas];
        [self requestRelateDatas];
        [self.detailCollectionView reloadData];
        self.isMyTopic = [self.viewModel isMyTopic];
        
        [self requestCommentDatas];

    } else {
        [self.detailCollectionView showRequestTip:nil];
    }
}
- (void)requestGoodsDetailInfo:(NSString *)goodsId successBlock:(void(^)(GoodsDetailModel *goodsDetailInfo))successBlock{
    if (ZFIsEmptyString(goodsId)) {
        return;
    }
    NSDictionary *dict = @{
                           @"manzeng_id"  : @"",
                           @"goods_id"    : ZFToString(goodsId)
                           };
    
    ShowLoadingToView(self.view);
    if(!self.goodsDetailViewModel) {
        self.goodsDetailViewModel = [[ZFGoodsDetailViewModel alloc] init];
    }
    @weakify(self);
    [self.goodsDetailViewModel requestGoodsDetailData:dict completion:^(GoodsDetailModel *detaidlModel) {
        @strongify(self);
        HideLoadingFromView(self.view);

        //FIXME: occ Bug 1101 可能有异常（两个接口返回时）
        if (detaidlModel.detailMainPortSuccess && [detaidlModel isKindOfClass:[GoodsDetailModel class]]) {
            if (successBlock) {
                successBlock(detaidlModel);
            }
        }
    } failure:^(NSError *error) {
        @strongify(self)
        HideLoadingFromView(self.view);
    }];
}

- (void)requestRelateDatas {
    @weakify(self)
    [self.viewModel requestRelateWithReviewID:self.reviewID complateHandle:^(NSArray<ZFCommunityPostListInfoModel *> *topicArray) {
        @strongify(self)
        self.relatedArray = topicArray;
        [self.detailCollectionView reloadData];
    }];
}

/*
 * 关注
 */
- (void)requestFollow {
    ShowLoadingToView(self.view);
    @weakify(self)
    [self.viewModel requestFollowUserWithComplateHandle:^{
        @strongify(self)
        HideLoadingFromView(self.view);
        ShowToastToViewWithText(self.view, [self.viewModel tipMessage]);
        [self.detailCollectionView reloadData];
        [self configUserInfo:self.userInfoView indexPath:self.userInfoIndexPath];
    }];
}

/**
 * 请求点赞
 * indexPath， 当前帖子传nil
 */
- (void)requestLikeWithIndexPath:(NSIndexPath *)indexPath showLoading:(BOOL)showLoading resultBlock:(void (^)(BOOL state))completion{
    
    @weakify(self)
    [self judgePresentLoginVCCompletion:^{
        @strongify(self)
        
        if (showLoading) {
            ShowLoadingToView(self.view);
        }
        @weakify(self)
        [self.viewModel requestLikeWithIndexPath:indexPath complateHandle:^{
            @strongify(self)
            HideLoadingFromView(self.view);
            if (showLoading) {
                ShowToastToViewWithText(self.view, [self.viewModel tipMessage]);
            }

            if ([self.viewModel isRequestSuccess]) {
                if (indexPath != nil) {
                    [self.detailCollectionView reloadItemsAtIndexPaths:@[indexPath]];
                } else {
                    [self configBottomDatas];
                    [self.detailCollectionView reloadData];
                }
            }
            if (completion) {
                completion([self.viewModel isRequestSuccess]);
            }
            
            // branch统计
            [[ZFBranchAnalytics sharedManager] branchAnalyticsPostLikeWithPostId:self.reviewID postType:[self.viewModel reviewType] ? @"outfit" : @"show" isLike:self.viewModel.isLiked];
        }];
    }];
    
}

/**
 * 请求收藏
 */

- (void)requestCollectShowLoading:(BOOL)showLoading resultBlock:(void (^)(BOOL state))completion {
    
    @weakify(self)
    [self judgePresentLoginVCCompletion:^{
        @strongify(self)
        
        if (showLoading) {
            ShowLoadingToView(self.view);
        }
        @weakify(self)
        [self.viewModel requestCollect:self.reviewID complateHandle:^(BOOL success,BOOL state, NSString *msg){
            @strongify(self)
            HideLoadingFromView(self.view);
            if (showLoading && success) {
                if (state) { //收藏成功
                    ShowToastToViewWithText(self.view, ZFToString(msg));
                }
            }
            
            if (success) {
                [self configBottomDatas];
                //添加收藏帖子通知 不自动什么类型
                [[NSNotificationCenter defaultCenter]postNotificationName:kCollectionPostsNotification object:nil userInfo:nil];
                
                // branch统计
                [[ZFBranchAnalytics sharedManager] branchAnalyticsPostSaveWithPostId:self.reviewID postType:[self.viewModel reviewType] ? @"outfit" : @"show" isSave:state];
            }
            if (completion) {
                completion(success);
            }
        }];
    }];
}

/**
 * 社区查看帖子统计
 */
- (void)analyticsCheckPostView {
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId] = [NSString stringWithFormat:@"%@", self.reviewID];
    [ZFAnalytics appsFlyerTrackEvent:@"af_post_view" withValues:valuesDic];
    
    //growingIO 帖子详情浏览
    [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOFistEvar : GIOSourceCommunityPost,
                                               GIOSndIdEvar : ZFToString(self.reviewID),
                                               GIOSndNameEvar : ZFToString(self.reviewID)
    }];
    [ZFGrowingIOAnalytics ZFGrowingIOPostTopicShow:self.reviewID postType:[self growingPostType:self.sourceType]];
    
    // Branch帖子详情浏览
    [[ZFBranchAnalytics sharedManager] branchAnalyticsPostViewWithPostId:self.reviewID postType:[self.viewModel reviewType] ? @"outfit" : @"show"];
    
    //GA 帖子详情浏览，点击一起统计 (v4.1.0 需求 by 陈秀详), 同时取消了列表页的曝光和点击
    NSString *GAImpressName = [NSString stringWithFormat:@"%@_%@_%@", ZFGATopicDetailInternalPromotion,
                               [self growingPostType:self.sourceType],
                               ZFToString(self.reviewID)];
    [ZFAnalytics showAdvertisementWithBanners:@[@{@"name" : GAImpressName}] position:nil screenName:@"帖子详情"];
    [ZFAnalytics clickAdvertisementWithId:ZFToString(self.reviewID) name:GAImpressName position:nil];
}

- (void)userInfoActionWithUserView:(ZFCommunityPostDetailUserView *)userView {
    @weakify(self)
    userView.followActionHandle = ^{
        @strongify(self)
        @weakify(self)
        [self judgePresentLoginVCCompletion:^{
            @strongify(self)
            [self requestFollow];
        }];
    };
    
    userView.userAvarteActionHandle = ^{
        @strongify(self)
        ZFCommunityAccountViewController *mystyleVC = [[ZFCommunityAccountViewController alloc] init];
        mystyleVC.userName = [self.viewModel nickname];
        mystyleVC.userId = [self.viewModel userID];
        [self.navigationController pushViewController:mystyleVC animated:YES];
    };
}


- (void)openWebInfoWithUrl:(NSString *)url title:(NSString *)title {
    if ([url hasPrefix:@"ZZZZZ:"]) {
        ZFBannerModel *model = [[ZFBannerModel alloc] init];
        model.deeplink_uri = url;
        [BannerManager doBannerActionTarget:self withBannerModel:model];
    }else{
        ZFWebViewViewController *webVC = [[ZFWebViewViewController alloc] init];
        webVC.link_url = url;
        webVC.title = title;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}

- (void)changeGoodsAttribute:(NSString *)goodsId {
    if (self.currentSelectSimilarGoodsModel) {
        self.currentSelectSimilarGoodsModel.selectSkuCount += 1;
    }
    //获取商品详情接口
    @weakify(self)
    [self requestGoodsDetailInfo:ZFToString(goodsId) successBlock:^(GoodsDetailModel *goodsDetailInfo) {
        @strongify(self)
        self.attributeView.model = goodsDetailInfo;
    }];
}

//添加购物车
- (void)addGoodsToCartOption:(NSString *)goodsId goodsCount:(NSInteger)goodsCount {
    
    @weakify(self);
    [self.goodsDetailViewModel requestAddToCart:ZFToString(goodsId) loadingView:self.view goodsNum:goodsCount completion:^(BOOL isSuccess) {
        @strongify(self);
        
        if (isSuccess) {
            [self startAddCartSuccessAnimation];
            [self changeCartNumAction];
            
            //添加商品至购物车事件统计
            self.attributeView.model.buyNumbers = goodsCount;
            NSString *goodsSN = self.attributeView.model.goods_sn;
            NSString *spuSN = @"";
            if (goodsSN.length > 7) {  // sn的前7位为同款id
                spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
            }else{
                spuSN = goodsSN;
            }
            NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
            valuesDic[AFEventParamContentId] = ZFToString(goodsSN);
            valuesDic[@"af_spu_id"] = ZFToString(spuSN);
            valuesDic[AFEventParamPrice] = ZFToString(self.attributeView.model.shop_price);
            valuesDic[AFEventParamQuantity] = [NSString stringWithFormat:@"%zd",goodsCount];
            valuesDic[AFEventParamContentType] = @"product";
            valuesDic[@"af_content_category"] = ZFToString(self.attributeView.model.long_cat_name);
            valuesDic[AFEventParamCurrency] = @"USD";
            valuesDic[@"af_inner_mediasource"] = [ZFAppsflyerAnalytics sourceStringWithType:ZFAppsflyerInSourceTypeZMePostDetailBottomRelatedRecommend sourceID:self.reviewID];
            valuesDic[@"af_purchase_way"] = @"1";//V5.0.0增加, 判断是否为一键购买(0)还是正常加购(1)
            
            valuesDic[@"af_changed_size_or_color"] = (self.currentSelectSimilarGoodsModel.selectSkuCount > 0) ? @"1" : @"0";
            //        valuesDic[@"af_bucket_id"]         = ZFToString(self.afParams.bucketid);
            //        valuesDic[@"af_plan_id"]           = ZFToString(self.afParams.planid);
            //        valuesDic[@"af_version_id"]        = ZFToString(self.afParams.versionid);
            //        valuesDic[@"af_sort"]              = ZFToString(self.analyticsParams.analyticsSort);
            valuesDic[BigDataParams]           = @[[self.attributeView.model gainAnalyticsParams]];
            [ZFAnalytics appsFlyerTrackEvent:@"af_add_to_bag" withValues:valuesDic];
            //Branch
            [[ZFBranchAnalytics sharedManager] branchAddToCartWithProduct:self.attributeView.model number:goodsCount];
            [ZFFireBaseAnalytics addToCartWithGoodsModel:self.attributeView.model];
            [ZFGrowingIOAnalytics ZFGrowingIOAddCart:self.attributeView.model];
            
        } else {
            [self.attributeView bottomCartViewEnable:YES];
            [self changeCartNumAction];
        }
    }];
}

- (void)startAddCartSuccessAnimation {
    @weakify(self)
    [self.attributeView startAddCartAnimation:^{
        @strongify(self)
        [self.attributeView hideSelectTypeView];
    }];
}

#pragma mark - Public Method

- (void)laodDefaultViewModel:(ZFCommunityPostDetailViewModel *)viewModel {
    _viewModel = viewModel;
}

- (void)sharePostAction {
    [self.shareView open];
}

- (void)deletePostAction {
    
    NSString *deleteTitle = ZFLocalizedString(@"Address_List_Cell_Delete",nil);
    NSString *cancelTitle = ZFLocalizedString(@"Cancel",nil);
    @weakify(self)
    ZFActionSheetView *sheetView = [ZFActionSheetView actionSheetByBottomCornerRadius:^(NSInteger buttonIndex, id title) {
        @strongify(self)
        [self deleteDetailAction];//删除
        [self permitScrollSetting];
    } cancelButtonBlock:^{
        [self permitScrollSetting];
    } sheetTitle:nil cancelButtonTitle:cancelTitle otherButtonTitleArr:@[deleteTitle]];
    
    if (sheetView) {
        [self forbidScrollSetting];
    }
}

- (void)jumpToCartAction {
    ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
    [self.navigationController pushViewController:cartVC animated:YES];
}

- (void)hideBottomView {
    if (self.bottomView.superview) {
        [UIView animateWithDuration:0.25 animations:^{
            [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.view.mas_bottom).offset([ZFCommunityPostDetailBottomView defaultHeight]);
            }];
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)showBottomViewTime:(CGFloat )time {
    if (time < 0) {
        time = 0.25;
    }
    if (self.bottomView.superview) {
        [UIView animateWithDuration:time animations:^{
            [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.view.mas_bottom);
            }];
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - Property Method

- (ZFCommunityPostOperateViewModel *)interfaceViewModel {
    if (!_interfaceViewModel) {
        _interfaceViewModel = [[ZFCommunityPostOperateViewModel alloc] init];
    }
    return _interfaceViewModel;
}

- (UICollectionView *)detailCollectionView {
    if (!_detailCollectionView) {
        CHTCollectionViewWaterfallLayout *layout = [[CHTCollectionViewWaterfallLayout alloc] init];
        _detailCollectionView                    = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _detailCollectionView.dataSource         = self;
        _detailCollectionView.delegate           = self;
        _detailCollectionView.scrollsToTop       = NO;
        _detailCollectionView.backgroundColor    = [UIColor whiteColor];
        _detailCollectionView.showsHorizontalScrollIndicator = NO;
        _detailCollectionView.showsVerticalScrollIndicator   = NO;
        _detailCollectionView.alwaysBounceVertical           = YES;
        _detailCollectionView.emptyDataTitle    = ZFLocalizedString(@"EmptyCustomViewManager_titleLabel",nil);
        _detailCollectionView.emptyDataImage    = ZFImageWithName(@"blankPage_noCart");
        _detailCollectionView.emptyDataBtnTitle = ZFLocalizedString(@"EmptyCustomViewManager_refreshButton",nil);
        @weakify(self)
        _detailCollectionView.blankPageViewActionBlcok = ^(ZFBlankPageViewStatus status) {
            @strongify(self)
            [self requestDatas];
        };
        
        if (@available(iOS 11.0, *)) {
            _detailCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_detailCollectionView registerClass:[UICollectionViewCell class]
                  forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        [_detailCollectionView registerClass:[UICollectionReusableView class]
                  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                         withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
        [_detailCollectionView registerClass:[UICollectionReusableView class]
                  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                         withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
        [_detailCollectionView registerClass:[ZFPostDetailSimilarGoodsCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFPostDetailSimilarGoodsCell class])];
        [_detailCollectionView registerClass:[ZFCommunityPostDetailRecommendGoodsCCell class] forCellWithReuseIdentifier:[ZFCommunityPostDetailRecommendGoodsCCell queryReuseIdentifier]];
        
        [_detailCollectionView registerClass:[ZFCommunityPostDetailCommentCCell class] forCellWithReuseIdentifier:NSStringFromClass(ZFCommunityPostDetailCommentCCell.class)];
    }
    return _detailCollectionView;
}


- (ZFPostDetailSimilarGoodsView *)similarGoodsView {
    if (!_similarGoodsView) {
        _similarGoodsView = [[ZFPostDetailSimilarGoodsView alloc] initWithReviewID:self.reviewID];
        _similarGoodsView.sourceType = self.sourceType;
        @weakify(self)
        _similarGoodsView.selectedGoodsHandle = ^(NSString *goodsID, NSString *goodsSN) {
            @strongify(self)
            [self.bottomView setRelateUnselected];
            ZFGoodsDetailViewController *goodsDetailViewController = [[ZFGoodsDetailViewController alloc] init];
            goodsDetailViewController.goodsId = goodsID;
            //occ v3.7.0hacker 添加 ok
            goodsDetailViewController.analyticsProduceImpression = self.similarGoodsView.viewModel.analyticsProduceImpression;
            goodsDetailViewController.sourceType = ZFAppsflyerInSourceTypeZMePostDetailBottomRelatedRecommend;
            goodsDetailViewController.sourceID = ZFToString(self.reviewID);
            [self.navigationController pushViewController:goodsDetailViewController animated:YES];
            
            // appflyer统计
            NSString *spuSN = @"";
            if (goodsSN.length > 7) {  // sn的前7位为同款id
                spuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
            }else{
                spuSN = goodsSN;
            }
            NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsSN),
                                              @"af_spu_id" : ZFToString(spuSN),
                                              @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                              @"af_page_name" : @"post_detail",    // 当前页面名称
                                              };
            [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
            
            [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{
                GIOGoodsTypeEvar : GIOGoodsTypeCommunity,
                GIOGoodsNameEvar : [NSString stringWithFormat:@"recommend_zme_%@_%@", [self getGrowingPostType:self.sourceType], self.reviewID]
            }];
            
            // 请求统计商品点击
            [ZFCommunityGoodsOperateViewModel requestGoodsTap:@{@"reviewId":ZFToString(self.reviewID),
                                                                @"goods_sku":ZFToString(goodsSN)} completion:nil];
        };
        
        _similarGoodsView.tapActionHandle = ^{
            @strongify(self)
            [self.bottomView setRelateUnselected];
            [self permitScrollSetting];
        };
        
        _similarGoodsView.tapMoreHandle = ^{
            @strongify(self)
            [self.bottomView setRelateUnselected];
            [self jumpToSameGoodsAction];
        };
        
        _similarGoodsView.addCartHandle = ^(ZFCommunityGoodsInfosModel *model) {
            @strongify(self)
            [self shopGoodsAction:model];
        };
    }
    return _similarGoodsView;
}

- (ZFCommunityPostDetailUserView *)userInfoView {
    if (!_userInfoView) {
        _userInfoView = [[ZFCommunityPostDetailUserView alloc] init];
        _userInfoView.hidden   = YES;
        _userInfoView.isFollow = NO;
        [_userInfoView showSepareteView];
        [self userInfoActionWithUserView:_userInfoView];
    }
    return _userInfoView;
}

- (ZFCommunityPostDetailBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[ZFCommunityPostDetailBottomView alloc] init];
        _bottomView.hidden = YES;
        
        @weakify(self)
        _bottomView.likeHandle = ^(BOOL isSelected) {
            @strongify(self)
            [self requestLikeWithIndexPath:nil showLoading:YES resultBlock:nil];
        };
        _bottomView.commentHandle = ^{
            @strongify(self)
            [self jumpPostReplyWithEdit:NO];
        };
        _bottomView.relatedHandle = ^(BOOL isSelected) {
            @strongify(self)
            if (isSelected) {
                if ([self.parentViewController isKindOfClass:[WMPageController class]]) {
                    [self.similarGoodsView showView:self.parentViewController.view];
                } else {
                    [self.similarGoodsView showView:self.view];
                }
                [self forbidScrollSetting];
            } else {
                [self.similarGoodsView dismiss];
                [self permitScrollSetting];
            }
        };
        
        _bottomView.collectHandle = ^(BOOL isCollected) {
            @strongify(self)
            [self requestCollectShowLoading:YES resultBlock:nil];
        };
        
    }
    return _bottomView;
}


- (ZFShareView *)shareView {
    if (!_shareView) {
        _shareView = [[ZFShareView alloc] init];
        _shareView.delegate = self;
        [ZFShareManager authenticatePinterest];
        
        ZFShareTopView *shareTopView = [[ZFShareTopView alloc] init];
        NSString *imageName = @"";
        if ([self.viewModel sectionCount] > 0) {
            if ([self.viewModel baseSectionWithSection:0].rowCount > 0) {
                imageName = [self.viewModel picURLInIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            }
        }
        NSString *content = self.isOutfits ? ZFLocalizedString(@"ZFShare_Community_outfits", nil) : ZFLocalizedString(@"ZFShare_Community_post", nil);
        [shareTopView updateImage:imageName
                            title:content
                          tipType:ZFShareDefaultTipTypeCommon];
        _shareView.topView = shareTopView;
    }
    return _shareView;
}

- (void)setIsMyTopic:(BOOL)isMyTopic {
    _isMyTopic = isMyTopic;
    [self changeCartNumAction];
}

- (ZFGoodsDetailSelectTypeView *)attributeView {
    if (!_attributeView) {
        NSString *bagTitle = ZFLocalizedString(@"Detail_Product_AddToBag", nil);
        _attributeView = [[ZFGoodsDetailSelectTypeView alloc] initSelectSizeView:YES bottomBtnTitle:bagTitle];
        
        _attributeView.hidden = YES;
        @weakify(self);
        _attributeView.openOrCloseBlock = ^(BOOL isOpen) {
            @strongify(self);
            [self.attributeView bottomCartViewEnable:YES];
        };
        
        _attributeView.goodsDetailSelectTypeBlock = ^(NSString *goodsId) {
            @strongify(self);
            [self changeGoodsAttribute:goodsId];
        };
        
        _attributeView.goodsDetailSelectSizeGuideBlock = ^(NSString *url){
            @strongify(self);
            [self openWebInfoWithUrl:self.attributeView.model.size_url title:ZFLocalizedString(@"Detail_Product_SizeGuides",nil)];
        };
        _attributeView.addCartBlock = ^(NSString *goodsId, NSInteger count) {
            @strongify(self);
            [self.attributeView bottomCartViewEnable:NO];
            [self addGoodsToCartOption:ZFToString(goodsId) goodsCount:count];
        };
        
        _attributeView.cartBlock = ^{
            @strongify(self)
            [self jumpToCartAction];
            
        };
    }
    return _attributeView;
}

#pragma mark - super method

- (UIButton *)imageViewAllButton {
    if (!_imageViewAllButton) {
        _imageViewAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _imageViewAllButton.backgroundColor = ZFC0x000000_05();
        [_imageViewAllButton addTarget:self action:@selector(actionViewItems:) forControlEvents:UIControlEventTouchUpInside];
        _imageViewAllButton.hidden = YES;
        
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLab.text = ZFLocalizedString(@"Community_post_View_Items", nil);
        titleLab.textColor = ZFC0xFFFFFF();
        titleLab.font = ZFFontSystemSize(14);
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"size_arrow_right"]];
        [_imageViewAllButton addSubview:titleLab];
        [_imageViewAllButton addSubview:arrowImageView];
        
        [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.imageViewAllButton.mas_right).offset(-2);
            make.centerY.mas_equalTo(self.imageViewAllButton.mas_centerY);
        }];
        
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(arrowImageView.mas_left).offset(-7);
            make.centerY.mas_equalTo(arrowImageView.mas_centerY);
            make.left.mas_equalTo(self.imageViewAllButton.mas_left).offset(4);
        }];
        
    }
    return _imageViewAllButton;
}

- (ZFCommunityPostDetailAOP *)analyticsAOP {
    if (!_analyticsAOP) {
        _analyticsAOP = [[ZFCommunityPostDetailAOP alloc] init];
    }
    return _analyticsAOP;
}
@end
