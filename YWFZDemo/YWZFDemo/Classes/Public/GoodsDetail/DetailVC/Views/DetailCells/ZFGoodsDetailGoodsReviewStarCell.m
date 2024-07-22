//
//  ZFGoodsDetailGoodsReviewStarCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailGoodsReviewStarCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFGoodsReviewStarsView.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "GoodsDetailsReviewsModel.h"
#import "ZFGoodsReviewsRankingView.h"
#import "GoodsDetailModel.h"

@interface ZFGoodsDetailGoodsReviewStarCell() <ZFInitViewProtocol>
@property (nonatomic, strong) UIView                    *topLineView;
@property (nonatomic, strong) UILabel                   *titleLabel;
@property (nonatomic, strong) UILabel                   *pointsLabel;
@property (nonatomic, strong) ZFGoodsReviewStarsView    *starsView;
@property (nonatomic, strong) ZFGoodsReviewsRankingView *rankingView;
@property (nonatomic, strong) UIView                    *lineView;
@end

@implementation ZFGoodsDetailGoodsReviewStarCell

@synthesize cellTypeModel = _cellTypeModel;

#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
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
    [self.contentView addSubview:self.topLineView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.pointsLabel];
    [self.contentView addSubview:self.starsView];
    [self.contentView addSubview:self.rankingView];
    [self.contentView addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.leading.mas_equalTo(self.contentView.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing);
        make.height.mas_equalTo(8);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topLineView.mas_bottom).offset(14);
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
        make.width.mas_equalTo(KScreenWidth - (16 + 53));
//        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-53);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - setter
- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;
    
    NSInteger reViewCount = cellTypeModel.reviewsRankingModel.reviewCount;
    if (reViewCount > 0) {
        
        self.pointsLabel.hidden = NO;
        self.starsView.hidden = NO;
        self.titleLabel.text = [NSString stringWithFormat:@"%@(%ld)", ZFLocalizedString(@"Detail_Product_Reviews", nil), (long)reViewCount];
        
        float agvRate = cellTypeModel.reviewsRankingModel.agvRate;
        self.pointsLabel.text = [NSString stringWithFormat:@"%.1lf", agvRate];
        self.starsView.rateAVG = [NSString stringWithFormat:@"%lf", agvRate];
        
    } else {
        self.titleLabel.text = @"0";
        self.pointsLabel.hidden = YES;
        self.starsView.hidden = YES;
    }
    
    // 评论 适合大小比例
    [self.rankingView refreshSmallValue:(cellTypeModel.reviewsRankingModel.small)
                            middleValue:(cellTypeModel.reviewsRankingModel.middle)
                             largeValue:(cellTypeModel.reviewsRankingModel.big)];
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
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
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
    }
    return _rankingView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    }
    return _lineView;
}


@end
