//
//  OSSVMessageCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageCell.h"

@interface OSSVMessageCell()

@property (nonatomic, strong) UIImageView   *iconView;
@property (nonatomic, strong) UILabel       *titleLab;
@property (nonatomic, strong) UILabel       *titleSubLab;
@property (nonatomic, strong) UIView        *lineView;
@property (nonatomic, strong) UIImageView   *rightArrowImgview;
@property (nonatomic, strong) UIImageView   *redDotImgview;

@end

@implementation OSSVMessageCell


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
    [self.contentView addSubview:self.redDotImgview];
    [self.contentView addSubview:self.titleLab];
    [self.contentView addSubview:self.titleSubLab];
    [self.contentView addSubview:self.lineView];
    [self.contentView addSubview:self.rightArrowImgview];

    [self makeConstraints];
}

- (void)makeConstraints
{
    [_iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(10);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(16);
        make.width.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
    }];
    
    [_redDotImgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(12);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(48);
        make.width.height.mas_equalTo(8);
    }];
    
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_iconView.mas_top).offset(0);
        make.leading.mas_equalTo(_iconView.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-40);
    }];
    
    [_titleSubLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_titleLab.mas_bottom).offset(0);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-10);
        make.leading.mas_equalTo(_iconView.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-40);
    }];
    
    [_lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(@(MIN_PIXEL));
    }];
    
    [_rightArrowImgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
    }];
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

- (UILabel *)titleLab
{
    if (!_titleLab)
    {
        _titleLab = [UILabel new];
        _titleLab.font = [UIFont boldSystemFontOfSize:15];
        _titleLab.textColor = OSSVThemesColors.col_333333;
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
        _titleSubLab.textColor = OSSVThemesColors.col_999999;
        [_titleSubLab sizeToFit];
    }
    return _titleSubLab;
}


- (UIImageView *)redDotImgview
{
    if (!_redDotImgview)
    {
        _redDotImgview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"unreadmessage"]];
    }
    return _redDotImgview;
}

- (UIView *)lineView
{
    if (!_lineView)
    {
        _lineView = [UIView new];
        _lineView.backgroundColor = OSSVThemesColors.col_EFEFEF;
    }
    return _lineView;
}

- (UIImageView *)rightArrowImgview
{
    if (!_rightArrowImgview)
    {
        _rightArrowImgview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right_gray"]];
        _rightArrowImgview.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _rightArrowImgview;
}

- (void)setModel:(OSSVMessageModel *)model
{
    if (!model) {
        self.titleSubLab.text = STLLocalizedString_(@"messageNoMsgTip",nil);
        return;
    }
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        _rightArrowImgview.transform = CGAffineTransformMakeRotation(M_PI);
    }
    _model = model;
    if ([model.count integerValue] > 0) {
        self.redDotImgview.hidden = NO;
    }
    else {
        self.redDotImgview.hidden = YES;
    }
    
    self.titleLab.text = model.title;
    
    NSString *placeImgName = @"onlineCustomService";
    if ([model.type isEqualToString:@"1"]) {
        placeImgName = @"notifications";
    } else if ([model.type isEqualToString:@"2"]) {
        placeImgName = @"logistics";
    } else if ([model.type isEqualToString:@"3"]) {
        placeImgName = @"promotional";
    } else if ([model.type isEqualToString:@"4"]) {
        placeImgName = @"System";
    }
    [self.iconView yy_setImageWithURL:[NSURL URLWithString:_model.img_url] placeholder:[UIImage imageNamed:placeImgName]];
    
    self.titleSubLab.text = model.content.length > 0?model.content:STLLocalizedString_(@"messageNoMsgTip",nil);
}

@end
