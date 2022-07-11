//
//  OSSVCartInvalidTableCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartInvalidTableCell.h"

@implementation OSSVCartInvalidTableCell
@synthesize cartModel = _cartModel;


+ (OSSVCartInvalidTableCell *)cellTableInvalidWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [tableView registerClass:[OSSVCartInvalidTableCell class] forCellReuseIdentifier:@"OSSVCartInvalidTableCell"];
    return [tableView dequeueReusableCellWithIdentifier:@"OSSVCartInvalidTableCell" forIndexPath:indexPath];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.iconView yy_cancelCurrentImageRequest];
    self.iconView.image = nil;
    self.titleLabel.text = nil;
    self.priceLabel.text = nil;
    self.propertyLabel.text = nil;
    self.stateLabel.text = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        UIView *ws = self.contentView;
        //商品图片
        [ws addSubview:self.iconView];
        //商品名称
        [ws addSubview:self.titleLabel];
        [ws addSubview:self.deleteButton];
        //商品属性
        [ws addSubview:self.propertyLabel];
//        [ws addSubview:self.rateBtn];

        //商品价格
        [ws addSubview:self.priceLabel];
        [ws addSubview:self.markePriceLabel];

        [ws addSubview:self.lineView];

        //商品状态
        [self.iconView addSubview:self.stateLabel];
        [ws addSubview:self.flashImageView];
        [ws addSubview:self.unCheckImgView];
        
        [ws bringSubviewToFront:self.iconView];
        [ws addSubview:self.activityStateView];
        [ws addSubview:self.imageMarkView];
        [ws addSubview:self.collectionButton];
        
        
        [self.unCheckImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.mas_centerY);
            if (APP_TYPE == 3) {
                make.leading.mas_equalTo(ws.mas_leading).offset(14);
            } else {
                make.leading.mas_equalTo(ws.mas_leading).offset(8);
            }
            make.size.mas_equalTo(CGSizeMake(18, 18));
        }];

        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.leading.mas_equalTo(self.unCheckImgView.mas_trailing).mas_offset(14);
                make.top.mas_equalTo(ws.mas_top).offset(14);
                make.bottom.mas_equalTo(ws.mas_bottom).offset(-14);
                make.size.equalTo(CGSizeMake(100, 100));

            } else {
                make.leading.mas_equalTo(self.unCheckImgView.mas_trailing).mas_offset(8);
                make.height.mas_equalTo(120);
                make.width.mas_equalTo(self.iconView.mas_height).multipliedBy(90 / 120.0);
                make.top.mas_equalTo(ws.mas_top).offset(12);
                make.bottom.mas_equalTo(ws.mas_bottom).offset(-12);
            }
        }];
        
        [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.mas_equalTo(self.iconView);
        }];
        
        [self.imageMarkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.iconView);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconView.mas_top);
            make.leading.mas_equalTo(self.iconView.mas_trailing).offset(8);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-40);

        }];
        
        [self.collectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.titleLabel.mas_centerY);

//            make.leading.mas_equalTo(self.titleLabel.mas_trailing);
//            make.trailing.mas_equalTo(ws.mas_trailing).offset(-12);
//            make.size.mas_equalTo(CGSizeMake(24, 24));
//            make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        }];
        
        [self.propertyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-12);
        }];
        
//        [self.rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.propertyLabel.mas_bottom).offset(10);
//            make.leading.mas_equalTo(self.titleLabel.mas_leading);
//            make.height.mas_equalTo(18);
//        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.iconView.mas_bottom);
            make.leading.mas_equalTo(self.propertyLabel.mas_leading);
//            make.trailing.mas_equalTo(ws.mas_trailing).offset(-123);
            make.height.equalTo(18);
        }];


        [self.markePriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.priceLabel.mas_top).offset(-2);
            make.leading.mas_equalTo(self.propertyLabel.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-123);
        }];
        
        [self.flashImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceLabel.mas_trailing).offset(2);
            make.centerY.mas_equalTo(self.priceLabel.mas_centerY);
            make.size.equalTo(CGSizeMake(12, 12));
            
        }];

        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.collectionButton.mas_centerX);
            make.centerY.mas_equalTo(self.priceLabel.mas_centerY);
        }];
        
        [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.leading.bottom.mas_equalTo(self.iconView);
            make.height.mas_equalTo(@20);
        }];

        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.iconView.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing);
            make.bottom.mas_equalTo(ws.mas_bottom);
            if (APP_TYPE == 3) {
                make.height.mas_equalTo(@(0.0));
            } else {
                make.height.mas_equalTo(@(0.5));
            }
        }];
        
    }
    return self;
    
}

