//
//  OSSVTrackingeAlreadySendcTableCell.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
// -------------已发货-----------------

#import "OSSVTrackingeAlreadySendcTableCell.h"

@interface OSSVTrackingeAlreadySendcTableCell ()
@property (nonatomic, strong) UIView              *shipBgView;         //已发货背景
@property (nonatomic, strong) YYAnimatedImageView *shipImgView;        //已发货图片
@property (nonatomic, strong) UILabel             *titleLabel;         //主标题
@property (nonatomic, strong) UILabel             *subTitleLabel;      //描述
@property (nonatomic, strong) UILabel             *dateLabel;          //日期
@property (nonatomic, strong) UILabel             *timeLabel;          //时间
@property (nonatomic, strong) UIView              *lineView;
@end


@implementation OSSVTrackingeAlreadySendcTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = OSSVThemesColors.col_FFFFFF;
        [self.contentView addSubview:self.shipBgView];
        [self.shipBgView addSubview:self.shipImgView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.subTitleLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

- (void)setModel:(OSSVTrackingcTotalInformcnModel *)model {
    _model = model;
    self.titleLabel.text    = STLToString(model.alreadyShip.logistics_status);
    self.subTitleLabel.text = STLToString(model.alreadyShip.desc);
    NSString *dateStr = STLToString(model.alreadyShip.date);
    if (dateStr.length) {
        NSString *str1 = [dateStr substringWithRange:NSMakeRange(5, 5)];
        NSString *str2 = [dateStr substringWithRange:NSMakeRange(11, 5)];
        NSLog(@"日期：%@", str1);
        NSLog(@"时间：%@", str2);
        self.dateLabel.text = str1;
        self.timeLabel.text = str2;
    }

    if (model.alreadySign) {
        self.shipBgView.backgroundColor = OSSVThemesColors.col_F5F5F5;
        self.shipImgView.image = [UIImage imageNamed:@"alreadyShip_gray"];
        self.shipBgView.layer.borderColor = OSSVThemesColors.col_CCCCCC.CGColor;
        self.titleLabel.textColor = OSSVThemesColors.col_999999;
        self.subTitleLabel.textColor = OSSVThemesColors.col_999999;
        self.timeLabel.textColor = OSSVThemesColors.col_999999;
        self.dateLabel.textColor = OSSVThemesColors.col_999999;

        return;
    }
    if (model.transport) {
        self.shipBgView.backgroundColor = OSSVThemesColors.col_F5F5F5;
        self.shipImgView.image = [UIImage imageNamed:@"alreadyShip_gray"];
        self.shipBgView.layer.borderColor = OSSVThemesColors.col_CCCCCC.CGColor;
        self.titleLabel.textColor = OSSVThemesColors.col_999999;
        self.subTitleLabel.textColor = OSSVThemesColors.col_999999;
        self.timeLabel.textColor = OSSVThemesColors.col_999999;
        self.dateLabel.textColor = OSSVThemesColors.col_999999;

        return;
    }
}
- (UIView *)shipBgView {
    if (!_shipBgView) {
        _shipBgView = [UIView new];
        _shipBgView.backgroundColor = OSSVThemesColors.col_0D0D0D;
        _shipBgView.layer.cornerRadius = 12;
        _shipBgView.layer.borderColor = OSSVThemesColors.col_0D0D0D.CGColor;
        _shipBgView.layer.borderWidth = 1.f;
        _shipBgView.layer.masksToBounds = YES;
    }
    return _shipBgView;
}

- (YYAnimatedImageView *)shipImgView {
    if (!_shipImgView) {
        _shipImgView = [YYAnimatedImageView new];
        _shipImgView.image = [UIImage imageNamed:@"alreadyShip_white"];
    }
    return _shipImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
//        _titleLabel.text = @"Shipped";
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel  new];
        _subTitleLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _subTitleLabel.font = [UIFont systemFontOfSize:13];
//        _subTitleLabel.text = @"Your package has been sent";
    }
    return _subTitleLabel;
}

- (UIView*)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = OSSVThemesColors.col_CCCCCC;
    }
    return _lineView;
}


- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _dateLabel.font = [UIFont systemFontOfSize:13];
    }
    return _dateLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _timeLabel.font = [UIFont systemFontOfSize:1];
    }
    return _timeLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.shipBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(50);
        make.width.height.equalTo(24);
        make.top.mas_equalTo(self.contentView.mas_top).offset(2);
    }];
    
    [self.shipImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.shipBgView.mas_leading).offset(4);
        make.height.width.equalTo(16);
        make.top.mas_equalTo(self.shipBgView.mas_top).offset(4);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.shipBgView.mas_trailing).offset(8);
        make.top.mas_equalTo(self.shipBgView.mas_top).offset(5);
        make.height.equalTo(15);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(10);
        make.top.mas_equalTo(self.shipBgView.mas_top);
        make.trailing.mas_equalTo(self.shipBgView.mas_leading).offset(-1);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.dateLabel.mas_leading).offset(4);
        make.top.mas_equalTo(self.dateLabel.mas_bottom);
        make.trailing.mas_equalTo(self.dateLabel.mas_trailing);
    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shipBgView.mas_bottom);
        make.width.mas_equalTo(1);
        make.centerX.mas_equalTo(self.shipBgView.mas_centerX);
        make.height.equalTo(61);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
