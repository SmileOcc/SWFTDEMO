//
//  ZFCommunityAccountOutfitsView.m
//  ZZZZZ
//
//  Created by YW on 2017/8/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityAccountOutfitsView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCommunityAccountOutfitsCell.h"
#import "ZFCommunityOutfitsModel.h"
#import "ZFCommunityAccountOutfitsViewModel.h"
#import "ZFCommunityFavesItemModel.h"
#import "ZFCommuntityGestureTableView.h"
#import "ZFThemeManager.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "Constants.h"
#import "AccountManager.h"

static NSString *const kZFCommunityAccountOutfitsCellIdentifier = @"kZFCommunityAccountOutfitsCellIdentifier";

@interface ZFCommunityAccountOutfitsView () <ZFInitViewProtocol, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) NSInteger                             currentPage;
@property (nonatomic, strong) ZFCommuntityCollectionView            *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout            *flowLayout;
@property (nonatomic, strong) ZFCommunityAccountOutfitsViewModel    *viewModel;
@property (nonatomic, strong) NSMutableArray<ZFCommunityOutfitsModel *> *dataArray;
@end

@implementation ZFCommunityAccountOutfitsView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self.collectionView.mj_header beginRefreshing];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatusChangeValue:) name:kLikeStatusChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(likeStatusChangeValue:) name:kLikeStatusChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChangeValue:) name:kChangeUserInfoNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logoutChangeValue:) name:kLogoutNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notificatoin methods 
- (void)loginChangeValue:(NSNotification *)nofi {
    [self.collectionView.mj_header beginRefreshing];
}

- (void)logoutChangeValue:(NSNotification *)nofi {
    [self.collectionView.mj_header beginRefreshing];
}

- (void)deleteChangeValue:(NSNotification *)nofi {
    [self.collectionView.mj_header beginRefreshing];
}

- (void)likeStatusChangeValue:(NSNotification *)nofi {
    //接收通知传过来的model StyleLikesModel
    ZFCommunityFavesItemModel *likesModel = nofi.object;
    //遍历当前列表数组找到相同reviewId改变点赞按钮状态并且增加或减少点赞数
    [self.dataArray enumerateObjectsUsingBlock:^(ZFCommunityOutfitsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.reviewId isEqualToString:likesModel.reviewId]) {
            if (likesModel.isLiked) {
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]+1];
            }else{
                obj.likeCount = [NSString stringWithFormat:@"%d", [obj.likeCount intValue]-1];
            }
            obj.liked = [NSString stringWithFormat:@"%d", likesModel.isLiked];
            NSIndexPath *reloadIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadItemsAtIndexPaths:@[reloadIndexPath]];
            });
            *stop = YES;
        }
    }];

}

#pragma mark - private methods
- (void)communityAccountOutfitsLikeOptionWithModel:(ZFCommunityOutfitsModel *)model andIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dic = @{kRequestModelKey : model,
                          kLoadingView : self.controller.view};
    
    if (![AccountManager sharedManager].isSignIn) {
        @weakify(self);
        [self.controller.navigationController judgePresentLoginVCCompletion:^{
            @strongify(self);
            [self.viewModel requestLikeNetwork:dic completion:^(id obj) {
//                @strongify(self);
//                self.dataArray[indexPath.row].liked = [NSString stringWithFormat:@"%d", ![self.dataArray[indexPath.row].liked boolValue]];
//                self.dataArray[indexPath.row].likeCount = [NSString stringWithFormat:@"%lu", [self.dataArray[indexPath.row].likeCount integerValue] + (self.dataArray[indexPath.row].liked ? 1 : -1)];
//                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            } failure:^(id obj) {
//                @strongify(self);
//                [self.collectionView reloadData];
            }];
        }];
        return ;
    }
    
//    @weakify(self);
    [self.viewModel requestLikeNetwork:dic completion:^(id obj) {
//        @strongify(self);
//        self.dataArray[indexPath.row].liked = [NSString stringWithFormat:@"%d", ![self.dataArray[indexPath.row].liked boolValue]];
//        self.dataArray[indexPath.row].likeCount = [NSString stringWithFormat:@"%lu", [self.dataArray[indexPath.row].likeCount integerValue] + (self.dataArray[indexPath.row].liked ? 1 : -1)];
//        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    } failure:^(id obj) {
//        @strongify(self);
//        [self.collectionView reloadData];
    }];
}

