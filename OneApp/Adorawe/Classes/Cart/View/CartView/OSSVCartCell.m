//
//  OSSVCartCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/28.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartCell.h"
#import "OSSVCartNewUserTipView.h"
#import "OSSVCartGoodImageMarkView.h"

@interface OSSVCartCell ()

@property (nonatomic, strong) UIImageView                    *choiceImgView;
/** 选中按钮*/
@property (nonatomic, strong) UIButton                       *choiceBtn;
/** 商品图片*/
@property (nonatomic, strong) YYAnimatedImageView            *iconView;
/** 商品名称*/
@property (nonatomic, strong) UILabel                        *titleLabel;
/** 商品属性*/
@property (nonatomic, strong) UILabel                        *propertyLabel;
/** 区级*/
@property (nonatomic, strong) UIButton                       *rateBtn;
/** 0元标识*/
@property (nonatomic, strong) OSSVCartNewUserTipView          *zeroNewTipView;
/** 商品价格*/
@property (nonatomic, strong) UILabel                        *priceLabel;
/** 操作View*/
@property (nonatomic, strong) UIView                         *operationView;
/** 商品数量*/
@property (nonatomic, strong) UILabel                        *countLabel;
/** 减少按钮*/
@property (nonatomic, strong) UIButton                       *decreaseBtn;
/** 增加按钮*/
@property (nonatomic, strong) UIButton                       *increaseBtn;
/** 新人免费*/
@property (nonatomic, assign) BOOL                           isFreeGift;
/** 是否达到满减*/
@property (nonatomic, assign) NSInteger                      isFullActive;
////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;

@property (nonatomic, strong) OSSVCartGoodImageMarkView       *imageMarkView;
/** 收藏*/
@property (nonatomic, strong) UIButton                       *collectButton;

@property (nonatomic, strong) UILabel                        *storgeLabel;
@property (nonatomic, strong) UIImageView                    *flashImageView; //闪购商品价格后的图标
@end

@implementation OSSVCartCell
@synthesize cartModel = _cartModel;


+ (OSSVCartCell *)cartCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [tableView registerClass:[OSSVCartCell class] forCellReuseIdentifier:NSStringFromClass(OSSVCartCell.class)];
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVCartCell.class) forIndexPath:indexPath];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.iconView yy_cancelCurrentImageRequest];
    self.iconView.image = nil;
    self.titleLabel.text = nil;
    self.priceLabel.text = nil;
    self.propertyLabel.text = nil;
    self.countLabel.text = nil;
    self.markePriceLabel.text = nil;
    self.storgeLabel.text = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = OSSVThemesColors.col_FFFFFF;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        UIView *ws = self.contentView;

        [ws addSubview:self.choiceImgView];
        //选中按钮
        [ws addSubview:self.choiceBtn];
        //商品图片
        [ws addSubview:self.iconView];
        
        [ws addSubview:self.activityStateView];
        
        [ws addSubview:self.imageMarkView];

        //商品名称
        [ws addSubview:self.titleLabel];
        [ws addSubview:self.collectButton];
        //商品属性
        [ws addSubview:self.propertyLabel];
//        [ws addSubview:self.rateBtn];
        [ws addSubview:self.zeroNewTipView];
        
        //商品价格
        [ws addSubview:self.priceLabel];
        [ws addSubview:self.markePriceLabel];
        [ws addSubview:self.operationView];
        [ws addSubview:self.lineView];
        [ws addSubview:self.storgeLabel];
        [ws addSubview:self.flashImageView];
        
        
        //增加按钮
        [self.operationView addSubview:self.increaseBtn];
        //商品数量
        [self.operationView addSubview:self.countLabel];
        //减少按钮
        [self.operationView addSubview:self.decreaseBtn];
        
        [self.choiceImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(ws.mas_centerY);
            if (APP_TYPE == 3) {
                make.leading.mas_equalTo(ws.mas_leading).offset(14);
            } else {
                make.leading.mas_equalTo(ws.mas_leading).offset(8);
            }
            make.size.mas_equalTo(CGSizeMake(18, 18));
        }];
        
        [self.choiceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.bottom.mas_equalTo(ws);
            make.width.mas_equalTo(44);
        }];
        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.leading.mas_equalTo(self.choiceImgView.mas_trailing).mas_offset(14);
                make.top.mas_equalTo(ws.mas_top).offset(14);
                make.bottom.mas_equalTo(ws.mas_bottom).offset(-14);
                make.size.equalTo(CGSizeMake(100, 100));
            } else {
                make.leading.mas_equalTo(self.choiceImgView.mas_trailing).mas_offset(5);
                make.top.mas_equalTo(ws.mas_top).offset(12);
                make.bottom.mas_equalTo(ws.mas_bottom).offset(-12);
                make.height.mas_equalTo(120);
                make.width.mas_equalTo(self.iconView.mas_height).multipliedBy(90 / 120.0);
            }
        }];
        
        [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.leading.mas_equalTo(self.iconView.mas_leading).offset(2);
                make.top.mas_equalTo(self.iconView.mas_top).offset(2);
            } else {
                make.leading.top.mas_equalTo(self.iconView);
            }
        }];
        
        [self.imageMarkView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.iconView);
        }];
        
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.iconView.mas_top);
            make.leading.mas_equalTo(self.iconView.mas_trailing).offset(8);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-40);
        }];
        
        [self.collectButton mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.trailing.mas_equalTo(ws.mas_trailing).offset(-14);
            } else {
                make.trailing.mas_equalTo(ws.mas_trailing).offset(-12);
            }
            make.centerY.mas_equalTo(self.titleLabel.mas_centerY);
        }];
                
        [self.propertyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(2);
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-12);
        }];
        
