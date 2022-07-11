//
//  OSSVMessageNotifyCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageNotifyCell.h"

@interface OSSVMessageNotifyCell()

@property (nonatomic, strong) UILabel   *timeLabel;
@property (nonatomic, strong) UIView    *bgView;
@property (nonatomic, strong) UILabel   *titleLabel;
@property (nonatomic, strong) UILabel   *detailLabel;
//@property (nonatomic, strong) UIView    *circleView;
@property (nonatomic, strong) YYAnimatedImageView *notifImgaeView;  //图片展示
@end

@implementation OSSVMessageNotifyCell

#pragma mark life cycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [OSSVThemesColors col_F5F5F5];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setUpSubviews];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


#pragma mark private methods


- (void)setUpSubviews
{
//    [self.contentView addSubview:self.circleView];
    [self.contentView addSubview:self.bgView];
    [self.contentView addSubview:self.timeLabel];
    [self.bgView addSubview:self.notifImgaeView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.detailLabel];
    [self makeConstraints];
}

- (void)makeConstraints
{
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
    
    [self.notifImgaeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
        make.top.mas_equalTo(self.bgView.mas_top).offset(14);
        make.height.mas_equalTo(109*kScale_375);
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.notifImgaeView.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
    }];
    
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-14);
    }];
}

#pragma mark setters and getters

- (void)setModel:(OSSVMessageModel *)model {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        [_titleLabel setTextAlignment:NSTextAlignmentRight];
        [_detailLabel setTextAlignment:NSTextAlignmentRight];
    } else {
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_detailLabel setTextAlignment:NSTextAlignmentLeft];
    }
    [self.timeLabel setText:model.date?:@""];
    [self.detailLabel setText:model.content?:@""];
    if ([model.type intValue] == 5) {
        //类型为5的时候，可能存在富文本，需要解析字符串
        if (model.content.length) {
            NSString *detailString = [model.content stringByRemovingPercentEncoding];
//            NSLog(@"解码后的字符串：%@", detailString);
            NSString *newDetailStr = [detailString stringByReplacingOccurrencesOfString:@"+" withString:@" "];  //空格替换+
            [self.detailLabel setText:newDetailStr];
        } else {
            [self.detailLabel setText:@""];
        }
        if (model.title.length) {
            NSString *titleString = [model.title stringByRemovingPercentEncoding];
            NSString *newTitleStr = [titleString stringByReplacingOccurrencesOfString:@"+" withString:@" "];  //空格替换+
            [self.titleLabel setText:newTitleStr];
        } else {
            [self.titleLabel setText:@""];
        }
    } else {
        [self.detailLabel setText:model.content?:@""];
        [self.titleLabel setText:model.title?:@""];

    }

    if (model.img_url.length) {
        self.notifImgaeView.hidden = NO;
        [self.notifImgaeView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgView.mas_top).offset(14);
            make.height.mas_equalTo(109*kScale_375);
        }];
        [self.notifImgaeView yy_setImageWithURL:[NSURL URLWithString:STLToString(model.img_url)]
                                    placeholder:[UIImage imageNamed:@"placeholder_banner_pdf"]
                                        options:YYWebImageOptionShowNetworkActivity completion
                                               :nil];
    } else {
        self.notifImgaeView.hidden = YES;
        [self.notifImgaeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgView.mas_top).offset(6);
            make.height.mas_equalTo(0);
        }];
    }
}

- (UILabel *)timeLabel
{
    if (!_timeLabel)
    {
        _timeLabel = [UILabel new];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = OSSVThemesColors.col_B2B2B2;
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
- (YYAnimatedImageView *)notifImgaeView {
    if (!_notifImgaeView) {
        _notifImgaeView = [YYAnimatedImageView new];
        _notifImgaeView.hidden = YES;
//        _notifImgaeView.contentMode = UIViewContentModeScaleAspectFit;
        _notifImgaeView.backgroundColor = [UIColor clearColor];
    }
    return _notifImgaeView;
}
- (UILabel *)titleLabel
{
    if (!_titleLabel)
    {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 1;
        [_titleLabel sizeToFit];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel)
    {
        _detailLabel = [UILabel new];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _detailLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _detailLabel.numberOfLines = 5;
        [_detailLabel sizeToFit];
    }
    return _detailLabel;
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
