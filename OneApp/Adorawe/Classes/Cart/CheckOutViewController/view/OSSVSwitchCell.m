//
//  OSSVSwitchCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSwitchCell.h"
#import "BigClickAreaButton.h"
#import "ExchangeManager.h"
#import "OSSVPriceView.h"

@interface OSSVSwitchCell ()
@property (nonatomic, strong) UISwitch             *switchButton;
@property (nonatomic, strong) UILabel              *titleLabel;
@property (nonatomic, strong) OSSVPriceView          *priceView;
@property (nonatomic, strong) BigClickAreaButton   *explainButton;
@property (nonatomic, strong) UIImageView          *safeIcon;
@end

@implementation OSSVSwitchCell
@synthesize delegate = _delegate;
@synthesize model = _model;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIView *contentView = self.contentView;
   
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self).priorityHigh();
        }];
        
        [contentView addSubview:self.titleLabel];
        [contentView addSubview:self.priceView];
        [contentView addSubview:self.switchButton];
        [contentView addSubview:self.explainButton];
        [contentView addSubview:self.safeIcon];
        
        [self.safeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(contentView.mas_leading).offset(14);
            make.centerY.mas_equalTo(contentView.mas_centerY);
            make.height.width.mas_equalTo(12);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.safeIcon.mas_trailing).offset(5);
            make.height.mas_offset(CheckOutCellNormalHeight).priorityHigh();
            make.centerY.mas_equalTo(contentView.mas_centerY);
        }];
        
        [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_trailing).mas_offset(5);
            make.centerY.mas_equalTo(contentView.mas_centerY);
            make.height.mas_offset(CheckOutCellNormalHeight).priorityHigh();
        }];
        
        [self.explainButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceView.mas_trailing).mas_offset(4);
            make.centerY.mas_equalTo(contentView);
            make.width.mas_offset(12);
            make.height.mas_offset(13);
        }];
        
        [self.switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(contentView).mas_offset(-CheckOutCellLeftPadding);
            make.centerY.mas_equalTo(contentView);
        }];
        
        [self addBottomLine:CellSeparatorStyle_LeftRightInset];
    }
    return self;
}

#pragma mark - target

-(void)switchAction:(UISwitch *)sender {
    OSSVSwitchCellModel *model = self.model;
    model.switchStatus = sender.on;
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_DidClickSwitch:)]) {
        [self.delegate STL_DidClickSwitch:self.model];
    }
}

-(void)explainButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(STL_DidClickQuestionMarkButton:)]) {
        [self.delegate STL_DidClickQuestionMarkButton:self.model];
    }
}

#pragma mark - setter and getter

-(void)setModel:(OSSVSwitchCellModel *)model {
    _model = model;

    if ([model.dataSourceModel isKindOfClass:[OSSVPointsModel class]]) {
        ///商品价格调整  后台功能暂时没有，还是APP换算
        OSSVPointsModel *point = (OSSVPointsModel *)model.dataSourceModel;
        point.points = point.points == nil ? @"0" : point.points;
        point.save = point.save == nil ? @"0" : point.save;
        NSString *showSave = [ExchangeManager changeRateModel:model.rateModel transforPrice:point.save priceType:PriceType_Point];
        NSString *savePrice = [NSString stringWithFormat:@"%@%@",model.rateModel.symbol, showSave];
        self.titleLabel.text = [NSString stringWithFormat:@"%@",point.points];
        [self.priceView updateFirstDesc:STLLocalizedString_(@"pointsSave", nil) secondPrice:savePrice];
        
    }else if ([model.dataSourceModel isKindOfClass:[OSSVCartCheckModel class]]){
        ///商品价格调整  后台功能暂时没有，还是APP换算
        OSSVCartCheckModel *checkModel = (OSSVCartCheckModel *)model.dataSourceModel;
        NSString *showInsurance = [ExchangeManager changeRateModel:model.rateModel transforPrice:checkModel.insurance priceType:PriceType_Insurance];
        
        NSString *shipInsuranceStr = [NSString stringWithFormat:@"%@:",STLLocalizedString_(@"shipInsurance", nil)];
//        NSString *insuranceStr = [NSString stringWithFormat:@"%@%@",model.rateModel.symbol, showInsurance];

        
        //V2.0.0 V站接入版本， 直接取shipping_insurance_converted_origin 这个字段， 不再计算汇率

        NSString *insuranceStr = STLToString(checkModel.fee_data.shipping_insurance_converted_origin);
        self.titleLabel.text = @"";
        [self.priceView updateFirstDesc:shipInsuranceStr secondPrice:insuranceStr];
    } else {
        self.titleLabel.text = model.titleContent;
        [self.priceView updateFirstDesc:@"" secondPrice:@""];
    }
    
    //当self.titleLabel.text 为空
    if ([OSSVNSStringTool isEmptyString:self.titleLabel.text]) {
        [self.priceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_trailing).mas_offset(0);
        }];
    } else {
        [self.priceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_trailing).mas_offset(5);
        }];
    }
    //赋值开关状态
    if ([model.dataSourceModel isKindOfClass:[OSSVCartCheckModel class]]) {
        OSSVCartCheckModel *checkModel = (OSSVCartCheckModel *)model.dataSourceModel;
        NSInteger switchStatu = STLToString(checkModel.shippingInsurance).integerValue;
        [self.switchButton setOn:switchStatu animated:YES];
    }
    
    switch (model.cellType) {
        case SwitchCellTypeNormal:{
            self.explainButton.hidden = YES;
        }
            break;
        case SwitchCellTypeExplain:{
            self.explainButton.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (UISwitch *)switchButton
{
    if (!_switchButton) {
        _switchButton = ({
            UISwitch *switchBtn = [[UISwitch alloc] init];
            [switchBtn setOnTintColor:[OSSVThemesColors col_262626]];
//            [switchBtn setThumbTintColor:OSSVThemesColors.col_C4C4C4];
            switchBtn.transform = CGAffineTransformMakeScale( 0.62, 0.62);//缩放
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                switchBtn.transform = CGAffineTransformMakeScale(-0.62, 0.62);
            }
            [switchBtn addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
            switchBtn;
        });
    }
    return _switchButton;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = @"";
            label.textColor = OSSVThemesColors.col_0D0D0D;
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _titleLabel;
}

- (OSSVPriceView *)priceView {
    if (!_priceView) {
        _priceView = [[OSSVPriceView alloc] initWithFrame:CGRectZero font:[UIFont systemFontOfSize:14] textColor:OSSVThemesColors.col_0D0D0D];
    }
    return _priceView;
}

-(BigClickAreaButton *)explainButton
{
    if (!_explainButton) {
        _explainButton = ({
            BigClickAreaButton *button = [[BigClickAreaButton alloc] init];
            button.clickAreaRadious = 10;
            [button setImage:[UIImage imageNamed:@"description"] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(explainButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _explainButton;
}

- (UIImageView *)safeIcon {
    if (!_safeIcon) {
        _safeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"security"]];
        
    }
    return _safeIcon;
}

@end