#pragma mark ----收藏方法
- (void)actionCollect:(UIButton *)sender {
    if (self.operateBlock) {
        self.operateBlock(sender, CartTableCellEventCollect);
    }

}

#pragma mark ----删除方法
- (void)actionDelete:(UIButton *)sender {
    
    if (self.operateBlock) {
        self.operateBlock(sender, CartTableCellEventDelete);
    }
    
}

- (void)setCartModel:(CartModel *)cartModel {
    _cartModel = cartModel;
    
    [self.iconView yy_setImageWithURL:[NSURL URLWithString:cartModel.goodsThumb]
                          placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                              options:kNilOptions
                             progress:nil
                            transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
//                                image = [image yy_imageByResizeToSize:CGSizeMake(80, 80) contentMode:UIViewContentModeScaleAspectFit];
                                return image;
                            }
                           completion:nil];
    
    self.titleLabel.text = STLToString(cartModel.goodsName);
    self.propertyLabel.text = STLToString(cartModel.goodsAttr);
    self.priceLabel.text = STLToString(cartModel.shop_price_converted);
//    self.priceLabel.textColor = [OSSVThemesColors col_0D0D0D];

    //加一个删除线
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:STLToString(cartModel.market_price_converted)
                                                                                attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
    self.markePriceLabel.attributedText = attrStr;
    
    STLLog(@"%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES));
    
    
    self.activityStateView.hidden = YES;
    self.imageMarkView.hidden = YES;
    
    self.stateLabel.hidden = YES;
    if (!cartModel.isOnSale) {
        self.imageMarkView.hidden = NO;
//        self.stateLabel.text = STLLocalizedString_(@"outStock", nil);
        [self.imageMarkView updateName:STLLocalizedString_(@"outStock", nil) showImage:YES flashProduct:NO];
    } else if ([cartModel.goodsStock isEqualToString:@"0"]) {
        self.imageMarkView.hidden = NO;
//        self.stateLabel.text = STLLocalizedString_(@"soldOut", nil);
        [self.imageMarkView updateName:STLLocalizedString_(@"soldOut", nil) showImage:YES flashProduct:NO];

    } else {
        self.imageMarkView.hidden = NO;
        [self.imageMarkView updateName:STLLocalizedString_(@"outStock", nil) showImage:YES flashProduct:NO];

//        self.stateLabel.text = STLLocalizedString_(@"outStock", nil);
    }

    //////折扣标 闪购标
    if ([cartModel.show_discount_icon integerValue] && !STLIsEmptyString(cartModel.discount) && [cartModel.discount floatValue] > 0) {
        self.stateLabel.hidden = NO;
        self.activityStateView.hidden = NO;
        self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(cartModel.discount)];
    }
    
    //闪购活动中，显示的闪购价
    //闪购结束、下线，显示的原价
    if (self.cartModel.flash_sale && [self.cartModel.is_flash_sale boolValue]) {
        
        self.stateLabel.hidden = YES;
        self.imageMarkView.hidden = NO;
        self.flashImageView.hidden = NO;
        if ([self.cartModel.flash_sale.active_status integerValue] == 2) {
            [self.imageMarkView updateName:STLLocalizedString_(@"Flash_Finished", nil) showImage:YES flashProduct:YES];
        } else {
            if ([self.cartModel.flash_sale.sold_out integerValue] == 1) {
                [self.imageMarkView updateName:STLLocalizedString_(@"soldOut", nil) showImage:YES flashProduct:NO];
            } else {
                [self.imageMarkView updateName:STLLocalizedString_(@"outStock", nil) showImage:YES flashProduct:NO];
            }
        }
        
        if ([self.cartModel.flash_sale.active_status integerValue] == 1) {
            self.priceLabel.text = STLToString(cartModel.flash_sale.active_price_converted);
//            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }

        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleFlashSale discount:self.cartModel.flash_sale.active_discount];
    }
    
//    //区级
//    [_rateBtn setTitle:STLToString(cartModel.warehouseName) forState:UIControlStateNormal];
//    if ([cartModel.wid isEqualToString:@"2"]) {//全球
//        [_rateBtn setTitleColor:OSSVThemesColors.col_24A600 forState:UIControlStateNormal];
//        _rateBtn.backgroundColor = OSSVThemesColors.col_E1F2DA;
//    } else {
//        [_rateBtn setTitleColor:OSSVThemesColors.col_2C98E9 forState:UIControlStateNormal];
//        _rateBtn.backgroundColor = OSSVThemesColors.col_E6F2FF;
//    }
}

