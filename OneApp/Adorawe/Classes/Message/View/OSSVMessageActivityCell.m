//
//  OSSVMessageActivityCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageActivityCell.h"

@interface OSSVMessageActivityCell()

@property (nonatomic, strong) UILabel               *timeLabel;
@property (nonatomic, strong) UIView                *bgView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) YYAnimatedImageView   *activityImgview;
@property (nonatomic, strong) UIView                *coverView;
@property (nonatomic, strong) UILabel               *detailLabel;
@property (nonatomic, strong) UILabel               *viewDetailLabel;
@property (nonatomic, strong) UILabel               *activityStatusLabel;

@end


@implementation OSSVMessageActivityCell


#pragma mark lift cycle

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
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.activityImgview];
    [self.bgView addSubview:self.coverView];
    [self.bgView addSubview:self.detailLabel];
    [self.bgView addSubview:self.viewDetailLabel];
    [self.coverView addSubview:self.activityStatusLabel];
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
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView.mas_top).mas_offset(14);
        make.leading.mas_equalTo(self.bgView.mas_leading).mas_offset(14);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).mas_offset(-14);
    }];
    
    [_activityImgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(8);
        make.leading.mas_equalTo(self.bgView.mas_leading).mas_offset(14);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).mas_offset(-14);
        make.height.mas_equalTo(self.activityImgview.mas_width).multipliedBy(100.0 / 323.0);
    }];
    
    [_coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.activityImgview);
        make.height.mas_equalTo(28);
    }];
    
    [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.activityImgview.mas_bottom).mas_offset(8);
        make.leading.mas_equalTo(self.bgView.mas_leading).mas_offset(14);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).mas_offset(-14);
    }];
    
    
    [_viewDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detailLabel.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.bgView.mas_leading).mas_offset(14);
        make.trailing.mas_equalTo(self.bgView.mas_trailing).mas_offset(-14);
        make.bottom.mas_equalTo(self.bgView.mas_bottom).mas_offset(-14);
        make.height.mas_equalTo(36);
    }];

    
   
    [_activityStatusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.coverView.mas_centerY);
        make.leading.mas_equalTo(self.coverView.mas_leading);
        make.trailing.mas_equalTo(self.coverView.mas_trailing);
    }];
}


#pragma mark setters and getters

- (void)setModel:(OSSVMessageModel *)model
{
    _model = model;
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow])
    {
//        _rightArrowImgview.transform = CGAffineTransformMakeRotation(M_PI);
        [_titleLabel setTextAlignment:NSTextAlignmentRight];
        [_detailLabel setTextAlignment:NSTextAlignmentRight];
    }
    else
    {
        [_titleLabel setTextAlignment:NSTextAlignmentLeft];
        [_detailLabel setTextAlignment:NSTextAlignmentLeft];
    }
    if (_model.status.integerValue == 1)
    {
        _coverView.hidden = YES;
    }
    else
    {
        if (_model.status.integerValue == 0)
        {
            _activityStatusLabel.text = STLLocalizedString_(@"messagePromotionUnstart",nil);
        }
        else
        {
            _activityStatusLabel.text = STLLocalizedString_(@"messagePromotionEnd",nil);
        }
        _coverView.hidden = NO;
    }
    [self.timeLabel setText:_model.date];
    [self.titleLabel setText:model.title];
    [self.detailLabel setText:model.content];
    
    [self.viewDetailLabel setText:APP_TYPE == 3 ? STLLocalizedString_(@"messageViewDetail",nil) : STLLocalizedString_(@"messageViewDetail",nil).uppercaseString];
    
    [self.activityImgview yy_setImageWithURL:[NSURL URLWithString:_model.img_url]
                                 placeholder:[UIImage imageNamed:@"placeholder_pdf"]
                                     options:YYWebImageOptionShowNetworkActivity
                                    progress:nil
                                   transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                       return image;
                                   }
                                  completion:nil];
    
    //活动未开始，不可以进去
    self.viewDetailLabel.hidden = YES;
    if (_model.status.integerValue == 1) {
        self.viewDetailLabel.hidden = NO;
        [self.viewDetailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.detailLabel.mas_bottom).offset(8);
            make.height.mas_equalTo(36);
        }];
    } else {
        [self.viewDetailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.detailLabel.mas_bottom).offset(0);
            make.height.mas_equalTo(0);
        }];
    }
    
}