//        [self.rateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.propertyLabel.mas_bottom).offset(4);
//            make.leading.mas_equalTo(self.titleLabel.mas_leading);
//        }];
        
        [self.zeroNewTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.titleLabel.mas_leading);
            make.top.mas_equalTo(self.propertyLabel.mas_bottom).offset(4);
            make.height.mas_equalTo(18);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.iconView.mas_bottom);
            make.leading.mas_equalTo(self.propertyLabel.mas_leading);
//            make.trailing.lessThanOrEqualTo(ws.mas_trailing).offset(-123);
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
        
        [self.operationView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.trailing.mas_equalTo(ws.mas_trailing).offset(-14);
            } else {
                make.trailing.mas_equalTo(ws.mas_trailing).offset(-10);
            }
            make.bottom.mas_equalTo(self.iconView.mas_bottom);
            make.height.mas_equalTo(@(32));
        }];
        
        
        [self.increaseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.operationView.mas_top);
            make.bottom.mas_equalTo(self.operationView.mas_bottom);
            make.trailing.mas_equalTo(self.operationView.mas_trailing);
            make.width.mas_equalTo(@(28));
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.increaseBtn.mas_leading).offset(-1);
            if (APP_TYPE == 3) {
                make.width.mas_equalTo(38);
                make.top.bottom.mas_equalTo(self.operationView);
            } else {
                make.width.mas_equalTo(28);
                make.top.mas_equalTo(self.operationView.mas_top).offset(2);
                make.bottom.mas_equalTo(self.operationView.mas_bottom).offset(-2);
            }
        }];
        
        [self.decreaseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.operationView.mas_top);
            make.bottom.mas_equalTo(self.operationView.mas_bottom);
            make.leading.mas_equalTo(self.operationView.mas_leading);
            make.trailing.mas_equalTo(self.countLabel.mas_leading).offset(-1);
            make.width.mas_equalTo(@(28));
        }];
        
        [self.storgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(self.iconView);
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

- (void)updateCartModel:(CartModel *)cartModel freeGift:(BOOL)isFreeGift {
    self.isFreeGift = isFreeGift;
    self.cartModel = cartModel;
}

- (void)updateCartModel:(CartModel *)cartModel isFullActive:(NSInteger)isFullActive {
    self.isFullActive = isFullActive;
    self.cartModel = cartModel;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
//    if (!_activityStateView.isHidden && _activityStateView.size.height > 0) {
        
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(4, 4)];
//        } else {
//            [self.activityStateView.activityVerticalView stlAddCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(4, 4)];
//        }
//    }
}

