//
//  ZFPostDetailSimilarGoodsView.m
//  ZZZZZ
//
//  Created by YW on 2018/7/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFPostDetailSimilarGoodsView.h"
#import "ZFPostDetailSimilarGoodsCell.h"
#import "ZFInitViewProtocol.h"
#import <Lottie/Lottie.h>
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "NSDictionary+SafeAccess.h"
#import "SystemConfigUtils.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGoodsModel.h"
#import "ZFPiecingOrderViewModel.h"
#import "UIView+ZFViewCategorySet.h"

@interface ZFPostDetailSimilarGoodsView () <ZFInitViewProtocol,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView                 *tapView;
@property (nonatomic, strong) UIView                 *topAddCornerView;

@property (nonatomic, strong) UICollectionView       *goodsCollectionView;
@property (nonatomic, strong) UIView                 *emptyView;

@property (nonatomic, strong) LOTAnimationView *animView;

@property (nonatomic, copy) NSString                 *reviewID;
@property (nonatomic, assign) CGFloat                contentHeight;



//@property (nonatomic, strong) UIView *loadMoreView;
//@property (nonatomic, strong) LOTAnimationView *animView;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isCanMore;

///保存统计推荐商品的属性
@property (nonatomic, strong) NSArray *analyticsGoodsList;

@end

@implementation ZFPostDetailSimilarGoodsView

- (instancetype)initWithReviewID:(NSString *)reviewID {
    if (self = [super init]) {
        self.frame = CGRectMake(0.0, 0.0, KScreenWidth, KScreenHeight - 49.0 - kiphoneXHomeBarHeight);
        self.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.0];
        
        self.contentHeight = 291.0;
        
        self.isLoading = NO;
        self.isCanMore = NO;
        self.reviewID = reviewID;
        [self zfInitView];
        [self zfAutoLayoutView];
        self.viewModel = [[ZFCommunityPostSameGoodsViewModel alloc] init];
        [self requestDataIsFirstPage:YES];
        
        UITapGestureRecognizer *tapGeture = [[UITapGestureRecognizer alloc] init];
        [tapGeture addTarget:self action:@selector(tapHiddenAction:)];
        [self.tapView addGestureRecognizer:tapGeture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.topAddCornerView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];
}

#pragma mark - <zfAutoLayoutView>
- (void)zfInitView {
    [self addSubview:self.tapView];
    [self addSubview:self.topAddCornerView];
    [self addSubview:self.goodsCollectionView];
    [self.goodsCollectionView addSubview:self.animView];
    [self.animView play];
}

- (void)zfAutoLayoutView {
    [self.tapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-self.contentHeight);
    }];
    
    [self.topAddCornerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.goodsCollectionView.mas_top);
        make.height.mas_equalTo(16);
        make.leading.trailing.mas_equalTo(self);
    }];
    
    [self.goodsCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(0.0);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    [self.animView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(30.0f);
        make.centerX.mas_equalTo(self.goodsCollectionView.mas_centerX);
        make.centerY.mas_equalTo(self.goodsCollectionView.mas_centerY);
    }];
    
    [self layoutIfNeeded];
}

- (void)requestDataIsFirstPage:(BOOL)isFirstPage {
    @weakify(self)
    [self.viewModel requestTheSameGoodsWithReviewID:self.reviewID isFirstPage:isFirstPage catId:@"0" finishedHandle:^(NSDictionary *pageInfo) {
        @strongify(self)
        
        NSInteger curPage   = [pageInfo ds_integerForKey:kCurrentPageKey];
        NSInteger totalPage = [pageInfo ds_integerForKey:kTotalPageKey];
        self.isCanMore = !(curPage == totalPage);
        self.isLoading = NO;
        
        [self.goodsCollectionView reloadData];
        [self layoutIfNeeded];

        if (self.animView.hidden == NO) {
            self.animView.hidden = YES;
            [self.animView stop];
        }
        if ([SystemConfigUtils isRightToLeftShow]
            && isFirstPage) {
            [self.goodsCollectionView setContentOffset:CGPointMake(self.goodsCollectionView.contentSize.width - self.goodsCollectionView.width, 0.0) animated:NO];
        }
        
        [UIView animateWithDuration:0.25 animations:^{
            self.goodsCollectionView.contentInset = UIEdgeInsetsZero;
        }];
        
        if ([self.viewModel dataCount] == 0 || ![self.viewModel isRequestSuccess]) {
            [self.emptyView removeFromSuperview];
            [self.goodsCollectionView addSubview:self.emptyView];
            [self.goodsCollectionView bringSubviewToFront:self.emptyView];
            self.emptyView.frame = self.goodsCollectionView.bounds;
        } else {
            [self.emptyView removeFromSuperview];
            [self addSimilarkAnalytics];
        }
        [self.viewModel showAnalysicsWithCateName:@"relate_goods"];
    }];
}


