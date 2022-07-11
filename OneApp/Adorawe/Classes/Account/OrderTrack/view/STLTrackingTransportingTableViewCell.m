//
//  OSSVTrackingcTransporticTableVCell.m
// XStarlinkProject
//
//  Created by Kevin on 2020/11/13.
//  Copyright © 2020 starlink. All rights reserved.
//  -----运输中轨迹-----------

#import "OSSVTrackingcTransporticTableVCell.h"
#import "OSSVTransporteTrackeMode.h"
@interface OSSVTrackingcTransporticTableVCell ()
@property (nonatomic, strong) YYAnimatedImageView *addressMapImgView;  //小地图图片
@property (nonatomic, strong) UILabel             *titleLabel;         //主标题
@property (nonatomic, strong) UILabel             *subTitleLabel;      //描述
@property (nonatomic, strong) UIView              *pointView;
@property (nonatomic, strong) UILabel             *dateLabel;          //日期
@property (nonatomic, strong) UILabel             *timeLabel;          //时间
@property (nonatomic, strong) UIView              *lineView;
@end

@implementation OSSVTrackingcTransporticTableVCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = STLThemeColor.col_FFFFFF;
        [self.contentView addSubview:self.addressMapImgView];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.subTitleLabel];
        [self.contentView addSubview:self.pointView];
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}
- (void)setModel:(OSSVTransporteTrackeMode *)model {
    _model = model;
    self.titleLabel.text = STLToString(model.desc);
    self.subTitleLabel.text = STLToString(model.detail);
//    self.timeLabel.text  = STLToString(model.date);
    NSString *dateStr = STLToString(model.date);
    if (dateStr.length) {
        NSString *str1 = [dateStr substringWithRange:NSMakeRange(5, 5)];
        NSString *str2 = [dateStr substringWithRange:NSMakeRange(11, 5)];
        NSLog(@"日期：%@", str1);
        NSLog(@"时间：%@", str2);
        self.dateLabel.text = str1;
        self.timeLabel.text = str2;
    }

}

- (YYAnimatedImageView *)addressMapImgView{
    if (!_addressMapImgView) {
        _addressMapImgView = [YYAnimatedImageView new];
        _addressMapImgView.image = [UIImage imageNamed:@"adress_gray"];
    }
    return _addressMapImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = STLThemeColor.col_999999;
        _titleLabel.font = [UIFont systemFontOfSize:13];
//        _titleLabel.text = @"Description1";
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel {
    if (!_subTitleLabel) {
        _subTitleLabel = [UILabel  new];
        _subTitleLabel.textColor = STLThemeColor.col_999999;
        _subTitleLabel.font = [UIFont systemFontOfSize:13];
        _subTitleLabel.numberOfLines = 0;
//        _subTitleLabel.text = @"Location1:Madinah Monwarah Outlet,Saudi Arabia,Madinah Monwarah Outlet,Saudi Arabia";
    }
    return _subTitleLabel;
}

- (UIView*)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = STLThemeColor.col_CCCCCC;
    }
    return _lineView;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.textColor = STLThemeColor.col_999999;
        _dateLabel.font = [UIFont systemFontOfSize:13];
    }
    return _dateLabel;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.textColor = STLThemeColor.col_999999;
        _timeLabel.font = [UIFont systemFontOfSize:11];
    }
    return _timeLabel;
}

- (UIView *)pointView {
    if (!_pointView) {
        _pointView = [UIView new];
        _pointView.backgroundColor = STLThemeColor.col_CCCCCC;
        _pointView.layer.cornerRadius = 4.f;
        _pointView.layer.masksToBounds = YES;
    }
    return _pointView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.pointView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(58);
        make.width.height.equalTo(8);
        make.top.mas_equalTo(self.contentView.mas_top).offset(2);
    }];
    

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.pointView.mas_trailing).offset(16);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.height.equalTo(13);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.addressMapImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.titleLabel.mas_leading);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(5);
        make.height.width.equalTo(12);
    }];
    [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.addressMapImgView.mas_trailing).offset(1);
        make.top.mas_equalTo(self.addressMapImgView.mas_top).offset(-2);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
    }];
    
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(10);
        make.top.mas_equalTo(self.pointView.mas_top);
        make.trailing.mas_equalTo(self.pointView.mas_leading).offset(-9);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.dateLabel.mas_leading).offset(4);
        make.top.mas_equalTo(self.dateLabel.mas_bottom);
        make.trailing.mas_equalTo(self.dateLabel.mas_trailing);
    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.pointView.mas_bottom);
        make.width.mas_equalTo(1);
        make.centerX.mas_equalTo(self.pointView.mas_centerX);
        make.height.equalTo(77);
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