- (UILabel *)timeLabel
{
    if (!_timeLabel)
    {
        _timeLabel = [[UILabel alloc]init];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [OSSVThemesColors col_B2B2B2];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}

- (UIView *)bgView
{
    if (!_bgView)
    {
        _bgView = [[UIView alloc]init];
        _bgView.backgroundColor = [UIColor whiteColor];
        if (APP_TYPE == 3) {
            
        } else {
            _bgView.layer.cornerRadius = 6;
            _bgView.layer.masksToBounds = true;
        }
    }
    return _bgView;
}

- (UIView *)coverView {
    if (!_coverView)
    {
        _coverView = [[UIView alloc]init];
        _coverView.backgroundColor = [OSSVThemesColors col_0D0D0D:0.8];
    }
    return _coverView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _titleLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (YYAnimatedImageView *)activityImgview {
    if (!_activityImgview) {
        _activityImgview = [[YYAnimatedImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 26 * 2, (SCREEN_WIDTH - 26 * 2) * 100.0 / 323.0)];
        _activityImgview.userInteractionEnabled = YES;
        _activityImgview.contentMode = UIViewContentModeScaleAspectFill;
        _activityImgview.clipsToBounds = YES;
        if (APP_TYPE == 3) {
            
        } else {
            [_activityImgview stlAddCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(6, 6)];
        }
    }
    return _activityImgview;
}

- (UILabel *)detailLabel
{
    if (!_detailLabel)
    {
        _detailLabel = [UILabel new];
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _detailLabel.numberOfLines = 5;
        
        
//        CGSize fontSize = [_detailLabel.text sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:_detailLabel.font.fontName size:_detailLabel.font.pointSize]}];
//        double finalHeight = fontSize.height * _detailLabel.numberOfLines;
//        double finalWidth = _detailLabel.frame.size.width;
//        CGRect rect =  [_detailLabel.text boundingRectWithSize:CGSizeMake(finalWidth, finalHeight) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: _detailLabel.font} context:nil];
//        int newLinesToPad = (finalHeight  - rect.size.height) / fontSize.height;
//        for(int i=0; i<newLinesToPad; i++)
//        {
//            _detailLabel.text = [_detailLabel.text stringByAppendingString:@"\n "];
//        }
        
        _detailLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;

    }
    return _detailLabel;
}


- (UILabel *)viewDetailLabel
{
    if (!_viewDetailLabel)
    {
        _viewDetailLabel = [[UILabel alloc]init];
        _viewDetailLabel.font = [UIFont stl_buttonFont:12];
        _viewDetailLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _viewDetailLabel.textAlignment = NSTextAlignmentCenter;
        _viewDetailLabel.numberOfLines = 1;
        if (APP_TYPE == 3) {
            _viewDetailLabel.layer.borderColor = [OSSVThemesColors stlBlackColor].CGColor;
            _viewDetailLabel.layer.borderWidth = 2;
        } else {
            _viewDetailLabel.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
            _viewDetailLabel.layer.borderWidth = 1;
        }
    }
    return _viewDetailLabel;
}


- (UILabel *)activityStatusLabel
{
    if (!_activityStatusLabel)
    {
        _activityStatusLabel = [[UILabel alloc]init];
        _activityStatusLabel.font = [UIFont systemFontOfSize:14];
        _activityStatusLabel.textColor = OSSVThemesColors.col_FFFFFF;
        _activityStatusLabel.textAlignment = NSTextAlignmentCenter;
        _activityStatusLabel.numberOfLines = 1;
        [_activityStatusLabel sizeToFit];
    }
    return _activityStatusLabel;
}

@end
