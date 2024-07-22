//
//  ZFPaySuccessPointCell.m
//  ZZZZZ
//
//  Created by YW on 7/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPaySuccessPointCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFPaySuccessModel.h"
#import "ZFThemeManager.h"
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYAnimatedImageView.h>
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "NSStringUtils.h"

@interface ZFPaySuccessPointCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *stateLabel;
@property (nonatomic, strong) UILabel               *tipLabel;
@property (nonatomic, strong) YYAnimatedImageView   *icon;
@property (nonatomic, strong) CAGradientLayer       *menuGradientLayer;
@end

@implementation ZFPaySuccessPointCell
+ (instancetype)pointCellWith:(UITableView *)tableView {
    [tableView registerClass:[self class] forCellReuseIdentifier:NSStringFromClass([self class])];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([self class])];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR(255, 158, 53, 1);
    self.selectionStyle = UITableViewCellSeparatorStyleNone;

    CAGradientLayer *menuGradientLayer = [[CAGradientLayer alloc] init];
    menuGradientLayer.colors = @[(__bridge id)ZFCOLOR(252.0, 191.0, 55.0, 1.0).CGColor,(__bridge id)ZFCOLOR(255.0, 158.0, 53.0, 1.0).CGColor];
    menuGradientLayer.frame = CGRectMake(0, 0, KScreenWidth, 130);
    menuGradientLayer.startPoint = CGPointMake(0, 0);
    menuGradientLayer.endPoint   = CGPointMake(0, 1);
    self.menuGradientLayer = menuGradientLayer;
    
    [self.contentView.layer addSublayer:self.menuGradientLayer];
    
    [self.contentView addSubview:self.stateLabel];
    [self.contentView addSubview:self.tipLabel];
    [self.contentView addSubview:self.icon];
}

- (void)zfAutoLayoutView {
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(16);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.height.priorityLow();
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.stateLabel.mas_leading);
        make.trailing.equalTo(self.icon.mas_leading).offset(-12);
        make.top.equalTo(self.stateLabel.mas_bottom).offset(12);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-8).priorityLow();
    }];
    
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(98, 92));
        make.trailing.mas_equalTo(-12);
        make.centerY.mas_equalTo(self);
    }];
     
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_greaterThanOrEqualTo(130);
        make.top.bottom.mas_equalTo(self);
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self);
    }];
}

#pragma mark - Setter
- (void)setModel:(ZFPaySuccessModel *)model {
    _model = model;

    if (_model.order_status == 6) {
        //付款中，显示新文案
        NSString *stateString = ZFLocalizedString(@"paySuccessPendingTipsTitle", nil);
        self.stateLabel.text = stateString;
        NSString *tipsString = ZFLocalizedString(@"paySuccessPendingTipsContent", nil);
        self.tipLabel.text = tipsString;
    } else if (_model.isCodPay) {
        //COD 支付，显示新文案
        [self.stateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(16);
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.icon.mas_leading).offset(-12);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-16);
        }];
        NSString *stateString = ZFLocalizedString(@"paySuccessPendingTipsTitle", nil);
        self.stateLabel.text = stateString;
//        NSString *tipsString = ZFLocalizedString(@"paySuccessPendingTipsCodTitle", nil);
        self.tipLabel.text = nil;
    } else {
        if ([model.is_use_point boolValue]) {
            self.tipLabel.text = ZFLocalizedString(@"paySuccess_usePoint", nil);
        } else {
            self.tipLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"paySuccess_Point", nil), ZFToString(model.points)];
        }
    }
    
    //如果是线下支付
    if (!ZFIsEmptyString(_model.offlineLink)) {
        if ([_model.offlineLink containsString:@"oxxo"]) {
            // oxxo 文案
            self.stateLabel.text = @"¡Muchas gracias por comprar con nosotros!";
            self.tipLabel.text = @"El estado de su pedido cambiará a \"procesamiento\" dentro de 1-2 días hábiles después de que verifiquemos su pago. Algunos pedidos pueden requerir un tiempo adicional para verificar. Por favor tenga paciencia con nosotros.";
        } else {
            // boleto
            self.stateLabel.text = @"Obrigado por comprar conosco!";
            self.tipLabel.text = @"Observe:Depois de verificar o seu pagamento ,o status do pedido será alterado para \"processamento\" dentro de 1-2 dias úteis. Algumas ordens podem necessitar de tempo adicional para verificar. Tenha-nos e ser paciente.";
        }
    }

}

-(void)layoutSubviews
{
    if (self.contentView.frame.size.height <= 130) {
        [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(130);
        }];
        self.menuGradientLayer.frame = CGRectMake(0, 0, self.menuGradientLayer.frame.size.width, 130);
    }else{
        self.menuGradientLayer.frame = CGRectMake(0, 0, self.menuGradientLayer.frame.size.width, self.contentView.frame.size.height);
    }
}

#pragma mark - Getter
- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.font = ZFFontSystemSize(14);
        _stateLabel.textColor = ZFCOLOR_WHITE;
        _stateLabel.text = ZFLocalizedString(@"Payment_Success", nil);
        _stateLabel.numberOfLines = 0;
        _stateLabel.preferredMaxLayoutWidth = KScreenWidth - 134;
        NSString *stateString = ZFLocalizedString(@"paySuccessPendingTipsTitle", nil);
        _stateLabel.text = stateString;
    }
    return _stateLabel;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = ZFFontSystemSize(10);
        _tipLabel.numberOfLines = 0;
        _tipLabel.preferredMaxLayoutWidth = KScreenWidth - 134;
        _tipLabel.textColor = ZFCOLOR_WHITE;
        NSString *tipsString = ZFLocalizedString(@"paySuccessPendingTipsContent", nil);
        _tipLabel.text = tipsString;
    }
    return _tipLabel;
}

- (YYAnimatedImageView *)icon {
    if (!_icon) {
        _icon = [[YYAnimatedImageView alloc] init];
        _icon.image = ZFImageWithName(@"paySuccess");
    }
    return _icon;
}

@end
