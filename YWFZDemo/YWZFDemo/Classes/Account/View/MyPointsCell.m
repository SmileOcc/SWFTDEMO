//
//  DRewardsCell.m
//  Dezzal
//
//  Created by 7FD75 on 16/7/28.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "MyPointsCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeFontManager.h"

@interface MyPointsCell () <ZFInitViewProtocol>

@property (nonatomic, strong) YYAnimatedImageView   *timeIcon;
@property (nonatomic, strong) UILabel       *dateLabel;
@property (nonatomic, strong) UILabel       *detailLabel;
@property (nonatomic, strong) UILabel       *rewardLabel;
@end

@implementation MyPointsCell
- (void)prepareForReuse {
    [super prepareForReuse];
    self.rewardLabel.text = nil;
    self.detailLabel.text = nil;
    self.dateLabel.text = nil;
}

#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - interface methods
+ (MyPointsCell *)pointCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[MyPointsCell class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    [self.contentView addSubview:self.timeIcon];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.rewardLabel];
    [self.contentView addSubview:self.detailLabel];
}

- (void)zfAutoLayoutView {
    [self.timeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView).offset(16);
        make.top.equalTo(self.contentView).offset(16);
        make.size.mas_equalTo(CGSizeMake(self.timeIcon.image.size.width, self.timeIcon.image.size.width));
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.timeIcon.mas_trailing).offset(4);
        make.centerY.equalTo(self.timeIcon.mas_centerY);
    }];
    
    [self.rewardLabel sizeToFit];
    [self.rewardLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.contentView).offset(-12).priorityHigh();
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.timeIcon);
        make.top.equalTo(self.timeIcon.mas_bottom).offset(8);
        make.trailing.equalTo(self.rewardLabel.mas_leading).offset(-12).priorityLow();
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-16);
    }];
}

#pragma mark - setter
- (void)setModel:(PointsModel *)model {
    _model = model;
    _dateLabel.text = model.adddate;
    _detailLabel.text = model.note;
    
    NSString * outOrIn = model.outgo > 0 ? @"-":@"+";
    CGFloat outInNum = 0.0;
    outInNum = [outOrIn isEqualToString:@"+"] ? model.income:model.outgo;
    NSString *rewardText = [NSString stringWithFormat:@"%@%.0f",outOrIn,outInNum];

    NSRange range = [rewardText rangeOfString:outOrIn];
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:rewardText];
    
    if (model.outgo > 0) {
        self.rewardLabel.textColor = ZFC0x999999();
        [attributeString addAttributes:@{NSFontAttributeName : ZFFontBoldSize(20), NSForegroundColorAttributeName : ZFC0x999999()} range:range];
    } else {
        self.rewardLabel.textColor = ZFC0xFE5269();
        [attributeString addAttributes:@{NSFontAttributeName : ZFFontBoldSize(20), NSForegroundColorAttributeName : ZFC0xFE5269()} range:range];
    }
    self.rewardLabel.attributedText = attributeString;
}

#pragma mark - getter
- (YYAnimatedImageView *)timeIcon {
    if (!_timeIcon) {
        _timeIcon = [[YYAnimatedImageView alloc] init];
        _timeIcon.image = [UIImage imageNamed:@"time"];
    }
    return _timeIcon;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = ZFCOLOR(178, 178, 178, 1.0);
        _dateLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    return _dateLabel;
}

- (UILabel *)rewardLabel {
    if (!_rewardLabel) {
        _rewardLabel = [[UILabel alloc] init];
        _rewardLabel.textColor = ZFC0xFE5269();
        [_rewardLabel setTextAlignment:NSTextAlignmentRight];
        _rewardLabel.font = ZFFontBoldNumbers(20);
    }
    return _rewardLabel;
}

- (UILabel *)detailLabel {
    if (!_detailLabel) {
        _detailLabel = [[UILabel alloc] init];
        _detailLabel.textColor = ZFCOLOR(0, 0, 0, 1.0);
        _detailLabel.font = [UIFont systemFontOfSize:16.0f];
        _detailLabel.preferredMaxLayoutWidth = KScreenWidth * 0.7;
        _detailLabel.numberOfLines = 0;
        _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _detailLabel;
}
@end
