//
//  OSSVWishListsTableCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVWishListsTableCell.h"
#import "OSSVAccountMysWishsModel.h"
#import "OSSVDetailsActivityFullReductionView.h"
#import "STLCLineLabel.h"
@interface OSSVWishListsTableCell ()

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) YYAnimatedImageView *image;
@property (nonatomic, strong) UILabel *content;
@property (nonatomic, strong) UILabel *arr;
@property (nonatomic, strong) UILabel *price;
@property (nonatomic, strong) STLCLineLabel *markePriceLabel;

@property (nonatomic, strong) UIView  *coverView;
@property (nonatomic, strong) UIImageView *stateImageView;
@property (nonatomic, strong) UILabel *state;


@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *addToCartBtn;

@property (nonatomic, strong) UIView *lineView;

////折扣标 闪购
@property (nonatomic, strong) OSSVDetailsHeaderActivityStateView   *activityStateView;
@property (nonatomic, strong) OSSVDetailsActivityFullReductionView     *activityFullReductionView;

@end

@implementation OSSVWishListsTableCell

+ (OSSVWishListsTableCell *)accountMyWishCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath {
    return [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(OSSVWishListsTableCell.class) forIndexPath:indexPath];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [OSSVThemesColors stlClearColor];
        self.coverView.backgroundColor = [OSSVThemesColors stlClearColor];
        
        [self.contentView addSubview:self.bgView];
        
        _image = [[YYAnimatedImageView alloc] init];
        _image.contentMode = UIViewContentModeScaleAspectFill;
        _image.clipsToBounds = YES;
        if (APP_TYPE == 3) {
            
        } else {
            _image.layer.borderWidth = 0.5f;
            _image.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        }
        
        [self.bgView addSubview:_image];
        
        _content = [[UILabel alloc] init];
        _content.textColor = [OSSVThemesColors col_6C6C6C];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _content.lineBreakMode = NSLineBreakByTruncatingTail;
        }
        _content.font = [UIFont systemFontOfSize:12];
        [self.bgView addSubview:_content];
        
        _arr = [[UILabel alloc] init];
        if (APP_TYPE == 3) {
            _arr.textColor = [OSSVThemesColors col_000000:0.5];
        } else {
            _arr.textColor = [OSSVThemesColors col_6C6C6C];
        }
        _arr.font = [UIFont boldSystemFontOfSize:12];
        [self.bgView addSubview:_arr];
        
        _price = [[UILabel alloc] init];
        _price.textColor = [OSSVThemesColors col_0D0D0D];
        _price.font = [UIFont boldSystemFontOfSize:14];
        [self.bgView addSubview:_price];
        
        [self.bgView addSubview:self.markePriceLabel];

        [self.bgView addSubview:self.activityFullReductionView];

        [self.bgView addSubview:self.activityStateView];
        
        if (APP_TYPE == 3) {
            [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.contentView.mas_leading);
                make.trailing.mas_equalTo(self.contentView.mas_trailing);
                make.top.bottom.mas_equalTo(self.contentView);
            }];
            
            [_image mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.mas_equalTo(self.bgView.mas_top).offset(14);
                make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-14);
                make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
                make.width.mas_equalTo(self.image.mas_height);//.multipliedBy(84.0/112.0);
            }];
            
            [_content mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.mas_equalTo(_image.mas_top);
                make.leading.mas_equalTo(_image.mas_trailing).mas_offset(8);
                make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
            }];
            
            [_arr mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.mas_equalTo(_content.mas_bottom).mas_offset(2);
                make.leading.mas_equalTo(_image.mas_trailing).mas_offset(8);
                make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-14);
            }];

            [_price mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.mas_equalTo(self.arr.mas_bottom).mas_offset(4);
                make.leading.mas_equalTo(_image.mas_trailing).mas_offset(8);
            }];
            
            
            [self.markePriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.price.mas_centerY);
                make.leading.mas_equalTo(self.price.mas_trailing).mas_offset(4);
            }];
            
            
            [self.activityFullReductionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.content.mas_leading);
                make.height.mas_equalTo(16);
                make.top.mas_equalTo(self.price.mas_bottom).mas_offset(4);
                make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-14);
            }];

            [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(_image.mas_leading).offset(6);
                make.top.mas_equalTo(_image.mas_top).offset(6);
            }];
            
        } else {
            
            [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
                make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
                make.top.bottom.mas_equalTo(self.contentView);
            }];
            
            [_image mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.mas_equalTo(self.bgView.mas_top).offset(8);
                make.bottom.mas_equalTo(self.bgView.mas_bottom).offset(-8);
                make.leading.mas_equalTo(self.bgView.mas_leading).offset(14);
                make.width.mas_equalTo(self.image.mas_height);//.multipliedBy(84.0/112.0);
            }];
            
            [_content mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.mas_equalTo(_image.mas_top);
                make.leading.mas_equalTo(_image.mas_trailing).mas_offset(8);
                make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-12);
            }];
            
            [_arr mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.mas_equalTo(_content.mas_bottom).mas_offset(2);
                make.leading.mas_equalTo(_image.mas_trailing).mas_offset(8);
                make.trailing.mas_equalTo(self.bgView.mas_trailing).offset(-12);
            }];
            
            [_price mas_makeConstraints:^(MASConstraintMaker *make){
                make.top.mas_equalTo(self.arr.mas_bottom).mas_offset(4);
                make.leading.mas_equalTo(_image.mas_trailing).mas_offset(8);
            }];
            
            
            [self.markePriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.price.mas_centerY);
                make.leading.mas_equalTo(self.price.mas_trailing).mas_offset(4);
            }];
            
            
            [self.activityFullReductionView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(self.content.mas_leading);
                make.height.mas_equalTo(16);
                make.top.mas_equalTo(self.price.mas_bottom).mas_offset(8);
                make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
            }];


            [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(_image.mas_leading);
                make.top.mas_equalTo(_image.mas_top);
            }];
        }
        
        
        [self.bgView addSubview:self.coverView];
        [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.image);
        }];
        
        [self.coverView addSubview:self.stateImageView];
        
        [self.stateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.coverView.mas_centerY).mas_offset(-2);
            make.centerX.mas_equalTo(self.coverView.mas_centerX);
        }];
        
        _state = [[UILabel alloc] init];
        _state.font = [UIFont systemFontOfSize:12];
        _state.textAlignment = NSTextAlignmentCenter;
        _state.textColor = [OSSVThemesColors stlWhiteColor];
        _state.backgroundColor = [OSSVThemesColors stlClearColor];
        
        [self.coverView addSubview:_state];
        
        [_state mas_makeConstraints:^(MASConstraintMaker *make){
            make.trailing.leading.mas_equalTo(self.coverView);
            make.top.mas_equalTo(self.stateImageView.mas_bottom).mas_offset(4);
            make.height.mas_equalTo(@20);
        }];
        
        
        [self.bgView addSubview:self.deleteButton];
        [self.bgView addSubview:self.addToCartBtn];

        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.image.mas_trailing).mas_offset(8);
            make.trailing.mas_equalTo(self.addToCartBtn.mas_leading).mas_offset(-8);
            make.bottom.mas_equalTo(self.image.mas_bottom);
            make.height.mas_equalTo(28);
        }];
        
        [self.addToCartBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.bgView.mas_trailing).mas_offset(-14);
            make.leading.mas_equalTo(self.deleteButton.mas_trailing).mas_offset(8);
            make.bottom.mas_equalTo(self.image.mas_bottom);
            make.height.mas_equalTo(28);
            make.width.mas_equalTo(self.deleteButton.mas_width).multipliedBy(143.0 / 80.0);
        }];
        
        
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
        [self.bgView addSubview:lineView];
        self.lineView = lineView;
    
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(14);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-14);
            make.bottom.mas_equalTo(self.contentView.mas_bottom);
            make.height.mas_equalTo(0.5);
        }];

    }
    return self;
}

