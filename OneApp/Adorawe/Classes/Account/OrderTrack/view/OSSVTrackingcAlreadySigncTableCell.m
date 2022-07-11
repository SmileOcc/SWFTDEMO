//
//  OSSVTrackingcAlreadySigncTableCell.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
//-------------已签收cell-------------

#import "OSSVTrackingcAlreadySigncTableCell.h"

@interface OSSVTrackingcAlreadySigncTableCell ()
@property (nonatomic, strong) UIView              *signBgView;         //已签收背景
@property (nonatomic, strong) YYAnimatedImageView *signImgView;        //已签收图片
@property (nonatomic, strong) UILabel             *titleLabel;         //主标题
@property (nonatomic, strong) UILabel             *subTitleLabel;      //描述
@property (nonatomic, strong) UIView              *lineView;
@property (nonatomic, strong) UILabel             *dateLabel;          //日期
@property (nonatomic, strong) UILabel             *timeLabel;          //时间
@end
@implementation OSSVTrackingcAlreadySigncTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = OSSVThemesColors.col_FFFFFF;
        [self.contentView addSubview:self.signBgView];
        [self.signBgView addSubview:self.signImgView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.subTitleLabel];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}
- (void)setModel:(OSSVTrackingcTotalInformcnModel *)model {
    _model = model;
    ///如果是已签收 （已签收和拒签对象唯独只有一个存在）
    if (model.alreadySign) {
        self.signImgView.image = [UIImage imageNamed:@"alreadySign"];
        self.titleLabel.text = STLToString(model.alreadySign.logistics_status);
        self.subTitleLabel.text = STLToString(model.alreadySign.desc);
        NSString *dateStr = STLToString(model.alreadySign.date);
        if (dateStr.length) {
            NSString *str1 = [dateStr substringWithRange:NSMakeRange(5, 5)];
            NSString *str2 = [dateStr substringWithRange:NSMakeRange(11, 5)];
            NSLog(@"日期：%@", str1);
            NSLog(@"时间：%@", str2);
            self.dateLabel.text = str1;
            self.timeLabel.text = str2;
        }
    } else {
        self.signImgView.image = [UIImage imageNamed:@"refuseSign_icon"];
        self.titleLabel.text = STLToString(model.refuseSign.status);
        self.subTitleLabel.text = STLToString(model.refuseSign.desc);
        NSString *dateStr = STLToString(model.refuseSign.date);
        if (dateStr.length) {
            NSString *str1 = [dateStr substringWithRange:NSMakeRange(5, 5)];
            NSString *str2 = [dateStr substringWithRange:NSMakeRange(11, 5)];
            NSLog(@"日期：%@", str1);
            NSLog(@"时间：%@", str2);
            self.dateLabel.text = str1;
            self.timeLabel.text = str2;
        }
    }

}

- (UIView *)signBgView {
    if (!_signBgView) {
        _signBgView = [UIView new];
        _signBgView.backgroundColor = OSSVThemesColors.col_0D0D0D;
        _signBgView.layer.cornerRadius = 12;
        _signBgView.layer.borderColor = OSSVThemesColors.col_0D0D0D.CGColor;
        _signBgView.layer.borderWidth = 1.f;
        _signBgView.layer.masksToBounds = YES;
    }
    return _signBgView;
}

- (YYAnimatedImageView *)signImgView {
    if (!_signImgView) {
        _signImgView = [YYAnimatedImageView new];
    }
    return _signImgView;
}

- (UIView*)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = OSSVThemesColors.col_CCCCCC;
    }
    return _lineView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = OSSVThemesColors.col_999999;
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
//        _titleLabel.text = @"Delivered";
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel  new];
        _subTitleLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _subTitleLabel.font = [UIFont systemFontOfSize:13];
//        _subTitleLabel.text = @"Your order has been Delivered";
    }
    return _subTitleLabel;
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
    [self.signBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(50);
        make.width.height.equalTo(24);
        make.top.mas_equalTo(self.contentView.mas_top).offset(2);
    }];
    
    [self.signImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.signBgView.mas_leading).offset(4);
        make.height.width.equalTo(16);
        make.top.mas_equalTo(self.signBgView.mas_top).offset(4);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.signBgView.mas_trailing).offset(8);
        make.top.mas_equalTo(self.signBgView.mas_top).offset(5);
        make.height.equalTo(15);
    }];
    
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(4);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(12);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(10);
        make.top.mas_equalTo(self.signBgView.mas_top);
        make.trailing.mas_equalTo(self.signBgView.mas_leading).offset(-1);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.dateLabel.mas_leading).offset(4);
        make.top.mas_equalTo(self.dateLabel.mas_bottom);
        make.trailing.mas_equalTo(self.dateLabel.mas_trailing);
    }];

    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.signBgView.mas_bottom);
        make.width.mas_equalTo(1);
        make.centerX.mas_equalTo(self.signBgView.mas_centerX);
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
