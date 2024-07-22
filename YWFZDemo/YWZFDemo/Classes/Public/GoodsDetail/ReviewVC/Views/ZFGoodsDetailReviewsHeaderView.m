
//
//  ZFGoodsDetailReviewsHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2017/11/21.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsDetailReviewsHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFGoodsReviewStarsView.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"
#import "GoodsDetailsReviewsModel.h"
#import "ZFGoodsReviewsRankingView.h"

@interface ZFGoodsDetailReviewsHeaderView() <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel                   *titleLabel;
@property (nonatomic, strong) UILabel                   *pointsLabel;
@property (nonatomic, strong) ZFGoodsReviewStarsView    *starsView;
@property (nonatomic, strong) ZFGoodsReviewsRankingView *rankingView;
@property (nonatomic, strong) UIView                    *lineView;
@end

@implementation ZFGoodsDetailReviewsHeaderView

#pragma mark - init methods

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.pointsLabel];
    [self.contentView addSubview:self.starsView];
    [self.contentView addSubview:self.rankingView];
    [self.contentView addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(14);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
    }];
    
    [self.pointsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.width.mas_equalTo(30);
    }];
    
    [self.starsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(95, 20));
        make.trailing.mas_equalTo(self.pointsLabel.mas_leading);
    }];
    
    [self.rankingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(31);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-53);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - setter
- (void)setModel:(GoodsDetailModel *)model {
    _model = model;
    self.titleLabel.text = [NSString stringWithFormat:@"%@(%@)", ZFLocalizedString(@"Detail_Product_Reviews", nil), _model.reViewCount ?: @"0"];
    if ([_model.reViewCount integerValue] > 0) {
        self.pointsLabel.hidden = NO;
        self.starsView.hidden = NO;
        self.pointsLabel.text = [NSString stringWithFormat:@"%.1lf", [_model.rateAVG floatValue]];
        self.starsView.rateAVG = _model.rateAVG;
    } else {
        self.pointsLabel.hidden = YES;
        self.starsView.hidden = YES;
    }
}

- (void)setReviewsRankingModel:(ReviewsSizeOverModel *)reviewsRankingModel {
    _reviewsRankingModel = reviewsRankingModel;
    self.rankingView.hidden = NO;
    self.lineView.hidden = NO;
    [self.rankingView refreshSmallValue:(reviewsRankingModel.small)
                            middleValue:(reviewsRankingModel.middle)
                             largeValue:(reviewsRankingModel.big)];
}

#pragma mark - getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _titleLabel.text = [NSString stringWithFormat:@"%@(0)", ZFLocalizedString(@"Detail_Product_Reviews", nil)];
    }
    return _titleLabel;
}

- (UILabel *)pointsLabel {
    if (!_pointsLabel) {
        _pointsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _pointsLabel.backgroundColor = [UIColor whiteColor];
        _pointsLabel.textColor = ZFCOLOR(255, 168, 0, 1.f);
        _pointsLabel.font = [UIFont systemFontOfSize:14];
        _pointsLabel.textAlignment = NSTextAlignmentRight;
        _pointsLabel.hidden = YES;
    }
    return _pointsLabel;
}

- (ZFGoodsReviewStarsView *)starsView {
    if (!_starsView) {
        _starsView = [[ZFGoodsReviewStarsView alloc] initWithFrame:CGRectZero];
        _starsView.hidden = YES;
    }
    return _starsView;
}

- (ZFGoodsReviewsRankingView *)rankingView {
    if (!_rankingView) {
        _rankingView = [[ZFGoodsReviewsRankingView alloc] initWithFrame:CGRectZero];
        _rankingView.hidden = YES;
    }
    return _rankingView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1);
        _lineView.hidden = YES;
    }
    return _lineView;
}


@end
