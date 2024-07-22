//
//  ZFGoodsDetailGoodsRecommendHeaderCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/19.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailGoodsRecommendHeaderCell.h"
#import "Masonry.h"
#import "ZFFrameDefiner.h"
#import "ZFColorDefiner.h"
#import "ZFInitViewProtocol.h"
#import "ZFLocalizationString.h"
#import "ZFGoodsDetailCellTypeModel.h"
#import "GoodsDetailModel.h"
#import "YWCFunctionTool.h"

@interface ZFGoodsDetailGoodsRecommendHeaderCell ()
@property (nonatomic, strong) UIView                            *topLineView;
@property (nonatomic, strong) UILabel                           *titleLabel;
@property (nonatomic, strong) UILabel                           *itemLabel;
@property (nonatomic, strong) UIActivityIndicatorView           *activityView;
@property (nonatomic, strong) UIView                            *lineView;
@property (nonatomic, assign) BOOL                              isSimilarRecommendType;
@end

@implementation ZFGoodsDetailGoodsRecommendHeaderCell

@synthesize cellTypeModel = _cellTypeModel;

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
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.topLineView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.itemLabel];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.activityView];
}

- (void)zfAutoLayoutView {
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(8);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLineView.mas_bottom);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.itemLabel.mas_leading).offset(-12);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [self.itemLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.itemLabel.mas_centerX).offset(-10);
        make.centerY.mas_equalTo(self.itemLabel.mas_centerY);
    }];
}

#pragma mark - setter

- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;
    
    // 如果推荐接口还没返回就显示转圈
    if (!cellTypeModel.detailModel.recommendPortSuccess) return;
    
    NSArray *modelArray = cellTypeModel.detailModel.recommendModelArray;
    NSInteger modelCount = ZFJudgeNSArray(modelArray) ? modelArray.count : 0;
    
    NSString *countText = [NSString stringWithFormat:@"%ld",modelCount];
    self.itemLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"list_item", nil), countText];
    //self.lineView.hidden = modelCount>0 ? YES : NO;
    self.lineView.hidden =YES;
    [self.activityView stopAnimating];
    self.itemLabel.hidden = NO;
}

#pragma mark - getter
- (UIView *)topLineView {
    if (!_topLineView) {
        _topLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _topLineView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
    }
    return _topLineView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.text = ZFLocalizedString(@"Detail_Product_Recommend",nil);
    }
    return _titleLabel;
}

- (UILabel *)itemLabel {
    if (!_itemLabel) {
        _itemLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _itemLabel.backgroundColor = [UIColor whiteColor];
        _itemLabel.textAlignment = NSTextAlignmentCenter;
        _itemLabel.font = [UIFont systemFontOfSize:12];
        _itemLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _itemLabel.text = @"";
        _itemLabel.hidden = YES;
    }
    return _itemLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
        _lineView.hidden = YES;
    }
    return _lineView;
}

- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
        [_activityView hidesWhenStopped];
        [_activityView startAnimating];
    }
    return _activityView;
}

@end
