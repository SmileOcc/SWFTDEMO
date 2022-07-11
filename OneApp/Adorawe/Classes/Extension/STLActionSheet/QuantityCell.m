//
//  QuantityCell.m
// XStarlinkProject
//
//  Created by 10010 on 2017/9/19.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import "QuantityCell.h"

@implementation QuantityCell

+ (QuantityCell *)quantityCellWithCollectionView:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    [collectionView registerClass:[QuantityCell class] forCellWithReuseIdentifier:@"QuantityCell"];
    return [collectionView dequeueReusableCellWithReuseIdentifier:@"QuantityCell" forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
//        [self.contentView addSubview:self.resultLabel];
        [self.contentView addSubview:self.separateLineView];
        [self.contentView addSubview:self.quantityLabel];
        [self.contentView addSubview:self.storgeLabel];
        [self.contentView addSubview:self.operationView];
        //增加按钮
        [self.operationView addSubview:self.increaseBtn];
        //商品数量
        [self.operationView addSubview:self.countLabel];
        //减少按钮
        [self.operationView addSubview:self.decreaseBtn];
        
//        [self.resultLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.trailing.mas_equalTo(self.contentView);
//            make.top.mas_equalTo(self.contentView);
//            make.height.mas_equalTo(0);
//        }];
        
        [self.separateLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).mas_offset(0);
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(-16);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(16);
            make.height.mas_equalTo(0.5);
        }];
        
        [self.quantityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.separateLineView.mas_bottom).mas_offset(26);
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        }];
        
        [self.storgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.quantityLabel.mas_centerY);
            make.leading.mas_equalTo(self.quantityLabel.mas_trailing).mas_offset(5);
        }];
        

        [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-16);
            make.centerY.mas_equalTo(self.quantityLabel.mas_centerY);
            make.width.mas_equalTo(APP_TYPE == 3 ? 48 + 38 : 76 + 14);
            make.height.mas_equalTo(APP_TYPE == 3 ? 26 : 28);
        }];

        [self.increaseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.operationView.mas_top);
            make.bottom.mas_equalTo(self.operationView.mas_bottom);
            make.trailing.mas_equalTo(self.operationView.mas_trailing);
            make.width.mas_equalTo(APP_TYPE == 3 ? 24 : 28);
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.operationView.mas_top);
//            make.bottom.mas_equalTo(self.operationView.mas_bottom);
            make.trailing.mas_equalTo(self.increaseBtn.mas_leading).offset(-1);
            make.center.mas_equalTo(self.operationView);
            make.width.mas_equalTo(APP_TYPE == 3 ? 38 : 28);
            make.height.mas_equalTo(@(28));
        }];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            
            [self.decreaseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.operationView.mas_top);
                make.bottom.mas_equalTo(self.operationView.mas_bottom);
                make.leading.mas_equalTo(self.operationView.mas_leading);
                make.trailing.mas_equalTo(self.decreaseBtn.mas_leading).offset(-1);
                make.width.mas_equalTo(APP_TYPE == 3 ? 24 : 28);
            }];
        } else {
            
            [self.decreaseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.operationView.mas_top);
                make.bottom.mas_equalTo(self.operationView.mas_bottom);
                make.leading.mas_equalTo(self.operationView.mas_leading);
                make.trailing.mas_equalTo(self.countLabel.mas_leading).offset(-1);
                make.width.mas_equalTo(@(28));
            }];
        }
        
    }
    return self;
}

//- (void)updatequantityCell:(NSString *)attribute {
//
//    NSString *attributeStr = STLToString(attribute);
//    self.resultLabel.text = attributeStr;
//    if (attributeStr.length > 0) {
//        [self.resultLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(33);
//        }];
//    } else {
//        [self.resultLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(0);
//        }];
//    }
//}
//
//+ (CGFloat)heightquantityCell:(NSString *)attribute {
//    NSString *attributeStr = STLToString(attribute);
//
//    if (attributeStr.length > 0) {
//        return 65 + 33;
//    }
//    return 65;
//}

