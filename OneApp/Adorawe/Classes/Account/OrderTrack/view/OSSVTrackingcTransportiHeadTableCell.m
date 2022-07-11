//
//  OSSVTrackingcTransportiHeadTableCell.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
// ----------运输中状态的cell---------

#import "OSSVTrackingcTransportiHeadTableCell.h"

@interface OSSVTrackingcTransportiHeadTableCell ()
@property (nonatomic, strong) UIView              *transportingBgView;         //运输中背景
@property (nonatomic, strong) YYAnimatedImageView *transportingImgView;        //运输中图片
@property (nonatomic, strong) UILabel             *titleLabel;         //主标题
@property (nonatomic, strong) UILabel             *subTitleLabel;      //描述
@property (nonatomic, strong) UIImageView         *addressMapImgView; //地址图标
@property (nonatomic, strong) UILabel             *addressLabel;
@property (nonatomic, strong) UILabel             *dateLabel;          //日期
@property (nonatomic, strong) UILabel             *timeLabel;          //时间
@property (nonatomic, strong) UIView              *lineView;

@end
@implementation OSSVTrackingcTransportiHeadTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = OSSVThemesColors.col_FFFFFF;
        [self.contentView addSubview:self.transportingBgView];
        [self.transportingBgView addSubview:self.transportingImgView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.subTitleLabel];
        [self.contentView addSubview:self.addressMapImgView];
        [self.contentView addSubview:self.addressLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}
- (void)setModel:(OSSVTrackingcTotalInformcnModel *)model {
    _model = model;
    self.titleLabel.text = STLToString(model.transport.logistics_status);
    self.subTitleLabel.text = STLToString(model.transport.desc);
    self.addressLabel.text = STLToString(model.transport.loc);
    NSString *dateStr = STLToString(model.transport.date);
    if (dateStr.length) {
        NSString *str1 = [dateStr substringWithRange:NSMakeRange(5, 5)];
        NSString *str2 = [dateStr substringWithRange:NSMakeRange(11, 5)];
        NSLog(@"日期：%@", str1);
        NSLog(@"时间：%@", str2);
        self.dateLabel.text = str1;
        self.timeLabel.text = str2;
    }

    if (model.alreadySign) {
        self.transportingBgView.backgroundColor = OSSVThemesColors.col_F5F5F5;
        self.transportingImgView.image = [UIImage imageNamed:@"transporting_gray"];
        self.transportingBgView.layer.borderColor = OSSVThemesColors.col_CCCCCC.CGColor;
        self.titleLabel.textColor = OSSVThemesColors.col_999999;
        self.subTitleLabel.textColor = OSSVThemesColors.col_999999;
        self.timeLabel.textColor = OSSVThemesColors.col_999999;
        self.dateLabel.textColor = OSSVThemesColors.col_999999;
        return;
    }

}

- (UIView *)transportingBgView {
    if (!_transportingBgView) {
        _transportingBgView = [UIView new];
        _transportingBgView.backgroundColor = OSSVThemesColors.col_0D0D0D;
        _transportingBgView.layer.cornerRadius = 12;
        _transportingBgView.layer.borderColor = OSSVThemesColors.col_0D0D0D.CGColor;
        _transportingBgView.layer.borderWidth = 1.f;
        _transportingBgView.layer.masksToBounds = YES;
    }
    return _transportingBgView;
}

- (YYAnimatedImageView *)transportingImgView{
    if (!_transportingImgView) {
        _transportingImgView = [YYAnimatedImageView new];
        _transportingImgView.image = [UIImage imageNamed:@"transporting_white"];
    }
    return _transportingImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
//        _titleLabel.text = @"In Transit";
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel  new];
        _subTitleLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _subTitleLabel.font = [UIFont systemFontOfSize:13];
//        _subTitleLabel.text = @"Delivered";
    }
    return _subTitleLabel;
}

- (UIImageView *)addressMapImgView {
    if (!_addressMapImgView) {
        _addressMapImgView = [UIImageView new];
        _addressMapImgView.image = [UIImage imageNamed:@"adress_black"];
    }
    return _addressMapImgView;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [UILabel  new];
        _addressLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _addressLabel.font = [UIFont systemFontOfSize:13];
        _addressLabel.numberOfLines = 0;
    }
    return _addressLabel;
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
        _timeLabel.font = [UIFont systemFontOfSize:11];
    }
    return _timeLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.transportingBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(50);
        make.width.height.equalTo(24);
        make.top.mas_equalTo(self.contentView.mas_top).offset(2);
    }];
    
    [self.transportingImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.transportingBgView.mas_leading).offset(4);
        make.height.width.equalTo(16);
        make.top.mas_equalTo(self.transportingBgView.mas_top).offset(4);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.transportingBgView.mas_trailing).offset(8);
        make.top.mas_equalTo(self.transportingBgView.mas_top).offset(5);
        make.height.equalTo(15);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.addressMapImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.subTitleLabel.mas_bottom).offset(5);
        make.height.width.equalTo(12);
    }];
    
    [self.addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.addressMapImgView.mas_trailing).offset(1);
        make.top.mas_equalTo(self.addressMapImgView.mas_top).offset((-2));
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        
    }];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(10);
        make.top.mas_equalTo(self.transportingBgView.mas_top);
        make.trailing.mas_equalTo(self.transportingBgView.mas_leading).offset(-1);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.dateLabel.mas_leading).offset(4);
        make.top.mas_equalTo(self.dateLabel.mas_bottom);
        make.trailing.mas_equalTo(self.dateLabel.mas_trailing);
    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.transportingBgView.mas_bottom);
        make.width.mas_equalTo(1);
        make.centerX.mas_equalTo(self.transportingBgView.mas_centerX);
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
