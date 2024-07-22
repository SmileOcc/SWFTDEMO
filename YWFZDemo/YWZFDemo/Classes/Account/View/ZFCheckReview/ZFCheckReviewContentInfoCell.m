

//
//  ZFCheckReviewContentInfoCell.m
//  ZZZZZ
//
//  Created by YW on 2018/2/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCheckReviewContentInfoCell.h"
#import "ZFInitViewProtocol.h"
#import "CheckReviewModel.h"
#import "StarRatingControl.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCheckReviewContentInfoCell() <ZFInitViewProtocol>
@property (nonatomic, strong) StarRatingControl *ratingView;
@property (nonatomic, strong) UILabel           *contentLabel;
@property (nonatomic, strong) UILabel           *addTimeLabel;

@end

@implementation ZFCheckReviewContentInfoCell
#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}


#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.ratingView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.addTimeLabel];
    
}

- (void)zfAutoLayoutView {
    [self.ratingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 16));
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.ratingView.mas_bottom).offset(10);
    }];
    
    [self.addTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
    }];
}

#pragma mark - setter
- (void)setCheckModel:(CheckReviewModel *)checkModel {
    _checkModel = checkModel;
    self.ratingView.rating = [_checkModel.rate_overall floatValue];
    self.contentLabel.text = _checkModel.content;
    self.addTimeLabel.text = _checkModel.add_time;
}

#pragma mark - getter
- (StarRatingControl *)ratingView {
    if (!_ratingView) {
        _ratingView = [[StarRatingControl alloc] initWithFrame:CGRectZero andDefaultStarImage:[UIImage imageNamed:@"starNormal"] highlightedStar:[UIImage imageNamed:@"starHigh"]];
        _ratingView.enabled = NO;
        [_ratingView convertUIWithARLanguage];
        _ratingView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;

    }
    return _ratingView;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont fontWithName:FONT_HIGHT size:12];
        _contentLabel.textColor = ZFCOLOR(102, 102, 102, 1.0);
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UILabel *)addTimeLabel {
    if (!_addTimeLabel) {
        _addTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addTimeLabel.font = [UIFont systemFontOfSize:12];
        _addTimeLabel.textColor = ZFCOLOR(170, 170, 170, 1.0);
    }
    return _addTimeLabel;
}

@end
