//
//  ZFGoodsDetailOutfitsListView.m
//  ZZZZZ
//
//  Created by YW on 2019/9/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailOutfitsListView.h"
#import "ZFInitViewProtocol.h"
#import "ZFWishListVerticalStyleCell.h"
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
#import "ZFGoodsDetailEnumDefiner.h"
#import "Constants.h"
#import "ZFGoodsDetailAnalytics.h"

static NSString *const kZFGoodsDetailOutfitsIdentifier = @"kZFGoodsDetailOutfitsIdentifier";

@interface ZFGoodsDetailOutfitsListView ()
<ZFInitViewProtocol,
UITableViewDelegate,
UITableViewDataSource,
ZFWishListVerticalStyleCellDelegate
>

@property (nonatomic, strong) NSArray<ZFGoodsModel *> *goodsModelArr;
@property (nonatomic, strong) UIView                *maskBgView;
@property (nonatomic, strong) UIView                *containView;
@property (nonatomic, strong) UIView                *topView;
@property (nonatomic, strong) BigClickAreaButton    *closeButton;
@property (nonatomic, strong) UILabel               *topTitleLabel;
@property (nonatomic, strong) UITableView           *tableView;
@end

@implementation ZFGoodsDetailOutfitsListView

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
        make.height.mas_equalTo(self.outfitsListViewHeight);
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
    if (!CGRectEqualToRect(self.containView.bounds, CGRectZero)) {
        [self.containView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                           cornerRadii:CGSizeMake(8, 8)];
    }
    
    if (!CGRectEqualToRect(self.topView.bounds, CGRectZero)) {
        [self.topView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                        cornerRadii:CGSizeMake(8, 8)];
    }
}

- (CGFloat)outfitsListViewHeight {
    if (IPHONE_X_5_15){
         return 584;
    } else {
       return 557;
    }
}

#pragma mark -===========刷新数据===========

/**
 * 显示穿搭列表
 */
- (void)convertOutfitsListView:(NSArray<ZFGoodsModel *> *)goodsModelArr
                   showOutfits:(BOOL)isShow {
    self.goodsModelArr = goodsModelArr;
    [self.tableView reloadData];
    
    [self.containView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(self.outfitsListViewHeight);
        if (isShow) {
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
                         self.maskBgView.alpha = isShow ? 1.0 : 0.0;
                         [self layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.hidden = !isShow;
                     }];
    
    ///growingIO统计
    [self.goodsModelArr enumerateObjectsUsingBlock:^(ZFGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        [ZFGrowingIOAnalytics ZFGrowingIOCouponShow:obj.discounts page:@"GoodsDetailCouponPage"];
    }];
}

#pragma mark - <ZFWishListVerticalStyleCellDelegate>

- (void)ZFWishListVerticalStyleCellDidClickFindRelated:(ZFGoodsModel *)goodsModel {
    if (self.outfitsActionBlock) {
        self.outfitsActionBlock(goodsModel, ZFOutfitsList_FindRelatedActionType);
    }
}

- (void)ZFWishListVerticalStyleCellDidClickAddCartBag:(ZFGoodsModel *)goodsModel {
    if (self.outfitsActionBlock) {
        self.outfitsActionBlock(goodsModel, ZFOutfitsList_AddCartBagActionType);
    }
}

#pragma mark -===========按钮事件===========

- (void)closeButtonAction {
    [self convertOutfitsListView:self.goodsModelArr showOutfits:NO];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.goodsModelArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZFWishListVerticalStyleCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFGoodsDetailOutfitsIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.goodsModel = self.goodsModelArr[indexPath.row];;
    cell.delegate = self;
    
    ///商详穿搭关联商品公用此Cell时刷新部分UI
    [cell refreshUIStyleFromGoodsDetailOutfits];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    YWLog(@"--- didSelectRowAtIndexPath ----");
    ZFGoodsModel *goodsModel = self.goodsModelArr[indexPath.row];
    if (self.outfitsActionBlock) {
        self.outfitsActionBlock(goodsModel, ZFOutfitsList_ShowDetailActionType);
    }
    [ZFGoodsDetailAnalytics outfitsClickGoods:goodsModel outfitsId:self.tmpShowOutfitsId];
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
        _containView.backgroundColor = ZFCOLOR_WHITE;
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
        _topTitleLabel.font = ZFFontBoldSize(18);
        _topTitleLabel.textAlignment = NSTextAlignmentCenter;
        NSString *showText = ZFLocalizedString(@"Community_outfit_goods",nil);
        _topTitleLabel.text = showText;
//        NSString *upText = [showText uppercaseString];
//        if (!ZFIsEmptyString(upText)) {
//            _topTitleLabel.text = upText;
//        }
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
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = ZFCOLOR_WHITE;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 120;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 15, 0);
        _tableView.alwaysBounceVertical = YES;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerClass:[ZFWishListVerticalStyleCell class] forCellReuseIdentifier:kZFGoodsDetailOutfitsIdentifier];
    }
    return _tableView;
}

@end