- (void)updateDecreaseButtonState:(BOOL)canSelect {
    if (canSelect) {
        [_decreaseBtn setImage:[UIImage imageNamed:@"minus_status_01"] forState:UIControlStateNormal];
        [_decreaseBtn setImage:[UIImage imageNamed:@"minus_status_01"] forState:UIControlStateHighlighted];
    } else {
        [_decreaseBtn setImage:[UIImage imageNamed:@"shoppingBag_detele"] forState:UIControlStateNormal];
        [_decreaseBtn setImage:[UIImage imageNamed:@"shoppingBag_detele"] forState:UIControlStateHighlighted];
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

- (void)setCartModel:(CartModel *)cartModel {
    _cartModel = cartModel;
    
    if (APP_TYPE == 3) {
        self.markePriceLabel.hidden = YES;
        self.choiceImgView.image = [UIImage imageNamed:(cartModel.isChecked ? @"viv_ShoppingBag_Selected" : @"viv_ShoppingBag_Unselected")];
    } else {
        self.markePriceLabel.hidden = NO;
        self.choiceImgView.image = [UIImage imageNamed:(cartModel.isChecked ? @"Shopping_Selected" : @"Shopping_UnSelect")];
    }
    self.titleLabel.text = STLToString(cartModel.goodsName);
    self.propertyLabel.text = STLToString(cartModel.goodsAttr) ;
    self.priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
    self.priceLabel.text = STLToString(cartModel.shop_price_converted);
    //加一个删除线
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:STLToString(cartModel.market_price_converted)
                                                                                attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
    self.markePriceLabel.attributedText = attrStr;
    
    self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)cartModel.goodsNumber];
    
    self.storgeLabel.hidden = YES;
    if ([cartModel.goodsStock integerValue] < 20 && [cartModel.goodsStock integerValue] > 0) {
        self.storgeLabel.hidden = NO;
        NSString *goodsTitle = STLLocalizedString_(@"Only_XX_left", nil);
        NSString *goodsNumberStr = [NSString stringWithFormat:@"%@",cartModel.goodsStock];
        self.storgeLabel.text =  [goodsTitle stringByReplacingOccurrencesOfString:@"XX" withString:goodsNumberStr];
    }
    
    //区级 是否全球级别
//    BOOL isWid = [cartModel.wid isEqualToString:@"2"];
//    [_rateBtn setTitle:STLToString(cartModel.warehouseName) forState:UIControlStateNormal];
//    [_rateBtn setTitleColor:isWid ? OSSVThemesColors.col_24A600 : OSSVThemesColors.col_2C98E9 forState:UIControlStateNormal];
//    _rateBtn.backgroundColor = isWid ? OSSVThemesColors.col_E1F2DA : OSSVThemesColors.col_E6F2FF;
    
    self.zeroNewTipView.hidden = YES;
    if ([cartModel.is_exchange boolValue]) {
        self.zeroNewTipView.hidden = NO;
        self.zeroNewTipView.tipLabel.text = [STLToString(cartModel.exchange_label) uppercaseString];

        if (APP_TYPE == 3) {
            self.priceLabel.textColor = OSSVThemesColors.col_9F5123;
            self.zeroNewTipView.tipLabel.textColor = OSSVThemesColors.col_9F5123;
        } else {
            self.zeroNewTipView.tipLabel.textColor = OSSVThemesColors.col_B62B21;
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
        self.priceLabel.text = STLLocalizedString_(@"FREE", nil);
    }
    
    //增加、减少 按钮
    [self updateDecreaseButtonState:(cartModel.goodsNumber <= 1 ? NO : YES)];
    [self updateIncreaseBtnButtonState:YES];
    if (cartModel.goodsNumber >= 1000 || cartModel.goodsNumber == [cartModel.goodsStock integerValue]) {
        [self updateIncreaseBtnButtonState:NO];
    }
    
    [self.iconView yy_setImageWithURL:[NSURL URLWithString:cartModel.goodsThumb]
                          placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                              options:kNilOptions
                             progress:nil
                            transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                return image;
                            }
                           completion:nil];
    
    self.activityStateView.hidden = YES;
    
    //////折扣标 闪购标 
    if ([cartModel.show_discount_icon integerValue] && !STLIsEmptyString(cartModel.discount) && [cartModel.discount floatValue] > 0) {
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(cartModel.discount)];

        if (APP_TYPE == 3) {
            self.priceLabel.textColor = OSSVThemesColors.col_9F5123;
            self.markePriceLabel.hidden = NO;
        } else {
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
    }
    if (self.cartModel.flash_sale && [self.cartModel.flash_sale isCanBuyFlashSaleStateing]) {
        //闪购时，不显示这个库存提示
        self.storgeLabel.hidden = YES;
        self.priceLabel.text = STLToString(self.cartModel.flash_sale.active_price_converted);

        if (APP_TYPE == 3) {
            self.priceLabel.textColor = OSSVThemesColors.col_9F5123;
            self.markePriceLabel.hidden = NO;

        } else {
            self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
        }
        [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(self.cartModel.flash_sale.active_discount)];
        self.flashImageView.hidden = NO;
        if (cartModel.goodsNumber >= 1000 || cartModel.goodsNumber == [cartModel.goodsStock integerValue] || cartModel.goodsNumber >= [cartModel.flash_sale.active_limit integerValue]) {
            [self updateIncreaseBtnButtonState:NO];

        }
    } else {
        self.flashImageView.hidden = YES;
    }
//    if (cartModel.isChecked && self.isFullActive == 1) {
//        self.priceLabel.textColor = OSSVThemesColors.col_B62B21;
//    }
    
    
    //新人礼品不能编辑
    self.operationView.userInteractionEnabled = self.isFreeGift ? NO : YES;
    if (self.isFreeGift) {
        [self updateIncreaseBtnButtonState:NO];
    }
    
}