- (void)handleGoodsNumber:(OSSVDetailsBaseInfoModel *)baseInfoModel currnetCount:(NSInteger)count {
    self.baseInfoModel = baseInfoModel;
    self.storgeLabel.text = @"";
    self.storgeLabel.textColor = [OSSVThemesColors col_666666];

    NSInteger goodsNumber = [baseInfoModel.goodsNumber integerValue];
    if (count >= goodsNumber) {
        count = goodsNumber;
    }

    [self updateIncreaseBtnButtonState:NO];
    [self updateDecreaseButtonState:NO];

    if (count >= 1000) {
        self.countLabel.text = @"1000";
        [self updateDecreaseButtonState:YES];
        count = 1000;
        
    } else {
        if (!baseInfoModel.isOnSale) {
            self.storgeLabel.text = STLLocalizedString_(@"outStock", nil);
            self.storgeLabel.textColor = OSSVThemesColors.col_B62B21;
        } else if (goodsNumber <= 0) {
            self.storgeLabel.text = STLLocalizedString_(@"soldOut", nil);
            self.storgeLabel.textColor = OSSVThemesColors.col_B62B21;
            count = 0;
            
        } else if(goodsNumber <= 20) { // 库存小于等于3时，显示仅限X件
            
            if (goodsNumber == 1 || count >= goodsNumber) {
                count = goodsNumber;
            }
            
            if (count >= 1 && count <= goodsNumber) {
                [self updateDecreaseButtonState:(count == 1 ? NO : YES)];
                [self updateIncreaseBtnButtonState:(count == goodsNumber ? NO : YES)];
            }
            
            self.storgeLabel.textColor = OSSVThemesColors.col_B62B21;
            NSString *goodsTitle = STLLocalizedString_(@"Only_XX_left", nil);
            NSString *goodsNumberStr = [NSString stringWithFormat:@"%ld",(long)goodsNumber];
            self.storgeLabel.text =  [goodsTitle stringByReplacingOccurrencesOfString:@"XX" withString:goodsNumberStr];
        } else {
            
            if (count < goodsNumber) { //小于库存时
                [self updateDecreaseButtonState:(YES)];
                [self updateIncreaseBtnButtonState:(YES)];
                if (count <= 1) {
                    [self updateDecreaseButtonState:(NO)];
                    count = 1;
                }
            } else { // 等于大于库存时

                [self updateDecreaseButtonState:(YES)];
                [self updateIncreaseBtnButtonState:(NO)];
            }
        }
        
        /////
        if(self.baseInfoModel.flash_sale && [self.baseInfoModel.flash_sale isCanBuyFlashSaleStateing]) {
            //闪购商品,输入数量>= 限购数量时候，+ 按钮置灰
            if (count >= [self.baseInfoModel.flash_sale.active_limit integerValue]) {
                [self updateIncreaseBtnButtonState:NO];
                count = [self.baseInfoModel.flash_sale.active_limit integerValue];
//                NSString *msg = STLLocalizedString_(@"Max_Qty_allowed_limited_product_is_XXXX", nil);
//                if ([msg rangeOfString:@"XXXX"].location != NSNotFound) {
//                    msg = [msg stringByReplacingOccurrencesOfString:@"XXXX" withString:self.baseInfoModel.flash_sale.active_limit];
//                    ShowToastToViewWithTextTime(self, msg,1.5);
//                    self.userInteractionEnabled = NO;
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        self.userInteractionEnabled = YES;
//                    });
//                }

            }
        }
    }
    
    self.currentCount = count;
    self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)count];
    if (self.goodsNumBlock) {
        self.goodsNumBlock([NSString stringWithFormat:@"%ld",(long)count]);
    }
    
    for (OSSVSpecsModel *specModel in baseInfoModel.GoodsSpecs) {
        BOOL isselectSize = specModel.isSelectSize;
        if (isselectSize) {
            self.storgeLabel.hidden = NO;
        }else{
            self.storgeLabel.hidden = YES;
        }
        break;
    }
}

