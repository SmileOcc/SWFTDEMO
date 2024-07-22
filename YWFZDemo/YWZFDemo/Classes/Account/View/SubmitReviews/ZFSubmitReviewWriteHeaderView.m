

//
//  ZFSubmitReviewWriteHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/12.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSubmitReviewWriteHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "StarRatingControl.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import "ZFLocalizationString.h"
#import "Masonry.h"

@interface ZFSubmitReviewWriteHeaderView() <ZFInitViewProtocol, StarRatingDelegate>
@property (nonatomic, strong) UIView                *lineView;
@property (nonatomic, strong) StarRatingControl     *starsView;
@property (nonatomic, strong) UIImageView           *goodsImageView;
@property (nonatomic, strong) UILabel               *tipsLabel;
@property (nonatomic, strong) UILabel               *ratingLabel;

@end

@implementation ZFSubmitReviewWriteHeaderView
#pragma mark - init methods
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <StarRatingDelegate>
- (void)newRating:(StarRatingControl *)control :(float)rating {
    if (self.submitReviewWriteRatingCompletionHandler) {
        self.submitReviewWriteRatingCompletionHandler(rating);
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.goodsImageView];
    [self.contentView addSubview:self.tipsLabel];
    [self.contentView addSubview:self.ratingLabel];
    [self.contentView addSubview:self.starsView];
}

- (void)zfAutoLayoutView {
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.contentView);
        make.height.mas_equalTo(10);
    }];

    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(12);
        make.size.mas_equalTo(CGSizeMake(90, 120));
    }];
    
    [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.goodsImageView.mas_trailing).offset(12);
        make.width.mas_equalTo(6);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(18);
    }];
    
    [self.ratingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.tipsLabel.mas_trailing).offset(2);
        make.top.mas_equalTo(self.lineView.mas_bottom).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.starsView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.ratingLabel);
        make.top.mas_equalTo(self.ratingLabel.mas_bottom).offset(12);
        make.size.mas_equalTo(CGSizeMake(170, 50));
    }];
    
    self.starsView.rating = 5.f;
}

#pragma mark - setter
- (void)setModel:(ZFOrderReviewModel *)model {
    _model = model;
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:_model.goods_info.goods_grid]
                               placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                    options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                   progress:nil
                                  transform:nil
                                 completion:nil];
    self.starsView.rating = model.userSelectStartCount;
}

#pragma mark - getter
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    }
    return _lineView;
}

- (StarRatingControl *)starsView {
    if (!_starsView) {
        _starsView = [[StarRatingControl alloc] initWithFrame:CGRectZero andDefaultStarImage:[UIImage imageNamed:@"starNormal"] highlightedStar:[UIImage imageNamed:@"starHigh"]];
        _starsView.enabled = YES;
        _starsView.delegate = self;

        _starsView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        _starsView.rating = 0;
    }
    return _starsView;
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _goodsImageView;
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipsLabel.font = [UIFont systemFontOfSize:14];
        _tipsLabel.textColor = ZFCOLOR(255, 168, 0, 1.f);
        _tipsLabel.text = @"*";
    }
    return _tipsLabel;
}

- (UILabel *)ratingLabel {
    if (!_ratingLabel) {
        _ratingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _ratingLabel.font = [UIFont systemFontOfSize:14];
        _ratingLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
        _ratingLabel.text = ZFLocalizedString(@"WriteReview_Rating", nil);
    }
    return _ratingLabel;
}

@end