/**
 * 统计相似弹窗商品列表
 */
- (void)addSimilarkAnalytics {
    if (self.viewModel.goodsInfoArray.count <= 0) {
        return;
    }
    
    NSMutableString *goodsns = [[NSMutableString alloc] init];
    NSMutableArray <ZFGoodsModel *> *tempGoodsModelArray = [[NSMutableArray alloc] init];
    for (ZFCommunityGoodsInfosModel *model in self.viewModel.goodsInfoArray) {
        ZFGoodsModel *goodsModel = [self goodsInfoModelAdapterToGoodsModel:model];
        [tempGoodsModelArray addObject:goodsModel];
        [goodsns appendFormat:@"%@,", goodsModel.goods_sn];
    }
    
    //这里要通过商品id获取一波商品的具体详情，因为 社区接口不能获取到商品的多级分类属性, 单独用于GIO统计
    @weakify(self)
    [ZFPiecingOrderViewModel requestHandpickGoodsList:goodsns completion:^(NSArray<ZFGoodsModel *> *goodsModelArray) {
        self.analyticsGoodsList = goodsModelArray;
        @strongify(self)
        @weakify(self)
        [goodsModelArray enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            @strongify(self)
            obj.postType = [self gainPostType];
            obj.af_rank = idx + 1;
        }];
        
        [ZFAppsflyerAnalytics trackGoodsList:goodsModelArray inSourceType:ZFAppsflyerInSourceTypeZMePostDetailBottomRelatedRecommend sourceID:self.reviewID];
        
    }];
}

- (ZFGoodsModel *)goodsInfoModelAdapterToGoodsModel:(ZFCommunityGoodsInfosModel *)infoModel {
    ZFGoodsModel *goodsModel = [ZFGoodsModel new];
    goodsModel.goods_id      = infoModel.goodsId;
    goodsModel.goods_sn      = infoModel.goods_sn;
    goodsModel.goods_title   = infoModel.goodsTitle;
    return goodsModel;
}

- (NSString *)gainPostType {
    NSString *type = nil;
    if (self.sourceType == ZFAppsflyerInSourceTypeZMeExploreid) {
        type = GIOPostShows;
    }else if (self.sourceType == ZFAppsflyerInSourceTypeZMeVideoid) {
        type = GIOPostVideos;
    }else{
        type = GIOPostOutfits;
    }
    return type;
}

#pragma mark - Action
- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.35 animations:^{
        self.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.4];
        [self.goodsCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(self.contentHeight - 16.0);
        }];
        [self layoutIfNeeded];
    }];
}