#pragma mark - 删除功能

- (void)actionDelete:(UIButton *)sender {
    
    if (self.operateBlock) {
        self.operateBlock(sender, CartTableCellEventDelete);
    }
    
}
#pragma mark ---移入收藏列表
- (void)actionCollect:(UIButton *)sender {
    if (self.operateBlock) {
        self.operateBlock(sender, CartTableCellEventCollect);
    }

}

- (void)choiceTouch:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (self.operateBlock) {
        self.operateBlock(sender,(self.cartModel.isChecked ? CartTableCellEventUnSelecte : CartTableCellEventSelected));
    }
}

//增加
- (void)increaseTouch:(UIButton *)sender {
    
    if (self.cartModel.goodsNumber >= 1000) {
        [self updateIncreaseBtnButtonState:NO];
        return;
    }
    
    if(self.cartModel.flash_sale && !STLIsEmptyString(self.cartModel.flash_sale.active_discount) && [self.cartModel.flash_sale.active_discount floatValue] > 0) {
        if (self.cartModel.goodsNumber >= [self.cartModel.flash_sale.active_limit integerValue]) {
            ///展示toast
            NSString *notifi = [NSString stringWithFormat:STLLocalizedString_(@"flash_sale_noti", nil),STLToString(self.cartModel.flash_sale.active_limit)];
            [HUDManager showHUDWithMessage:notifi];
            [self updateIncreaseBtnButtonState:NO];
            return;
        }
    }
    
    if (self.cartModel.goodsNumber == [self.cartModel.goodsStock integerValue]) {
        [self updateIncreaseBtnButtonState:NO];
        return;
    }
    
    if (self.operateBlock) {
        self.operateBlock(sender,CartTableCellEventIncrease);
    }
}
//减少
- (void)reduceTouch:(UIButton *)sender {
    
    if (self.cartModel.goodsNumber <= 1) {
        [self updateDecreaseButtonState:NO];
    //1.4.0修改 最后一个商品 可以删除
        [self actionDelete:sender];
        return;
    }
    
    if (self.operateBlock) {
        self.operateBlock(sender,CartTableCellEventReduce);
    }
}


#pragma mark - LazyLoad