#pragma mark - LazyLoad
- (UIImageView *)unCheckImgView {
    if (!_unCheckImgView) {
        _unCheckImgView = [UIImageView new];
        _unCheckImgView.image = [UIImage imageNamed:@"Shopping_DisSelected"];
    }
    return _unCheckImgView;
}

- (YYAnimatedImageView *)iconView {
    if (!_iconView) {
        _iconView = [[YYAnimatedImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.clipsToBounds = YES;
        if (APP_TYPE != 3) {
            _iconView.layer.masksToBounds = YES;
            _iconView.backgroundColor = OSSVThemesColors.col_F7F7F7;
            _iconView.layer.borderWidth = 0.5;
            _iconView.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;

        }
    }
    return _iconView;
}

- (UIImageView *)flashImageView {
    if (!_flashImageView) {
        _flashImageView = [UIImageView new];
        _flashImageView.image = [UIImage imageNamed:@"shopBag_flash"];
        _flashImageView.alpha = 0.6;
        _flashImageView.hidden = YES;
    }
    return _flashImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textColor = [OSSVThemesColors col_B2B2B2];
//        _titleLabel.alpha = 0.5;

        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
            _titleLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        }
    }
    return _titleLabel;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[UIImage imageNamed:@"shopBag_detele"] forState:UIControlStateNormal];
        [_deleteButton setImage:[UIImage imageNamed:@"shopBag_detele"] forState:UIControlStateHighlighted];
        [_deleteButton addTarget:self action:@selector(actionDelete:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

- (UIButton *)collectionButton {
    if (!_collectionButton) {
        _collectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collectionButton setImage:[UIImage imageNamed:@"shoppingBag_collect"] forState:UIControlStateNormal];
        [_collectionButton setImage:[UIImage imageNamed:@"shoppingBag_collect"] forState:UIControlStateHighlighted];
        [_collectionButton addTarget:self action:@selector(actionCollect:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _collectionButton;
}

- (UIButton *)rateBtn {
    if (!_rateBtn) {
        _rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rateBtn.userInteractionEnabled = NO;
        _rateBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        [_rateBtn setTitleColor:OSSVThemesColors.col_24A600 forState:UIControlStateNormal];
        _rateBtn.backgroundColor = OSSVThemesColors.col_E1F2DA;
        [_rateBtn setContentEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 8)];
        _rateBtn.alpha = 0.5;

    }
    return _rateBtn;
}

- (UILabel *)propertyLabel {
    if (!_propertyLabel) {
        _propertyLabel = [[UILabel alloc] init];
        _propertyLabel.font = [UIFont boldSystemFontOfSize:12];
        _propertyLabel.textColor = [OSSVThemesColors col_B2B2B2];
//        _propertyLabel.alpha = 0.5;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _propertyLabel.textAlignment = NSTextAlignmentRight;
        }

    }
    return _propertyLabel;
}


- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.textColor = [OSSVThemesColors col_B2B2B2];
        _priceLabel.font = [UIFont boldSystemFontOfSize:14];
//        _priceLabel.alpha = 0.5;
        
        _priceLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _priceLabel.textAlignment = NSTextAlignmentRight;
        }

    }
    return _priceLabel;
}

- (UILabel *)markePriceLabel {
    if (!_markePriceLabel) {
        _markePriceLabel = [[UILabel alloc] init];
        _markePriceLabel.textColor = [OSSVThemesColors col_B2B2B2];
        _markePriceLabel.font = [UIFont systemFontOfSize:12];
        _markePriceLabel.numberOfLines = 1;
//        _markePriceLabel.alpha = 0.5;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _markePriceLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _markePriceLabel;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] init];
        _stateLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _stateLabel.font = [UIFont systemFontOfSize:11];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.backgroundColor = [OSSVThemesColors col_0D0D0D:0.7];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _stateLabel.textAlignment = NSTextAlignmentRight;
        }

    }
    return _stateLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}

- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
//        _activityStateView.flashImageSize = 12;
//        _activityStateView.fontSize = 9;
//        _activityStateView.samllImageShow = YES;
        _activityStateView.hidden = YES;
    }
    return _activityStateView;
}


- (OSSVCartGoodImageMarkView *)imageMarkView {
    if (!_imageMarkView) {
        _imageMarkView = [[OSSVCartGoodImageMarkView alloc] initWithFrame:CGRectZero];
        _imageMarkView.hidden = YES;
    }
    return _imageMarkView;
}
@end