//增加
- (void)increaseTouch:(UIButton *)sender {
    OSSVSpecsModel *specModel = self.baseInfoModel.GoodsSpecs.firstObject;
    if (!specModel.isSelectSize) {
        if (self.goodsNumBlock) {
            self.goodsNumBlock(nil);
        }
        return;
    }
    
    if (self.operateBlock) {
        self.operateBlock(QuantityCellEventIncrease);
    }
    NSInteger purposeCount = self.currentCount + 1;
    if (purposeCount >= 1000 || purposeCount > [self.baseInfoModel.goodsNumber integerValue]) {
        [self updateIncreaseBtnButtonState:NO];
        return;
        
    }else if(self.baseInfoModel.flash_sale && [self.baseInfoModel.flash_sale isCanBuyFlashSaleStateing]) {
        
        if (purposeCount > [self.baseInfoModel.flash_sale.active_limit integerValue]) {
            [self updateIncreaseBtnButtonState:NO];
//            NSString *msg = STLLocalizedString_(@"Max_Qty_allowed_limited_product_is_XXXX", nil);
//            if ([msg rangeOfString:@"XXXX"].location != NSNotFound) {
//                msg = [msg stringByReplacingOccurrencesOfString:@"XXXX" withString:self.baseInfoModel.flash_sale.active_limit];
//                ShowToastToViewWithTextTime(self, msg,1.5);
//                self.userInteractionEnabled = NO;
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    self.userInteractionEnabled = YES;
//                });
//            }
            return;
        }
    }
    
    if (self.goodsNumBlock) {
        NSInteger currentCount = [self.countLabel.text integerValue];
        [self handleGoodsNumber:self.baseInfoModel currnetCount:currentCount + 1];
    }
}
//减少
- (void)reduceTouch:(UIButton *)sender {
    OSSVSpecsModel *specModel = self.baseInfoModel.GoodsSpecs.firstObject;
    if (!specModel.isSelectSize) {
        if (self.goodsNumBlock) {
            self.goodsNumBlock(nil);
        }
        return;
    }
    if (self.operateBlock) {
        self.operateBlock(QuantityCellEventReduce);
    }
    if ([self.baseInfoModel.goodsNumber integerValue] <= 1 || self.currentCount <=1) {
        [self updateDecreaseButtonState:NO];
        return;
    }
    
    if (self.goodsNumBlock) {
        NSInteger currentCount = [self.countLabel.text integerValue];
        [self handleGoodsNumber:self.baseInfoModel currnetCount:currentCount - 1];
    }
}

#pragma mark - LazyLoad

//- (UILabel *)resultLabel {
//    if (!_resultLabel) {
//        _resultLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _resultLabel.textColor = OSSVThemesColors.col_666666;
//        _resultLabel.font = [UIFont systemFontOfSize:12];
//        _resultLabel.numberOfLines = 2;
//    }
//    return _resultLabel;
//}
- (UIView *)separateLineView {
    if (!_separateLineView) {
        _separateLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _separateLineView.backgroundColor = OSSVThemesColors.col_EFEFEF;
        _separateLineView.hidden = YES;
    }
    return _separateLineView;
}

- (UILabel *)quantityLabel {
    if (!_quantityLabel) {
        _quantityLabel = [[UILabel alloc] init];
        _quantityLabel.text = STLLocalizedString_(@"quantity", nil);
        _quantityLabel.font = [UIFont boldSystemFontOfSize:13];
        _quantityLabel.textColor = [OSSVThemesColors col_0D0D0D];
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _quantityLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
        
    }
    return _quantityLabel;
}

- (UILabel *)storgeLabel {
    if (!_storgeLabel) {
        _storgeLabel = [[UILabel alloc] init];
        _storgeLabel.font = [UIFont boldSystemFontOfSize:10];
        _storgeLabel.textColor = [OSSVThemesColors col_666666];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _storgeLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
    }
    return _storgeLabel;
}

