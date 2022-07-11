//
//  OSSVMessageSystemCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageSystemCell.h"

@interface OSSVMessageSystemCell()

@property (nonatomic, strong) UILabel       *timeLabel;
@property (nonatomic, strong) UIView        *bgView;
@property (nonatomic, strong) UILabel       *titleLabel;

@end

@implementation OSSVMessageSystemCell

#pragma mark life cycle

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
    [self.contentView addSubview:self.bgView];
    [self.contentView addSubview:self.timeLabel];
    [self.bgView addSubview:self.titleLabel];
    [self makeConstraints];
}

- (void)makeConstraints {
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).mas_offset(12);
        make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
    }];
    
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).mas_offset(34);
        make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-12);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_top).offset(14);
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-14);
    }];
}

#pragma mark setters and getters

- (void)setModel:(OSSVMessageModel *)model {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        [_titleLabel setTextAlignment:NSTextAlignmentRight];
    } else {
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
    }
    
    [self.timeLabel setText:STLToString(model.date)];
    [self.titleLabel setText:STLToString(model.title)];
}

- (UILabel *)timeLabel
{
    if (!_timeLabel)
    {
        _timeLabel = [UILabel new];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [OSSVThemesColors col_B2B2B2];
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
        _bgView.backgroundColor = [UIColor whiteColor];
        
        if (APP_TYPE == 3) {
        } else {
            _bgView.layer.cornerRadius = 6;
            _bgView.layer.masksToBounds = YES;
        }
    }
    return _bgView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        }
        _titleLabel.numberOfLines = 0;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}


@end