- (UIImageView *)choiceImgView {
    if (!_choiceImgView) {
        _choiceImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        if (APP_TYPE == 3) {
            _choiceImgView.image = [UIImage imageNamed:@"viv_ShoppingBag_Unselected"];
        } else {
            _choiceImgView.image = [UIImage imageNamed:@"Shopping_UnSelect"];

        }
        _choiceImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _choiceImgView;
}
- (UIButton *)choiceBtn {
    if (!_choiceBtn) {
        _choiceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_choiceBtn addTarget:self action:@selector(choiceTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _choiceBtn;
}

- (YYAnimatedImageView *)iconView {
    if (!_iconView) {
        _iconView = [[YYAnimatedImageView alloc] init];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        if (APP_TYPE != 3) {
            _iconView.layer.masksToBounds = YES;
            _iconView.layer.borderWidth = 0.5;
            _iconView.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        }
        _iconView.clipsToBounds = YES;
    }
    return _iconView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = APP_TYPE ==3 ? [OSSVThemesColors col_000000:1.0] :[OSSVThemesColors col_6C6C6C];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _titleLabel;
}

- (UIButton *)collectButton {
    if (!_collectButton) {
        _collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collectButton setImage:[UIImage imageNamed:@"shoppingBag_collect"] forState:UIControlStateNormal];
        [_collectButton setImage:[UIImage imageNamed:@"shoppingBag_collect"] forState:UIControlStateHighlighted];
        [_collectButton addTarget:self action:@selector(actionCollect:) forControlEvents:UIControlEventTouchUpInside];
//        _deleteButton.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    }
    return _collectButton;
}

- (UIButton *)rateBtn {
    if (!_rateBtn) {
        _rateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rateBtn.userInteractionEnabled = NO;
        _rateBtn.titleLabel.font = [UIFont systemFontOfSize:10];

        [_rateBtn setTitleColor:OSSVThemesColors.col_24A600 forState:UIControlStateNormal];
        _rateBtn.backgroundColor = OSSVThemesColors.col_E1F2DA;
        [_rateBtn setContentEdgeInsets:UIEdgeInsetsMake(2, 4, 2, 4)];
    }
    return _rateBtn;
}

- (OSSVCartNewUserTipView *)zeroNewTipView {
    if (!_zeroNewTipView) {
        _zeroNewTipView = [[OSSVCartNewUserTipView alloc] initWithFrame:CGRectZero];
        _zeroNewTipView.hidden = YES;
    }
    return _zeroNewTipView;
}

- (UILabel *)propertyLabel {
    if (!_propertyLabel) {
        _propertyLabel = [[UILabel alloc] init];
        if (APP_TYPE == 3) {
            _propertyLabel.textColor = [OSSVThemesColors col_000000:0.5];
        } else {
            _propertyLabel.textColor = [OSSVThemesColors col_6C6C6C];
        }
        _propertyLabel.font = [UIFont boldSystemFontOfSize:12];
        _propertyLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _propertyLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _propertyLabel;
}

- (UILabel *)markePriceLabel {
    if (!_markePriceLabel) {
        _markePriceLabel = [[UILabel alloc] init];
        if (APP_TYPE == 3) {
            _markePriceLabel.textColor = [OSSVThemesColors col_000000:0.7];
            _markePriceLabel.font = [UIFont systemFontOfSize:10];
        } else {
            _markePriceLabel.textColor = [OSSVThemesColors col_6C6C6C];
            _markePriceLabel.font = [UIFont systemFontOfSize:12];
        }
        _markePriceLabel.numberOfLines = 1;
        _markePriceLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _markePriceLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _markePriceLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.textColor = [OSSVThemesColors col_0D0D0D];
        _priceLabel.font = [UIFont boldSystemFontOfSize:14];
        _priceLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _priceLabel.textAlignment = NSTextAlignmentRight; 
        }
    }
    return _priceLabel;
}

- (UIImageView *)flashImageView {
    if (!_flashImageView) {
        _flashImageView = [UIImageView new];
        _flashImageView.image = [UIImage imageNamed:@"shopBag_flash"];
    }
    return _flashImageView;
}

- (UIView *)operationView {
    if (!_operationView) {
        _operationView = [UIView new];
        _operationView.backgroundColor = [UIColor whiteColor];
        if (APP_TYPE == 3) {
        _operationView.backgroundColor = OSSVThemesColors.col_FAFAFA;
            _operationView.layer.borderColor = OSSVThemesColors.col_E0E0E0.CGColor;
        _operationView.layer.borderWidth = 0.5;
        _operationView.layer.cornerRadius = 3.0;
        _operationView.layer.masksToBounds = YES;
        }
    }
    return _operationView;
}

- (UIButton *)increaseBtn {
    if (!_increaseBtn) {
        _increaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (APP_TYPE == 3) {
            _decreaseBtn.backgroundColor = OSSVThemesColors.col_FAFAFA;
        } else {
            _increaseBtn.backgroundColor = OSSVThemesColors.col_FFFFFF;
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
        if (APP_TYPE == 3) {
           _countLabel.backgroundColor = [OSSVThemesColors stlWhiteColor];
        } else {
            _countLabel.backgroundColor = [OSSVThemesColors col_FAFAFA];
        }
        _countLabel.font = [UIFont boldSystemFontOfSize:14];
        _countLabel.textColor = OSSVThemesColors.col_0D0D0D;
        _countLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _countLabel;
}

- (UIButton *)decreaseBtn {
    if (!_decreaseBtn) {
        _decreaseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (APP_TYPE == 3) {
            _decreaseBtn.backgroundColor = OSSVThemesColors.col_FAFAFA;
        } else {
            _decreaseBtn.backgroundColor = [OSSVThemesColors stlWhiteColor];
        }
        [_decreaseBtn setImage:[UIImage imageNamed:@"minus_status_01"] forState:UIControlStateNormal];
        [_decreaseBtn setImage:[UIImage imageNamed:@"minus_status_01"] forState:UIControlStateHighlighted];
        [_decreaseBtn addTarget:self action:@selector(reduceTouch:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _decreaseBtn;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}

- (UILabel *)storgeLabel {
    if (!_storgeLabel) {
        _storgeLabel = [[UILabel alloc] init];
        _storgeLabel.font = [UIFont boldSystemFontOfSize:10];
        _storgeLabel.textColor = [OSSVThemesColors col_ffffff:1];
        _storgeLabel.backgroundColor = [OSSVThemesColors col_0D0D0D:0.5];
        _storgeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _storgeLabel;
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
