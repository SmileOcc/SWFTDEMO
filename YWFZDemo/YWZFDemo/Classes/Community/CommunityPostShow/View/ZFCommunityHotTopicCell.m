//
//  ZFCommunityHotTopicCell.m
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityHotTopicCell.h"

#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ExchangeManager.h"
#import "BigClickAreaButton.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "NSStringUtils.h"
#import "NSDate+ZFExtension.h"
#import "ZFLocalizationString.h"
#import "UIImage+ZFExtended.h"

@interface ZFCommunityHotTopicCell()
<
ZFInitViewProtocol
>
@end

@implementation ZFCommunityHotTopicCell

+ (ZFCommunityHotTopicCell *)topicCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    
    [tableView registerClass:[ZFCommunityHotTopicCell class] forCellReuseIdentifier:NSStringFromClass([ZFCommunityHotTopicCell class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ZFCommunityHotTopicCell class]) forIndexPath:indexPath];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}


- (void)zfInitView {
    [self.contentView addSubview:self.topicImageView];
    [self.contentView addSubview:self.topicTitleLabel];
    [self.contentView addSubview:self.topicDateLabel];
    [self.contentView addSubview:self.topicDescLabel];
    [self.contentView addSubview:self.markImageView];
}

- (void)zfAutoLayoutView {
    
    [self.topicImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.width.mas_equalTo(self.topicImageView.mas_height).multipliedBy(106/80.0);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(80);
    }];
    
    [self.markImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topicImageView.mas_centerY);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
    }];
    
    [self.topicDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topicTitleLabel.mas_leading);
        make.trailing.mas_equalTo(self.topicTitleLabel.mas_trailing);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self.topicTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topicImageView.mas_trailing).offset(5);
        make.trailing.mas_equalTo(self.markImageView.mas_leading).offset(-8);
        make.bottom.mas_equalTo(self.topicDescLabel.mas_top).offset(-4);
    }];
    
    [self.topicDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.topicTitleLabel.mas_leading);
        make.trailing.mas_equalTo(self.topicTitleLabel.mas_trailing);
        make.top.mas_equalTo(self.topicDescLabel.mas_bottom).offset(4);
    }];    
    
    [self.topicTitleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.topicDateLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.topicDescLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

    [self.markImageView setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.markImageView setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - Public Method

- (void)setHotTopicModel:(ZFCommunityHotTopicModel *)hotTopicModel {
    _hotTopicModel = hotTopicModel;
    
    self.topicTitleLabel.text = ZFToString(hotTopicModel.label);
    self.topicDescLabel.text = ZFToString(hotTopicModel.activity_content);
    self.topicDateLabel.text = [self dateStrinStart:hotTopicModel.activity_start_time endTime:hotTopicModel.activity_end_time];
    
    if(ZFIsEmptyString(hotTopicModel.pic.small_pic)) {
        self.topicImageView.image = ZFImageWithName(@"topic_hot_activity_default");
    } else {
        [self.topicImageView yy_setImageWithURL:[NSURL URLWithString:hotTopicModel.pic.small_pic]
                                    placeholder:ZFImageWithName(@"loading_AdvertBg")
                                        options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                     completion:nil];
    }
    
    self.markImageView.hidden = !hotTopicModel.isMark;
}

- (UIImageView *)topicImageView {
    if (!_topicImageView) {
        _topicImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _topicImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topicImageView.layer.masksToBounds = YES;
    }
    return _topicImageView;
}

- (UILabel *)topicTitleLabel {
    if (!_topicTitleLabel) {
        _topicTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topicTitleLabel.font = [UIFont boldSystemFontOfSize:16];
        _topicTitleLabel.textColor = ZFC0x2D2D2D();
    }
    return _topicTitleLabel;
}

- (UILabel *)topicDateLabel {
    if (!_topicDateLabel) {
        _topicDateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topicDateLabel.font = [UIFont systemFontOfSize:10];
        _topicDateLabel.textColor = ZFC0x999999();
    }
    return _topicDateLabel;
}

- (UILabel *)topicDescLabel {
    if (!_topicDescLabel) {
        _topicDescLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topicDescLabel.font = [UIFont systemFontOfSize:14];
        _topicDescLabel.textColor = ZFC0xFE5269();
    }
    return _topicDescLabel;
}

- (UIImageView *)markImageView {
    if (!_markImageView) {
        _markImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _markImageView.image = [[UIImage imageNamed:@"refine_select"] imageWithColor:ZFC0xFE5269()];
        _markImageView.hidden = YES;
    }
    return _markImageView;
}

- (NSString *)dateStrinStart:(NSString *)startTime endTime:(NSString *)endTime {
    if (ZFIsEmptyString(endTime)) {
        return @"";
    }
    NSString *timeStr = @"";
    NSDate *nowDate = [NSDate date];
    NSTimeInterval endTimeSecond = endTime.doubleValue;
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:endTimeSecond];
    NSDateFormatter *dateFormatter = nowDate.queryZFDateFormatter;
    [dateFormatter setDateFormat:@"MMM.dd,yyyy"];
    timeStr = [dateFormatter stringFromDate:detailDate];
    timeStr = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Ends_in", nil),timeStr];
    
    return timeStr;
}
@end