//- (QuantityEdit *)quantity {
//    if (!_quantity) {
//        _quantity = [QuantityEdit numberButtonWithFrame:CGRectZero];
//        _quantity.minValue = 1;// 设置最小值
//        _quantity.inputFieldFont = 14;// 设置输入框中的字体大小
//        _quantity.increaseTitle = @"＋";
//        _quantity.decreaseTitle = @"－";
//        _quantity.isInput = NO; // 输入框不可输入
//
//        @weakify(self)
//        _quantity.numberBlock = ^(NSString *num){
//            @strongify(self)
//            if (self.goodsNumBlock) {
//                self.goodsNumBlock(num);
//            }
//        };
//    }
//    return _quantity;
//}

- (UIView *)operationView {
    if (!_operationView) {
        _operationView = [UIView new];
        
        if (APP_TYPE == 3) {
                    _operationView.layer.borderColor = [OSSVThemesColors col_E0E0E0].CGColor;
                    _operationView.layer.borderWidth = 0.5;
                    _operationView.layer.cornerRadius = 3.0;
                    _operationView.layer.masksToBounds = YES;
            _operationView.backgroundColor = [OSSVThemesColors col_FAFAFA];
        }else{
            _operationView.backgroundColor = [OSSVThemesColors stlClearColor];
        }

        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _operationView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        }
    }
    return _operationView;
}

- (UIButton *)increaseBtn {
    if (!_increaseBtn) {
        _increaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _increaseBtn.backgroundColor = OSSVThemesColors.col_FFFFFF;
        if (APP_TYPE == 3) {
            _increaseBtn.backgroundColor = UIColor.clearColor;
        }
        [_increaseBtn setImage:[UIImage imageNamed:@"plus_01"] forState:UIControlStateNormal];
        [_increaseBtn setImage:[UIImage imageNamed:@"plus_01"] forState:UIControlStateHighlighted];
        [_increaseBtn addTarget:self action:@selector(increaseTouch:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _increaseBtn;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.backgroundColor = OSSVThemesColors.col_FAFAFA;
        _countLabel.font = [UIFont systemFontOfSize:13];
        _countLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _countLabel.textAlignment = NSTextAlignmentCenter;
        if (APP_TYPE == 3) {
            _countLabel.backgroundColor = OSSVThemesColors.col_FFFFFF;
            _countLabel.font = [UIFont systemFontOfSize:12];
            _countLabel.textColor = [OSSVThemesColors col_000000:1];
        }
    }
    return _countLabel;
}

- (UIButton *)decreaseBtn {
    if (!_decreaseBtn) {
        _decreaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _decreaseBtn.backgroundColor = OSSVThemesColors.col_FFFFFF;
        if (APP_TYPE == 3) {
            _decreaseBtn.backgroundColor = UIColor.clearColor;
        }
        [_decreaseBtn setImage:[UIImage imageNamed:@"minus_status_01"] forState:UIControlStateNormal];
        [_decreaseBtn setImage:[UIImage imageNamed:@"minus_status_01"] forState:UIControlStateHighlighted];
        [_decreaseBtn addTarget:self action:@selector(reduceTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _decreaseBtn;
}

- (void)updateDecreaseButtonState:(BOOL)canSelect {
    if (canSelect) {
        [_decreaseBtn setImage:[UIImage imageNamed:@"minus_status_01"] forState:UIControlStateNormal];
        [_decreaseBtn setImage:[UIImage imageNamed:@"minus_status_01"] forState:UIControlStateHighlighted];
    } else {
        [_decreaseBtn setImage:[UIImage imageNamed:@"minus_01_dis"] forState:UIControlStateNormal];
        [_decreaseBtn setImage:[UIImage imageNamed:@"minus_01_dis"] forState:UIControlStateHighlighted];
    }
}

- (void)updateIncreaseBtnButtonState:(BOOL)canSelect {
    if (canSelect) {
        [_increaseBtn setImage:[UIImage imageNamed:@"plus_01"] forState:UIControlStateNormal];
        [_increaseBtn setImage:[UIImage imageNamed:@"plus_01"] forState:UIControlStateHighlighted];
    } else {
        [_increaseBtn setImage:[UIImage imageNamed:@"plus_status_01-0"] forState:UIControlStateNormal];
        [_increaseBtn setImage:[UIImage imageNamed:@"plus_status_01-0"] forState:UIControlStateHighlighted];
    }
}
@end
