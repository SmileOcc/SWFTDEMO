//
//  YSMsgCell.m
//  YoshopPro
//
//  Created by Stone on 2017/5/2.
//  Copyright © 2017年 yoshop. All rights reserved.
//

#import "YSMessageCell.h"
#import "YSMessageSubModel.h"

@interface YSMsgCell()

@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *rightArrowImgview;
@property (nonatomic, strong) UILabel *redDotLabel;

@end

@implementation YSMsgCell


#pragma mark - public methods

+ (YSMsgCell *)cellWithTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    
    return [tableView dequeueReusableCellWithIdentifier:@"YSMsgCell" forIndexPath:indexPath];
}

#pragma mark - life cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        [self setUpSubviews];
    }
    return self;
}

-  (void)prepareForReuse
{
    [super prepareForReuse];
    self.iconView.image = nil;
    self.titleLab.text = nil;
    self.titleSubLab.text = nil;
    self.timeLab.text = nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - private methods

- (void)setUpSubviews
{
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.redDotLabel];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.titleSubLab];
    [self.contentView addSubview:self.timeLab];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.rightArrowImgview];
    
    [self makeConstraints];
}


- (void)makeConstraints
{
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.leading.mas_equalTo(16);
        make.width.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
    }];
    
    [_redDotLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(12);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(48);
        make.width.height.mas_equalTo(8);
    }];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_iconView.mas_top).offset(0);
        make.leading.mas_equalTo(_iconView.mas_trailing).offset(12);
    }];
    
    [_titleSubLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titleLab.mas_bottom).offset(0);
        make.leading.mas_equalTo(_iconView.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-10);
    }];
    
    [_timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_titleLab.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-10);
    }];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(0);
        make.height.mas_equalTo(@(MIN_PIXEL));
    }];
    
    [_rightArrowImgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
}

- (NSString *)getStringByTime:(NSInteger)time
{
    if (0 == time)
    {
        return @"";
    }
    NSDate *pushDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSDate *curDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"MMM. dd yyyy";
    NSString *curDay = [formatter stringFromDate:curDate];
    NSString *pushDay = [formatter stringFromDate:pushDate];
    if ([curDay isEqualToString:pushDay])
    {
        formatter.dateFormat = @"HH:mm";
        pushDay = [formatter stringFromDate:pushDate];
    }
    return pushDay;
}


#pragma mark - setters and getters

- (UIImageView *)iconView
{
    if (!_iconView)
    {
        _iconView = [UIImageView new];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _iconView;
}

- (JSBadgeView *)messagebadge
{
//    if (!_messagebadge)
//    {
//        JSBadgeViewAlignment alignment = [SystemConfigUtils isRightToLeftShow] ? JSBadgeViewAlignmentTopLeft : JSBadgeViewAlignmentTopRightCorner;
//        _messagebadge = [[JSBadgeView alloc] initWithParentView:self.iconView alignment:alignment];
//    }
    return _messagebadge;
}

- (UILabel *)titleLab
{
    if (!_titleLab)
    {
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont boldSystemFontOfSize:15];
        _titleLab.textColor = YSCOLOR_51_51_51;
        [_titleLab sizeToFit];
    }
    return _titleLab;
}

- (UILabel *)titleSubLab
{
    if (!_titleSubLab)
    {
        _titleSubLab = [UILabel new];
        _titleSubLab.font = [UIFont systemFontOfSize:12];
        _titleSubLab.textColor = YSCOLOR_153_153_153;
        [_titleSubLab sizeToFit];
    }
    return _titleSubLab;
}

- (UILabel *)timeLab
{
    if (!_timeLab)
    {
        _timeLab = [UILabel new];
        _timeLab.font = [UIFont systemFontOfSize:12];
        _timeLab.textColor = YSCOLOR_153_153_153;
        [_timeLab sizeToFit];
    }
    return _timeLab;
}

- (UILabel *)redDotLabel
{
    if (!_redDotLabel)
    {
        _redDotLabel = [UILabel new];
        _redDotLabel.layer.cornerRadius = 4;
        _redDotLabel.clipsToBounds = YES;
        _redDotLabel.backgroundColor = [UIColor redColor];
    }
    return _redDotLabel;
}

- (UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [UIView new];
        _lineView.backgroundColor = YSCOLOR_239_239_239;
    }
    return _lineView;
}

- (UIImageView *)rightArrowImgview
{
    if (!_rightArrowImgview)
    {
        _rightArrowImgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cellArrow"]];
        _rightArrowImgview.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _rightArrowImgview;
}

- (void)setMessagesubModel:(YSMessageSubModel *)messagesubModel
{
    if (!messagesubModel)
    {
        self.titleSubLab.text = NSLocalizedString(@"messageNoMsgTip",nil);
        return;
    }
    _messagesubModel = messagesubModel;
    if ([messagesubModel.unreadMsgCount integerValue] > 0)
    {
        self.messagebadge.badgeText = messagesubModel.unreadMsgCount;
    }
    else
    {
        self.messagebadge.badgeText = nil;
    }
    self.titleSubLab.text = messagesubModel.lastMsg.content;
    if (messagesubModel.lastMsg.createTime > 0)
    {
        self.timeLab.text = [self getStringByTime:messagesubModel.lastMsg.createTime];
    }
}

@end
