//
//  ZFOrderPointsV457Cell.m
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderPointsV457Cell.h"
#import "PointModel.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "FilterManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "YSAlertView.h"
#import <Masonry/Masonry.h>
#import "UIView+ZFViewCategorySet.h"

@interface ZFOrderPointsV457Cell ()

//@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UILabel *pointLabel;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIButton *tipsButton;
@property (nonatomic, strong) UISwitch *pointSwitch;

@end

@implementation ZFOrderPointsV457Cell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
//        [self.contentView addSubview:self.iconImage];
        [self.contentView addSubview:self.pointLabel];
        [self.contentView addSubview:self.tipsLabel];
        [self.contentView addSubview:self.priceLabel];
        [self.contentView addSubview:self.tipsButton];
        [self.contentView addSubview:self.pointSwitch];
        
        UIView *contentView = self.contentView;
//        [self.iconImage mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(contentView.mas_leading).mas_offset(12);
//            make.size.mas_equalTo(CGSizeMake(24, 24));
//            make.centerY.mas_equalTo(contentView);
//        }];
        
        [self.pointLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(contentView.mas_leading).mas_offset(12);
            make.centerY.mas_equalTo(contentView);
        }];
        
        [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.pointLabel.mas_trailing).mas_offset(4);
            make.centerY.mas_equalTo(contentView);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.tipsLabel.mas_trailing).mas_offset(4);
            make.centerY.mas_equalTo(contentView);
        }];
        
        [self.tipsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceLabel.mas_trailing).mas_offset(4);
            make.size.mas_equalTo(CGSizeMake(18, 18));
            make.centerY.mas_equalTo(contentView);
        }];
        
        [self.pointSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(contentView.mas_trailing).mas_offset(-10);
            make.centerY.mas_equalTo(contentView);
        }];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    [self zfAddCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(8, 8)];
}

+ (NSString *)queryReuseIdentifier
{
    return NSStringFromClass(self.class);
}

- (void)pointSwitchAction:(UISwitch *)sender
{
    if (self.pointSwitchHandler) {
        self.pointSwitchHandler(sender.isOn);
    }
}

- (void)tipsButtonAction
{
    NSString *instructionPrice = [FilterManager adapterCodWithAmount:[NSString stringWithFormat:@"%.2f",[self.pointModel.use_point_max integerValue] * 0.02] andCod:self.isCod priceType:PriceType_Point];
    NSString *tips = [NSString stringWithFormat:ZFLocalizedString(@"CartOrderInfo_RewardsCell_Instruction",nil),self.pointModel.avail_point,self.pointModel.use_point_max,instructionPrice];
    NSString *message = ZFLocalizedString(@"SettingViewModel_Version_Latest_Alert_OK",nil);
    ShowAlertSingleBtnView(nil, tips, message);
}

#pragma mark - Property Method

- (void)setIsChoose:(BOOL)isChoose
{
    _isChoose = isChoose;
    
    [self.pointSwitch setOn:_isChoose animated:YES];
}

- (void)setPointModel:(PointModel *)pointModel
{
    _pointModel = pointModel;
    
    NSString *amount = [FilterManager adapterCodWithAmount:pointModel.point_money_max andCod:self.isCod priceType:PriceType_Point];
    self.pointLabel.text = pointModel.use_point_max;
    self.priceLabel.text = amount;
}

//- (UIImageView *)iconImage
//{
//    if (!_iconImage) {
//        _iconImage = ({
//            UIImageView *img = [[UIImageView alloc] init];
//            img.image = [UIImage imageNamed:@"Check_orderpoint"];
//            img;
//        });
//    }
//    return _iconImage;
//}

-(UILabel *)pointLabel
{
    if (!_pointLabel) {
        _pointLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.textColor = ZFC0x2D2D2D();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _pointLabel;
}

-(UILabel *)tipsLabel
{
    if (!_tipsLabel) {
        _tipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = ZFLocalizedString(@"OrderInfo_priceList_ZpointToSave", nil);
            label.textColor = ZFC0x999999();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _tipsLabel;
}

-(UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = @"";
            label.textColor = ZFC0x2D2D2D();
            label.font = [UIFont boldSystemFontOfSize:14];
            label;
        });
    }
    return _priceLabel;
}

- (UIButton *)tipsButton
{
    if (!_tipsButton) {
        _tipsButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"nationalID"] forState:UIControlStateSelected];
            button.userInteractionEnabled = YES;
            [button addTarget:self action:@selector(tipsButtonAction) forControlEvents:UIControlEventTouchUpInside];
            [button setEnlargeEdge:10];
            button;
        });
    }
    return _tipsButton;
}

- (UISwitch *)pointSwitch
{
    if (!_pointSwitch) {
        _pointSwitch = ({
            UISwitch *switchP = [[UISwitch alloc] init];
            switchP.on = NO;
            switchP.onTintColor = ZFC0xFE5269();
            [switchP addTarget:self action:@selector(pointSwitchAction:) forControlEvents:UIControlEventValueChanged];
            switchP.transform = CGAffineTransformMakeScale(0.8, 0.8);
            switchP;
        });
    }
    return _pointSwitch;
}

@end
