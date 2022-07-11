//
//  OSSVMessageBriefCell.m
// XStarlinkProject
//
//  Created by odd on 2020/8/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVMessageBriefCell.h"

@interface OSSVMessageBriefCell()

@property (nonatomic, strong) UILabel       *timeLabel;
@property (nonatomic, strong) UIView        *bgView;
@property (nonatomic, strong) UILabel       *titleLabel;
@property (nonatomic, strong) UILabel       *descLabel;
//@property (nonatomic, strong) UIView        *circleView;

@end


@implementation OSSVMessageBriefCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setUpSubviews];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    [super setSelected:selected animated:animated];
}


#pragma mark private methods


- (void)setUpSubviews {
//    [self.contentView addSubview:self.circleView];
    [self.contentView addSubview:self.bgView];
//    [self.contentView addSubview:self.timeLabel];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.descLabel];
    [self makeConstraints];
}

- (void)makeConstraints {
//    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.contentView.mas_top).offset(12);
//        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
//        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
//    }];
    
//    [_circleView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.contentView.mas_top).offset(31);
//        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
//        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
//        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-18);
//    }];
    
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_top).offset(8);
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-16);
    }];
    
    [_descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-16);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-8);
    }];
}

#pragma mark setters and getters

- (void)setModel:(OSSVMessageModel *)model {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        [_titleLabel setTextAlignment:NSTextAlignmentRight];
        [_descLabel setTextAlignment:NSTextAlignmentRight];

    } else {
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_descLabel setTextAlignment:NSTextAlignmentRight];

    }
    
//    [self.timeLabel setText:STLToString(model.date)];
    [self.titleLabel setText:STLToString(model.title)];
    [self.descLabel setText:STLToString(model.content)];
}

- (UILabel *)timeLabel
{
    if (!_timeLabel)
    {
        _timeLabel = [UILabel new];
        _timeLabel.font = [UIFont systemFontOfSize:11];
        _timeLabel.textColor = OSSVThemesColors.col_999999;
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.numberOfLines = 1;
        [_timeLabel sizeToFit];
    }
    return _timeLabel;
}

- (UIView *)bgView
{
    if (!_bgView)
    {
        _bgView = [UIView new];
        _bgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        _bgView.layer.cornerRadius = 2.0;
        _bgView.layer.masksToBounds = YES;
    }
    return _bgView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [OSSVThemesColors col_333333];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 0;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UILabel *)descLabel
{
    if (!_descLabel)
    {
        _descLabel = [UILabel new];
        _descLabel.font = [UIFont systemFontOfSize:10];
        _descLabel.textColor = [OSSVThemesColors col_333333];
        _descLabel.textAlignment = NSTextAlignmentLeft;
        _descLabel.numberOfLines = 0;
        [_descLabel sizeToFit];
    }
    return _descLabel;
}


//- (UIView *)circleView
//{
//    if (!_circleView)
//    {
//        _circleView = [[UIView alloc] init];
//        [_circleView setBackgroundColor:OSSVThemesColors.col_EFEFEF];
//    }
//    return _circleView;
//}


@end