#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ZFCommunityAccountOutfitsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kZFCommunityAccountOutfitsCellIdentifier forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    @weakify(self);
    cell.communityAccountOutfitsLikeCompletionHandler = ^(ZFCommunityOutfitsModel *model) {
        @strongify(self);
        [self communityAccountOutfitsLikeOptionWithModel:model andIndexPath:indexPath];
    };
    return cell;
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 7;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 7;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((KScreenWidth - 39) / 2, 230 * ScreenWidth_SCALE);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    ZFCommunityOutfitsModel *model = self.dataArray[indexPath.row];
    if (self.communityAccountOutfitsDetailCompletionHandler) {
        self.communityAccountOutfitsDetailCompletionHandler(model.userId, model.reviewId, model.reviewTitle);
    }
}

#pragma mark -<ZFInitViewProtocol>
- (void)zfInitView {
    self.currentPage = 1;
    self.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    [self.contentView addSubview:self.collectionView];
}

- (void)zfAutoLayoutView {
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView).insets(UIEdgeInsetsMake(0, 0, 44, 0));
    }];
}

#pragma mark - setter 
- (void)setUserId:(NSString *)userId {
    _userId = userId;
}

#pragma mark - getter
- (ZFCommunityAccountOutfitsViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFCommunityAccountOutfitsViewModel alloc] init];
    }
    return _viewModel;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
    }
    return _flowLayout;
}

- (ZFCommuntityCollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[ZFCommuntityCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[ZFCommunityAccountOutfitsCell class] forCellWithReuseIdentifier:kZFCommunityAccountOutfitsCellIdentifier];
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        NSString *tipString = nil;
        if ([self.userId isEqualToString:USERID]) {
            tipString = ZFLocalizedString(@"AccountOutfits_NoData_NotOutfits", nil);
        } else {
            tipString = ZFLocalizedString(@"AccountOtherOutfits_NoData_NotOutfits", nil);
        }
        //请求空数据提示图片文案
        _collectionView.emptyDataImage = ZFImageWithName(@"blankPage_noImages");
        _collectionView.emptyDataTitle = tipString;
        _collectionView.blankPageViewCenter = CGPointMake(KScreenWidth/2, KScreenHeight/4);
        
        @weakify(self);
        ZFRefreshHeader *header = [ZFRefreshHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self.viewModel requestOutfitsListData:@[Refresh, @(1), self.userId?:@"0"] completion:^(id obj, NSInteger totalPage) {
                self.currentPage = 1;
                self.dataArray = obj;
                self.collectionView.mj_footer.hidden = YES;
   
                [self.collectionView reloadData];
                //处理空白页,和分页
                NSDictionary *pageDic  = @{kTotalPageKey:@(totalPage),
                                           kCurrentPageKey:@(self.currentPage)};
                [self.collectionView showRequestTip:pageDic];
                
            } failure:^(id obj) {
                @strongify(self);
                [self.collectionView reloadData];
                [self.collectionView showRequestTip:nil];
            }];
        }];
        [self.collectionView setMj_header:header];
        
        ZFRefreshFooter *footer = [ZFRefreshFooter footerWithRefreshingBlock:^{
            @strongify(self);
            [self.viewModel requestOutfitsListData:@[LoadMore, @(self.currentPage + 1), self.userId?:@"0"] completion:^(id obj, NSInteger totalPage) {
                @strongify(self);
                if(![obj isEqual: NoMoreToLoad]) {
                    self.currentPage += 1;
                    self.dataArray = obj;
                }
                [self.collectionView reloadData];
                
                //处理空白页,和分页
                NSDictionary *pageDic  = @{kTotalPageKey:@(totalPage),
                                           kCurrentPageKey:@(self.currentPage)};
                [self.collectionView showRequestTip:pageDic];
                
            } failure:^(id obj) {
                [self.collectionView reloadData];
                [self.collectionView showRequestTip:nil];
            }];
        }];
        [self.collectionView setMj_footer:footer];
    }
    return _collectionView;
}

@end
