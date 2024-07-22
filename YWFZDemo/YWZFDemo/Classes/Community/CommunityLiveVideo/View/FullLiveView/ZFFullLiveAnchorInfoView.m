//
//  ZFFullLiveAnchorInfoView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveAnchorInfoView.h"
#import "ZFInitViewProtocol.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "CHTCollectionViewWaterfallLayout.h"
#import "Masonry.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"

#import "ZFCommunityLiveVideoActivityCCell.h"
@interface ZFFullLiveAnchorInfoView()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
ZFInitViewProtocol,
CHTCollectionViewDelegateWaterfallLayout,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) UIView                                *contentView;
@property (nonatomic, strong) UIView                                *topBarView;
@property (nonatomic, strong) UILabel                               *titleLabel;
@property (nonatomic, strong) UIButton                              *closeButton;

@property (nonatomic, strong) UICollectionView                      *collectionView;

@property (nonatomic, assign) BOOL                                  isDraging;

@property (nonatomic, assign) CGFloat                               contentOffsetY;

@end

@implementation ZFFullLiveAnchorInfoView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];
}

- (void)zfViewWillAppear {
    
}

- (void)zfInitView {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.topBarView];
    [self.contentView addSubview:self.collectionView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.closeButton];
    
}

- (CGFloat)contentH {
    return [ZFVideoLiveConfigureInfoUtils liveShowViewHeight];
}

- (void)zfAutoLayoutView {
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([self contentH]);
        make.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom).offset([self contentH]);
    }];
    
    [self.topBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(44);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.topBarView.mas_bottom);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.topBarView.mas_centerX);
        make.centerY.mas_equalTo(self.topBarView.mas_centerY);
        make.width.mas_lessThanOrEqualTo(KScreenWidth - 80);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.topBarView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.topBarView.mas_centerY);
    }];
}

- (void)fullScreen:(id)isFull {
    if (![isFull boolValue]) {
        [self scrollCurrentContnetOffSetY];
    }
}

- (void)showAnchorView:(BOOL)show {
    
    CGFloat topX;
    if (show) {
        topX = 0;
        self.hidden = NO;
        self.backgroundColor = ZFC0x000000_A(0);
    } else {
        topX = [self contentH];
    }
    
    [self setNeedsUpdateConstraints];
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.userInteractionEnabled = YES;
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(topX);
        }];
        self.backgroundColor = show ? ZFC0x000000_A(0.4) : ZFC0x000000_A(0);
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = !show;
    }];
}

- (void)actionClose:(UIButton *)sender {
    if (self.closeBlock) {
        self.closeBlock();
    }
}
- (void)scrollCurrentContnetOffSetY {
    if (self.contentOffsetY > 0) {
        [self.collectionView setContentOffset:CGPointMake(0, self.contentOffsetY) animated:NO];
    }
}

- (void)updateHotActivity:(NSArray<ZFCommunityLiveVideoRedNetModel *>*)activityModel {
    if (ZFJudgeNSArray(activityModel)) {
        self.liveActivityViewModel.datasArray = [[NSMutableArray alloc] initWithArray:activityModel];
        [self.collectionView reloadData];
        self.contentOffsetY = self.collectionView.contentOffset.y;
    }
    
    [self.collectionView showRequestTip:@{kTotalPageKey  : @(1),
                                          kCurrentPageKey: @(1)}];
}

- (void)requestLiveGoodsPageData:(BOOL)isFirstPage {
    // 不请求数据
}

#pragma mark - 手势

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([self.contentView pointInside:[touch locationInView:self.contentView] withEvent:nil] && !self.contentView.isHidden) {
        return NO;
    }
    return YES;
}

- (void)actionTap:(UITapGestureRecognizer *)tap {
    [self showAnchorView:NO];
}
#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.liveActivityViewModel.datasArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityLiveVideoActivityCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveVideoActivityCCell class]) forIndexPath:indexPath];
    
    if (self.liveActivityViewModel.datasArray.count > indexPath.section) {
        ZFCommunityLiveVideoRedNetModel *activityModel = self.liveActivityViewModel.datasArray[indexPath.section];
        cell.redNetModel = activityModel;
    }
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if (self.liveActivityViewModel.datasArray.count > indexPath.section) {
        ZFCommunityLiveVideoRedNetModel *activityModel = self.liveActivityViewModel.datasArray[indexPath.section];
        
        if (self.liveVideoBlock) {
            self.liveVideoBlock(ZFToString(activityModel.link_url));
        }
    }
}


#pragma mark -===CHTCollectionViewDelegateWaterfallLayout===


/**
 * 每个Item的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.liveActivityViewModel.datasArray.count > indexPath.section) {
        ZFCommunityLiveVideoRedNetModel *activityModel = self.liveActivityViewModel.datasArray[indexPath.section];
        if ([activityModel.pic_width floatValue] > 0) {
            return CGSizeMake(KScreenWidth, KScreenWidth * [activityModel.pic_height floatValue] / [activityModel.pic_width floatValue]);
        }
    }
    return CGSizeZero;
}

/**
 * 每个section之间的缩进间距
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(12, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section {
    return  0;
}

#pragma mark - UIScrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat offsetY = scrollView.contentOffset.y;
    YWLog(@"------- %f",offsetY);
    
    if (self.isDraging) {// 这个只处理拖拽
        self.contentOffsetY = offsetY;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    YWLog(@"-----scrollViewDidEndDecelerating：%f",scrollView.contentOffset.y);
    self.contentOffsetY = scrollView.contentOffset.y;
    
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    self.isDraging = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isDraging = YES;
}
#pragma mark - Property Method

- (ZFCommunityLiveVideoActivityModel *)liveActivityViewModel {
    if (!_liveActivityViewModel) {
        _liveActivityViewModel = [[ZFCommunityLiveVideoActivityModel alloc] init];
    }
    return _liveActivityViewModel;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = ZFC0xFFFFFF();
    }
    return _contentView;
}

- (UIView *)topBarView {
    if (!_topBarView) {
        _topBarView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _topBarView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFC0x2D2D2D();
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = ZFLocalizedString(@"Community_LivesVideo_Host", nil);
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"z-me_outfits_post_close"] forState:UIControlStateNormal];
        _closeButton.contentEdgeInsets = UIEdgeInsetsMake(3, 3, 3, 3);
        [_closeButton addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UICollectionView *)collectionView {
    if(!_collectionView){
        
        CHTCollectionViewWaterfallLayout *waterfallLayout = [[CHTCollectionViewWaterfallLayout alloc] init]; //创建布局
        waterfallLayout.minimumColumnSpacing = 13;
        waterfallLayout.minimumInteritemSpacing = 0;
        waterfallLayout.headerHeight = 0;
        waterfallLayout.columnCount = 1;
        
        
        CGRect frameRect = self.bounds;
        if (CGSizeEqualToSize(frameRect.size, CGSizeZero)) {
            frameRect = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 150);
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:frameRect collectionViewLayout:waterfallLayout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.alwaysBounceVertical = YES;
        
        _collectionView.emptyDataImage = ZFImageWithName(@"blankPage_noImages");
        _collectionView.emptyDataTitle = ZFLocalizedString(@"Community_LivesVideo_Host_Forgot_Introduce_msg", nil);

        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_collectionView registerClass:[ZFCommunityLiveVideoActivityCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityLiveVideoActivityCCell class])];
    }
    return _collectionView;
}

@end
