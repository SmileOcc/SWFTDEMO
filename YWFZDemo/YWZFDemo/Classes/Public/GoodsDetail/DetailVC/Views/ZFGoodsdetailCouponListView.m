//
//  ZFGoodsdetailCouponListView.m
//  ZZZZZ
//
//  Created by YW on 2018/8/19.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFGoodsdetailCouponListView.h"
#import "ZFInitViewProtocol.h"
#import "ZFGoodsDetailCouponCell.h"
#import "ZFGoodsDetailCouponModel.h"
#import "ZFGoodsDetailViewModel.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFGrowingIOAnalytics.h"
#import "BigClickAreaButton.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

static NSString *const kZFGoodsDetailCouponIdentifier = @"kZFGoodsDetailCouponIdentifier";

@interface ZFGoodsdetailCouponListView () <ZFInitViewProtocol, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray<ZFGoodsDetailCouponModel *> *couponDataArr;
@property (nonatomic, strong) UIView                *maskBgView;
@property (nonatomic, strong) UIView                *containView;
@property (nonatomic, strong) UIView                *topView;
@property (nonatomic, strong) BigClickAreaButton    *closeButton;
@property (nonatomic, strong) UILabel               *topTitleLabel;
@property (nonatomic, strong) UITableView           *tableView;
@end

@implementation ZFGoodsdetailCouponListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.maskBgView];
    [self addSubview:self.containView];
    [self addSubview:self.topView];
    [self.topView addSubview:self.topTitleLabel];
    [self.topView addSubview:self.closeButton];
    [self.containView addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.maskBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_bottom);
        make.height.mas_equalTo(kCouponListViewHeight+5);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.containView);
        make.height.mas_equalTo(44);
    }];
    
    [self.topTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.topView);
        make.height.mas_equalTo(44);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.mas_equalTo(self.topView);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];

    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.containView);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.bottom.mas_equalTo(self.containView).offset(-(IPHONE_X_5_15 ? 34 : 0));
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGRectEqualToRect(self.topView.bounds, CGRectZero)) {
        [self.topView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                       cornerRadii:CGSizeMake(8, 8)];
    }
}

#pragma mark -===========刷新数据===========
/**
 * 刷新领劵状态
 */
- (void)refreshCouponWithIndex:(NSIndexPath *)indexPath {
    if (self.couponDataArr.count > indexPath.row) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
    }
}

/**
 * 点击领劵刷新列表
 */
- (void)refreshListData:(NSArray<ZFGoodsDetailCouponModel *> *)couponDataArr {
    self.couponDataArr = couponDataArr;
    [self.tableView reloadData];
}

/**
 * 是否显示优惠券列表
 */
- (void)convertCouponListView:(NSArray<ZFGoodsDetailCouponModel *> *)couponDataArr
                   showCoupon:(BOOL)isShowCoupon {
    self.couponDataArr = couponDataArr;
    [self.tableView reloadData];
    
    [self.containView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(kCouponListViewHeight+5);
        if (isShowCoupon) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(5);
        } else {
            make.top.mas_equalTo(self.mas_bottom);
        }
    }];
    [UIView animateWithDuration:0.3 delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.maskBgView.alpha = isShowCoupon ? 1.0 : 0.0;
                         [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.hidden = !isShowCoupon;
    }];
    
    ///growingIO统计
    [self.couponDataArr enumerateObjectsUsingBlock:^(ZFGoodsDetailCouponModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ZFGrowingIOAnalytics ZFGrowingIOCouponShow:obj.discounts page:@"GoodsDetailCouponPage"];
    }];
}

#pragma mark -===========请求领劵===========

/**
 * 请求领劵
 */
- (void)requestGetGoodsCupon:(ZFGoodsDetailCouponModel *)couponModel indexPath:(NSIndexPath *)indexPath{
    if (ZFIsEmptyString(couponModel.couponId)) return;
    [ZFGrowingIOAnalytics ZFGrowingIOCouponClick:couponModel.discounts page:@"GoodsDetailCouponPage"];
    if (self.getCouponBlock) {
        self.getCouponBlock(couponModel, indexPath);
    }
}

#pragma mark -===========按钮事件===========

- (void)closeButtonAction {
    [self convertCouponListView:self.couponDataArr showCoupon:NO];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.couponDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFGoodsDetailCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFGoodsDetailCouponIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    ZFGoodsDetailCouponModel *couponModel = self.couponDataArr[indexPath.row];
    cell.couponModel = couponModel;
    @weakify(self)
    [cell setReceiveCouponBlock:^(ZFGoodsDetailCouponModel *couponModel) {
        @strongify(self)
        [self requestGetGoodsCupon:couponModel indexPath:indexPath];
    }];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YWLog(@"--- didSelectRowAtIndexPath ----");
}

#pragma mark -===========init UI===========

- (UIView *)maskBgView {
    if (!_maskBgView) {
        _maskBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskBgView.backgroundColor = ColorHex_Alpha(0x000000, 0.4);
        _maskBgView.alpha = 0.0;
        @weakify(self);
        [_maskBgView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            [self closeButtonAction];
        }];
    }
    return _maskBgView;
}

- (UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc] initWithFrame:CGRectZero];
        _containView.backgroundColor = ZFC0xF2F2F2();
        _containView.layer.cornerRadius = 8;
        _containView.layer.masksToBounds = YES;
    }
    return _containView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _topView;
}

- (UILabel *)topTitleLabel {
    if (!_topTitleLabel) {
        _topTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topTitleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _topTitleLabel.font = ZFFontSystemSize(16);
        _topTitleLabel.textAlignment = NSTextAlignmentCenter;
        NSString *showText = ZFLocalizedString(@"Detail_Product_CouponsList_Title",nil);
        _topTitleLabel.text = showText;
        NSString *upText = [showText uppercaseString];
        if (!ZFIsEmptyString(upText)) {
            _topTitleLabel.text = upText;
        }
    }
    return _topTitleLabel;
}

- (BigClickAreaButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"size_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.clickAreaRadious = 64;
    }
    return _closeButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = YES;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = ZFC0xF2F2F2();
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 120;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0);
        _tableView.alwaysBounceVertical = YES;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerClass:[ZFGoodsDetailCouponCell class] forCellReuseIdentifier:kZFGoodsDetailCouponIdentifier];
    }
    return _tableView;
}

@end