-(void)addToCartAction{
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(accountMyWishCell:addToCart:)]) {
        [self.myDelegate accountMyWishCell:self addToCart:self.model];
    }
}

- (void)deleteAction {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(accountMyWishCell:deleteModel:)]) {
        [self.myDelegate accountMyWishCell:self deleteModel:self.model];
    }
}


- (void)showBottomLine:(BOOL)show {
    self.lineView.hidden = !show;
    
    if (APP_TYPE == 3) {
        self.lineView.hidden = YES;
    }
}

- (void)setModel:(OSSVAccountMysWishsModel *)model {
    _model = model;
    
    if (APP_TYPE == 3) {
        self.price.textColor = [OSSVThemesColors col_000000:1];
    } else {
        self.price.textColor = [OSSVThemesColors col_0D0D0D];
    }
    self.coverView.hidden = YES;
    if (!model.isOnSale) {
        _state.text  = STLLocalizedString_(@"soldOut", nil);
        self.coverView.hidden = NO;
    } else if ([model.goodsNum isEqualToString:@"0"] || model.goodsNum == nil) {
        _state.text  = STLLocalizedString_(@"outStock", nil);
        self.coverView.hidden = NO;
    }

    [_image yy_setImageWithURL:[NSURL URLWithString:model.goodsThumb]
                   placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                       options:kNilOptions
                      progress:nil
                     transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                    return image;
                                }
                    completion:nil];
    _content.text = model.goodsTitle;
    _arr.text = model.goodsAttr;
    
    _price.text = STLToString(model.shop_price_converted);
        
    self.activityFullReductionView.hidden = NO;
    self.activityFullReductionView.tipMessage = STLToString(model.tips_reduction);
    //加一个删除线
