

//
//  ZFReviewDetailHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2017/11/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFReviewDetailHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFReviewsDetailStarsView.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "ZFGoodsReviewsRankingView.h"

@interface ZFReviewDetailHeaderView() <ZFInitViewProtocol>
@property (nonatomic, strong) UIView                        *lineView;
@property (nonatomic, strong) UILabel                       *pointsLabel;
@property (nonatomic, strong) ZFReviewsDetailStarsView      *starsView;
@property (nonatomic, strong) ZFGoodsReviewsRankingView     *rankingView;
@property (nonatomic, strong) UILabel                       *reviewsLabel;
@end

@implementation ZFReviewDetailHeaderView
#pragma mark - init methods
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.pointsLabel];
    [self.contentView addSubview:self.starsView];
    [self.contentView addSubview:self.reviewsLabel];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.rankingView];
}

- (void)zfAutoLayoutView {
    [self.pointsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(48);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.centerY.mas_equalTo(self.contentView);
    }];
    
    [self.starsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.pointsLabel.mas_trailing).offset(16);
        make.top.mas_equalTo(self.pointsLabel.mas_top);
        make.height.mas_equalTo(22);
    }];
    
    [self.reviewsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.pointsLabel.mas_trailing).offset(16);
        make.bottom.mas_equalTo(self.pointsLabel);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - setter
- (void)setPoints:(NSString *)points {
    _points = points;
    self.starsView.rateAVG = _points;
    self.pointsLabel.text = [NSString stringWithFormat:@"%.1lf", [_points floatValue]];
}

- (void)setReviewsCount:(NSInteger)reviewsCount {
    _reviewsCount = reviewsCount;
    self.reviewsLabel.text = [NSString stringWithFormat:@"%lu %@", _reviewsCount, ZFLocalizedString(@"GoodsReviews_HeaderView_Reviews", nil)];
}

-(void)setRankingModel:(ReviewsSizeOverModel *)rankingModel
{
    _rankingModel = rankingModel;
    self.rankingView.hidden = NO;
    
    self.pointsLabel.font = [UIFont systemFontOfSize:60];
    [self.pointsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top).mas_offset(6);
        make.width.mas_offset(92);
        make.height.mas_offset(70);
    }];

    [self.starsView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pointsLabel.mas_bottom).mas_offset(8);
        make.centerX.mas_equalTo(self.pointsLabel);
        make.height.mas_equalTo(18);
    }];
    
    [self.rankingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).mas_offset(16);
        make.leading.mas_equalTo(self.pointsLabel.mas_trailing).mas_offset(15);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-5);
    }];

    self.reviewsLabel.font = [UIFont systemFontOfSize:12];
    [self.reviewsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-8);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-14);
    }];
    
    [self.rankingView refreshSmallValue:(rankingModel.small)
                            middleValue:(rankingModel.middle)
                             largeValue:(rankingModel.big)];
    
    [self.pointsLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.rankingView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.rankingView setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - getter
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ColorHex_Alpha(0xDDDDDD, 1.0);
    }
    return _lineView;
}

- (UILabel *)pointsLabel {
    if (!_pointsLabel) {
        _pointsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _pointsLabel.textColor = ZFCOLOR(255, 168, 0, 1.f);
        _pointsLabel.font = [UIFont boldSystemFontOfSize:64];
        _pointsLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _pointsLabel;
}

- (ZFReviewsDetailStarsView *)starsView {
    if (!_starsView) {
        BOOL showRank = YES;
        CGFloat width = 22;
        if (showRank) {
            width = 18;
        }
        _starsView = [[ZFReviewsDetailStarsView alloc] initWithFrame:CGRectZero withRateSize:CGSizeMake(width, width)];
    }
    return _starsView;
}

- (UILabel *)reviewsLabel {
    if (!_reviewsLabel) {
        _reviewsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _reviewsLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _reviewsLabel.font = [UIFont systemFontOfSize:18];
        _reviewsLabel.text = [NSString stringWithFormat:@"0 %@", ZFLocalizedString(@"GoodsReviews_HeaderView_Reviews", nil)];
    }
    return _reviewsLabel;
}

-(ZFGoodsReviewsRankingView *)rankingView
{
    if (!_rankingView) {
        _rankingView = [[ZFGoodsReviewsRankingView alloc] init];
        _rankingView.hidden = YES;
    }
    return _rankingView;
}

@end