- (void)showView:(UIView *)superView {
    if (superView) {
        [superView addSubview:self];
        [UIView animateWithDuration:0.35 animations:^{
            self.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.4];
            [self.goodsCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(self.contentHeight - 16.0);
            }];
            [self layoutIfNeeded];
        }];
    }
}
- (void)dismiss {
    [UIView animateWithDuration:0.35 animations:^{
        self.backgroundColor = [UIColor colorWithHex:0x000000 alpha:0.0];
        [self.goodsCollectionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0.0);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)tapHiddenAction:(UITapGestureRecognizer *)tapGesture {
    CGPoint tapPoint = [tapGesture locationInView:self];
    if (tapPoint.y < self.height - self.contentHeight) {
        if (self.tapActionHandle) {
            self.tapActionHandle();
            [self dismiss];
        }
    }
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //只显示6个商品+更多视图
    NSInteger goodsCount = [self.viewModel dataCount];
    if (goodsCount > 0) {
        if ((self.isCanMore && goodsCount >= 6) || goodsCount > 6) {
            return 7;
        }
        return goodsCount;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 6) {//更多
        ZFTopicDetailSimilarGoodsMoreCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZFTopicDetailSimilarGoodsMoreCell" forIndexPath:indexPath];
        return cell;
    }
    
    ZFPostDetailSimilarGoodsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFPostDetailSimilarGoodsCell class]) forIndexPath:indexPath];
    [cell setShopCartShow:YES];
    
    @weakify(self)
    cell.addCartBlock = ^(ZFCommunityGoodsInfosModel *goodsModel) {
        @strongify(self)
        if (self.addCartHandle) {
            self.addCartHandle(goodsModel);
        }
    };
    if (self.viewModel.goodsInfoArray.count > indexPath.item) {
        cell.model = self.viewModel.goodsInfoArray[indexPath.item];
        
        [cell setGoodsImageURL:[self.viewModel goodsImageWithIndex:indexPath.item]];
        [cell setGoodsPrice:[self.viewModel goodsPriceWithIndex:indexPath.item]];
        [cell setGoodsIsSimilar:[self.viewModel isTheSameWithIndex:indexPath.item]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 6) {//更多
        if (self.tapMoreHandle) {
            self.tapMoreHandle();
            [self dismiss];
            [self removeFromSuperview];
        }
        return;
    }
    NSString *goodsID = [self.viewModel goodsIDWithIndex:indexPath.item];
    NSString *goodsSN = [self.viewModel goodsSNWithIndex:indexPath.item];
    if (self.selectedGoodsHandle) {
        self.selectedGoodsHandle(goodsID, goodsSN);
        [self.viewModel clickAnalysicsWithCateName:@"relate_goods" index:indexPath.item];
        [self dismiss];
        [self removeFromSuperview];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

#pragma mark - getter/setter
- (UICollectionView *)goodsCollectionView {
    if (!_goodsCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize        = CGSizeMake(150.0, self.contentHeight - 16.0 * 2);
        layout.minimumInteritemSpacing  = 8.0f;
        layout.sectionInset = UIEdgeInsetsMake(0.0, 16.0, 16.0, 16.0);
        _goodsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _goodsCollectionView.delegate   = self;
        _goodsCollectionView.dataSource = self;
        _goodsCollectionView.backgroundColor    = [UIColor whiteColor];
        _goodsCollectionView.showsHorizontalScrollIndicator = NO;
        _goodsCollectionView.showsVerticalScrollIndicator   = NO;
        _goodsCollectionView.alwaysBounceHorizontal         = YES;
        [_goodsCollectionView registerClass:[ZFPostDetailSimilarGoodsCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFPostDetailSimilarGoodsCell class])];
        [_goodsCollectionView registerClass:[ZFTopicDetailSimilarGoodsMoreCell class] forCellWithReuseIdentifier:@"ZFTopicDetailSimilarGoodsMoreCell"];
        
        if ([SystemConfigUtils isRightToLeftShow]) {
            _goodsCollectionView.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
        }
    }
    return _goodsCollectionView;
}

- (UIView *)tapView {
    if (!_tapView) {
        _tapView = [[UIView alloc] init];
        _tapView.backgroundColor = [UIColor clearColor];
        _tapView.userInteractionEnabled = YES;
    }
    return _tapView;
}

- (UIView *)topAddCornerView {
    if (!_topAddCornerView) {
        _topAddCornerView = [[UIView alloc] initWithFrame:CGRectZero];
        _topAddCornerView.backgroundColor = [UIColor whiteColor];
    }
    return _topAddCornerView;
}


- (LOTAnimationView *)animView {
    if (!_animView) {
        _animView = [LOTAnimationView animationNamed:@"ZZZZZ_loading_downloading"];
        _animView.contentMode = UIViewContentModeScaleAspectFit;
        _animView.loopAnimation = YES;
    }
    return _animView;
}


- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:self.goodsCollectionView.bounds];
        _emptyView.backgroundColor = [UIColor whiteColor];
        
        UIImage *emptyDataImage = [UIImage imageNamed:@"blankPage_noCart"];
        UIImageView *imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, emptyDataImage.size.width, emptyDataImage.size.height)];
        imageView.image         = emptyDataImage;
        [_emptyView addSubview:imageView];
        
        NSString *emptyDataTitle = ZFLocalizedString(@"community_topic_relateempty",nil);
        UILabel *emptyLabel  = [[UILabel alloc] initWithFrame:CGRectMake(16.0, 0.0, KScreenWidth - 32.0, 18.0)];
        emptyLabel.font      = [UIFont systemFontOfSize:14.0];
        emptyLabel.textColor = [UIColor colorWithHex:0x2D2D2D];
        emptyLabel.text      = emptyDataTitle;
        emptyLabel.textAlignment = NSTextAlignmentCenter;
        [_emptyView addSubview:emptyLabel];
        
        CGFloat offsetY = (self.contentHeight - emptyDataImage.size.height - emptyLabel.height - 12.0) / 2;
        imageView.y     = offsetY;
        imageView.x     = (KScreenWidth - imageView.width) / 2;
        emptyLabel.y    = imageView.y + imageView.height + 12.0;
    }
    return _emptyView;
}

@end
