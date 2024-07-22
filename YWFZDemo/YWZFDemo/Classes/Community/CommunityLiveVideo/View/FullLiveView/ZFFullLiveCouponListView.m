//
//  ZFFullLiveCouponListView.m
//  ZZZZZ
//
//  Created by YW on 2019/12/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFFullLiveCouponListView.h"
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

#import "ZFFullLiveCouponCell.h"

#import "ZFCommunityLiveVideoGoodsModel.h"

@interface ZFFullLiveCouponListView()
<
UITableViewDelegate,
UITableViewDataSource,
ZFInitViewProtocol,
UIGestureRecognizerDelegate
>

@property (nonatomic, strong) ZFCommunityLiveVideoGoodsModel        *liveGoodsViewModel;

@property (nonatomic, strong) UIView                                *contentView;
@property (nonatomic, strong) UIView                                *topBarView;
@property (nonatomic, strong) UILabel                               *titleLabel;
@property (nonatomic, strong) UIButton                              *closeButton;
@property (nonatomic, strong) UITableView                           *tableView;
@property (nonatomic, assign) BOOL                                  isDraging;
@property (nonatomic, assign) CGFloat                               contentOffsetY;

@end

@implementation ZFFullLiveCouponListView

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
    if (self.liveGoodsViewModel.couponsArray.count <= 0) {
        [self.tableView.mj_header beginRefreshing];
    }
}

- (void)zfInitView {
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.topBarView];
    [self.contentView addSubview:self.tableView];
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
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
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

- (void)requestLiveCouponsPageData:(BOOL)isFirstPage {
    
    @weakify(self)
    [self.liveGoodsViewModel requestLiveVideoCouponsData:isFirstPage coupon:ZFToString(self.live_code) completion:^(NSArray<ZFGoodsDetailCouponModel *> * _Nonnull couponsArray, NSDictionary * _Nonnull pageInfo) {
        
        @strongify(self)
        [self.tableView reloadData];
        [self.tableView showRequestTip:pageInfo];

    } failure:^(id  _Nonnull obj) {
        [self.tableView showRequestTip:nil];
    }];
}


- (void)fullScreen:(id)isFull {
    if (![isFull boolValue]) {
        [self scrollCurrentContnetOffSetY];
    }
}

- (void)showCouponListView:(BOOL)show {
    
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
        [self.tableView setContentOffset:CGPointMake(0, self.contentOffsetY) animated:NO];
    }
}

- (void)updateDatas:(ZFGoodsDetailCouponModel *)couponModel {
    if (couponModel) {
        for (ZFGoodsDetailCouponModel *model in self.liveGoodsViewModel.couponsArray) {
            if ([model.couponId isEqualToString:couponModel.couponId]) {
                model.couponStats = couponModel.couponStats;
                break;
            }
        }
        [self.tableView reloadData];
    }
}

- (void)setIsCanReceive:(BOOL)isCanReceive {
    _isCanReceive = isCanReceive;
    [self.tableView reloadData];
}

#pragma mark - 手势

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([self.contentView pointInside:[touch locationInView:self.contentView] withEvent:nil] && !self.contentView.isHidden) {
        return NO;
    }
    return YES;
}

- (void)actionTap:(UITapGestureRecognizer *)tap {
    [self showCouponListView:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.liveGoodsViewModel.couponsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFFullLiveCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ZFFullLiveCouponCell.class)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.liveGoodsViewModel.couponsArray.count > indexPath.row) {
        ZFGoodsDetailCouponModel *model = self.liveGoodsViewModel.couponsArray[indexPath.row];
        [cell configurate:model canReceive:self.isCanReceive];
    }
    
    @weakify(self)
    @weakify(cell)
    cell.selectBlock = ^{
        @strongify(self)
        @strongify(cell)
        [self receiveCoupon:cell];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 108;
}


- (void)receiveCoupon:(ZFFullLiveCouponCell *)cell {
    if (cell) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (self.liveGoodsViewModel.couponsArray.count > indexPath.row) {
            ZFGoodsDetailCouponModel *model = self.liveGoodsViewModel.couponsArray[indexPath.row];
            if (self.selectCouponBlock) {
                self.selectCouponBlock(model);
            }
        }
    }
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

- (ZFCommunityLiveVideoGoodsModel *)liveGoodsViewModel {
    if (!_liveGoodsViewModel) {
        _liveGoodsViewModel = [[ZFCommunityLiveVideoGoodsModel alloc] init];
    }
    return _liveGoodsViewModel;
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
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = ZFLocalizedString(@"Live_coupon", nil);
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

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.alwaysBounceVertical = YES;
        _tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        
        _tableView.emptyDataImage = ZFImageWithName(@"blankPage_noCoupon");
//        _tableView.emptyDataTitle = @"";

        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_tableView registerClass:[ZFFullLiveCouponCell class] forCellReuseIdentifier:NSStringFromClass(ZFFullLiveCouponCell.class)];
        
        
        @weakify(self);
        [_tableView addCommunityHeaderRefreshBlock:^{
            @strongify(self);
            [self requestLiveCouponsPageData:YES];
            
            
        } footerRefreshBlock:^{
            @strongify(self);
            
        } startRefreshing:NO];
    }
    return _tableView;
}


@end
