//
//  YXBaseStockListCell.m
//  YouXinZhengQuan
//
//  Created by ellison on 2018/11/19.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXBaseStockListCell.h"
#import <Masonry/Masonry.h>
#import "YXSecuID.h"
#import "UILabel+create.h"
#import "UIView+Line.h"
#import "YXSecu.h"
#import "uSmartOversea-Swift.h"
@interface YXBaseStockListCell ()

//@property (nonatomic, strong) UIView *lineView;

@end

@implementation YXBaseStockListCell
@dynamic model;

- (void)initialUI {
    [super initialUI];
    self.backgroundColor = QMUITheme.foregroundColor;
    
    self.qmui_selectedBackgroundColor = QMUITheme.backgroundColor;
    
//    [self.contentView addSubview:self.marketIconView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.symbolLabel];
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.rocLabel];
    [self.contentView addSubview:self.delayLabel];
    [self.contentView addSubview:self.lineView];
//
//    [self.marketIconView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.contentView).offset(4);
//        make.top.equalTo(self.contentView).offset(16);
//        make.height.mas_equalTo(11);
//    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(18);
        make.width.mas_equalTo(135);
        make.top.equalTo(self.contentView).offset(10);
        make.height.mas_equalTo(22);
    }];
    
    [self.symbolLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel).offset(0);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(4);
        make.height.mas_equalTo(15);
        //make.width.equalTo(self.nameLabel);
    }];
    
    [self.delayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.symbolLabel.mas_right).offset(4);
        make.height.mas_equalTo(12);
        make.centerY.equalTo(self.symbolLabel);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(1);
    }];
}

- (void)refreshUI {
    if ([self.model conformsToProtocol:@protocol(YXSecuProtocol)]) {
//        if (self.model.secuId.marketIcon) {
//            self.marketIconView.image = [UIImage imageNamed:self.model.secuId.marketIcon];
//
//            [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(self.contentView).offset(25);
//            }];
//        } else {
//
//            [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(self.contentView).offset(12);
//            }];
//        }
        self.nameLabel.text = self.model.name;
        if (self.model.symbol) {
            self.symbolLabel.text = [NSString stringWithFormat:@"%@.%@", self.model.symbol, self.model.market.uppercaseString];
        }
    }
//    self.priceLabel.text = [NSString stringWithFormat:@"%.3f",self.model.now/pow(10, self.model.priceBase)];
//    if (self.model.change > 0) {
//        self.priceLabel.textColor = [QMUITheme stockRedColor];
//    } else if (self.model.change < 0) {
//        self.priceLabel.textColor = [QMUITheme stockGreenColor];
//    } else {
//        self.priceLabel.textColor = [QMUITheme stockGrayColor];
//    }
//
//    self.changeButton.roc = self.model.roc;
}

//
//#pragma mark - actions
//
//- (void)changeButtonAction {
//
//}

#pragma mark - getter
//- (UIImageView *)marketIconView {
//    if (_marketIconView == nil) {
//        _marketIconView = [[UIImageView alloc] init];
//    }
//    return _marketIconView;
//}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [QMUITheme textColorLevel1];
        _nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    }
    return _nameLabel;
}

- (UILabel *)symbolLabel {
    if (_symbolLabel == nil) {
        _symbolLabel = [[UILabel alloc] init];
        _symbolLabel.textColor = [QMUITheme textColorLevel2];
        _symbolLabel.font = [UIFont systemFontOfSize:14];
    }
    return _symbolLabel;
}

- (UILabel *)priceLabel {
    if (_priceLabel == nil) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.textColor = [QMUITheme textColorLevel2];
        _priceLabel.font = [UIFont systemFontOfSize:18];
    }
    return _priceLabel;
}

- (UILabel *)rocLabel {
    if (_rocLabel == nil) {
        _rocLabel = [[UILabel alloc] init];
        _rocLabel.textColor = [QMUITheme textColorLevel2];
        _rocLabel.font = [UIFont systemFontOfSize:18];
    }
    return _rocLabel;
}

- (QMUILabel *)delayLabel {
    if (_delayLabel == nil) {
//        _delayLabel = [[QMUILabel alloc] init];
//        _delayLabel.font = [UIFont systemFontOfSize:8];
//        _delayLabel.textColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.4];
//        _delayLabel.backgroundColor = [[QMUITheme textColorLevel1] colorWithAlphaComponent:0.05];
//        _delayLabel.layer.cornerRadius = 1.0;
//        _delayLabel.layer.masksToBounds = YES;
//        _delayLabel.contentEdgeInsets = UIEdgeInsetsMake(1, 2, 1, 2);
        QMUILabel *delayLabel = [[QMUILabel alloc] init];;
        _delayLabel = delayLabel;
        _delayLabel.text = [YXLanguageUtility kLangWithKey:@"common_delay"];
        delayLabel.textColor = [QMUITheme textColorLevel3];
        delayLabel.font = [UIFont systemFontOfSize:8];
        delayLabel.layer.cornerRadius = 2;
        delayLabel.layer.borderWidth = 0.5;
        delayLabel.layer.borderColor = [QMUITheme textColorLevel3].CGColor;
        delayLabel.layer.masksToBounds = YES;
        delayLabel.contentEdgeInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        _delayLabel.hidden = YES;
    }
    return _delayLabel;
}


- (UIView *)lineView {
    if (_lineView == nil) {
        _lineView = [UIView lineView];
    }
    return _lineView;
}

@end