//    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:STLToString(model.market_price_converted)
//                                                                                attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle)}];
    self.markePriceLabel.text = STLToString(model.market_price_converted);
    
    //////折扣标 闪购标
    self.activityStateView.hidden = YES;
    
    if (APP_TYPE == 3) {
        self.markePriceLabel.hidden = YES;
    }
    
    if ([model.show_discount_icon integerValue] && !STLIsEmptyString(model.cutoff) && [model.cutoff floatValue] > 0) {
        self.markePriceLabel.hidden = NO;
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleNormal discount:STLToString(model.cutoff)];
        if (APP_TYPE == 3) {
            self.price.textColor = OSSVThemesColors.col_9F5123;
        } else {
            self.price.textColor = OSSVThemesColors.col_B62B21;
        }
    }
    if (model.flash_sale && [model.flash_sale isOnlyFlashActivity]) {
        self.activityFullReductionView.hidden = YES;
        
        self.markePriceLabel.hidden = NO;
        _price.text = STLToString(model.flash_sale.active_price_converted);
        if (APP_TYPE == 3) {
            self.price.textColor = OSSVThemesColors.col_9F5123;
        } else {
            self.price.textColor = OSSVThemesColors.col_B62B21;
        }
        self.activityStateView.hidden = NO;
        [self.activityStateView updateState:STLActivityStyleFlashSale discount:STLToString(model.flash_sale.active_discount)];

    }
    
    [self setNeedsDisplay];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [_image yy_cancelCurrentImageRequest];
    _image.image = nil;
    _content.text = nil;
    _arr.text = nil;
    _price.text = nil;
    _state.text = nil;
}


- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [OSSVThemesColors stlWhiteColor];
    }
    return _bgView;
}

- (STLCLineLabel *)markePriceLabel {
    if (!_markePriceLabel) {
        _markePriceLabel = [[STLCLineLabel alloc] init];
        _markePriceLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _markePriceLabel.font = [UIFont systemFontOfSize:10];
        _markePriceLabel.numberOfLines = 1;
        _markePriceLabel.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _markePriceLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _markePriceLabel;
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:CGRectZero];
        _coverView.backgroundColor = [OSSVThemesColors col_0D0D0D:0.3];
        _coverView.hidden = YES;
    }
    return _coverView;
}

- (UIImageView *)stateImageView {
    if (!_stateImageView) {
        _stateImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _stateImageView.image = [UIImage imageNamed:@"shopBag_yijia"];
    }
    return _stateImageView;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];;
        _deleteButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _deleteButton.backgroundColor = [OSSVThemesColors stlWhiteColor];
        if (APP_TYPE == 3) {
            [_deleteButton setTitleColor:[OSSVThemesColors col_000000:1] forState:UIControlStateNormal];
            _deleteButton.layer.borderColor = [OSSVThemesColors col_E1E1E1].CGColor;
            [_deleteButton setTitle:STLLocalizedString_(@"delete", nil) forState:UIControlStateNormal];

        } else {
            [_deleteButton setTitleColor:[OSSVThemesColors col_0D0D0D] forState:UIControlStateNormal];
            _deleteButton.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
            [_deleteButton setTitle:[STLLocalizedString_(@"delete", nil) uppercaseString] forState:UIControlStateNormal];

        }
        _deleteButton.layer.borderWidth = 1.0;
        [_deleteButton addTarget:self action:@selector(deleteAction) forControlEvents:(UIControlEventTouchUpInside)];

    }
    return _deleteButton;
}

- (UIButton *)addToCartBtn {
    if (!_addToCartBtn) {
        _addToCartBtn = [UIButton buttonWithType:UIButtonTypeCustom];;
        _addToCartBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        _addToCartBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        if (APP_TYPE == 3) {
            _addToCartBtn.backgroundColor = [OSSVThemesColors col_000000:1];
            [_addToCartBtn setTitle:STLLocalizedString_(@"addToBag", nil) forState:UIControlStateNormal];

        } else {
            _addToCartBtn.backgroundColor = [OSSVThemesColors col_0D0D0D];
            [_addToCartBtn setTitle:[STLLocalizedString_(@"addToBag", nil) uppercaseString] forState:UIControlStateNormal];

        }
        [_addToCartBtn addTarget:self action:@selector(addToCartAction) forControlEvents:(UIControlEventTouchUpInside)];

    }
    return _addToCartBtn;
}


- (OSSVDetailsHeaderActivityStateView *)activityStateView {
    if (!_activityStateView) {
        _activityStateView = [[OSSVDetailsHeaderActivityStateView alloc] initWithFrame:CGRectZero showDirect:STLActivityDirectStyleNormal];
//        _activityStateView.samllImageShow = 12;
//        _activityStateView.fontSize = 9;
//        _activityStateView.flashImageSize = 12;
        _activityStateView.hidden = YES;
    }
    return _activityStateView;
}

- (OSSVDetailsActivityFullReductionView *)activityFullReductionView {
    if (!_activityFullReductionView) {
        _activityFullReductionView = [[OSSVDetailsActivityFullReductionView alloc] initWithFrame:CGRectZero];
    }
    return _activityFullReductionView;
}
@end
