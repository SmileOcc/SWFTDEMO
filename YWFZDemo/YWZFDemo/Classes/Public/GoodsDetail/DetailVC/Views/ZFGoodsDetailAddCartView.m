//
//  ZFGoodsDetailAddCartView.m
//  ZZZZZ
//
//  Created by YW on 2017/11/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsDetailAddCartView.h"
#import "ZFInitViewProtocol.h"
#import "UIView+ZFBadge.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "ZFPubilcKeyDefiner.h"
#import "ZFGoodsDetailGroupBuyModel.h"
#import "ExchangeManager.h"
#import "Constants.h"
#import "NSString+Extended.h"
#import "ZFFrameDefiner.h"
#import "YWCFunctionTool.h"
#import "ZFBTSManager.h"

#define kCarBtnWidth        (100)
#define kCarBtnHeight       (40)

@interface ZFGoodsDetailAddCartView() <ZFInitViewProtocol>
@property (nonatomic, strong) UIView            *lineView;
@property (nonatomic, strong) UIButton          *addCartButton;
@property (nonatomic, strong) UILabel           *outOfStockLabel;
@end

@implementation ZFGoodsDetailAddCartView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addNotification];
        [self changeCartNumberInfo];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCartNumberInfo) name:kCartNotification object:nil];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self addDropShadowWithOffset:CGSizeMake(0, -2)
                           radius:2
                            color:[UIColor blackColor]
                          opacity:0.1];
}

#pragma mark - interface methods
- (void)changeCartNumberInfo {
    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
    [self.cartButton showShoppingCarsBageValue:[badgeNum integerValue]];
}

#pragma mark - action methods
- (void)buttonAction:(UIButton *)sender {
    if (sender.tag == 2019) return;
    
    if (self.goodsDetailBottomViewBlock) {
        self.goodsDetailBottomViewBlock(sender.tag);
    }
}

#pragma mark -<ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.outOfStockLabel];
    [self addSubview:self.cartButton];
    [self addSubview:self.addCartButton];
    [self addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.outOfStockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(0);
    }];
    
    CGFloat carBtnWidth = (KScreenWidth - (kCarBtnWidth + 11 + 16));
    
    [self.addCartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.outOfStockLabel.mas_bottom).offset(8);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-16);
        make.size.mas_equalTo(CGSizeMake(carBtnWidth, kCarBtnHeight));
        make.bottom.mas_equalTo(self.mas_bottom).offset(-(IPHONE_X_5_15 ? 34 : 8));
    }];
    
    [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.addCartButton.mas_centerY);
        make.leading.mas_equalTo(self);
        make.trailing.mas_equalTo(self.addCartButton.mas_leading);
        make.height.mas_equalTo(kCarBtnHeight);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - setter

- (void)setModel:(GoodsDetailModel *)model {
    _model = model;
    CGFloat tipHeight = 0.0;
    
    // CDN没回来之前先不显示无库存提示
    if ((ZFIsEmptyString(model.manzeng_id)
         && [AccountManager sharedManager].appShouldRequestCdn)
        && !model.detailCdnPortSuccess) {
        
        self.addCartButton.tag = GoodsDetailActionA_addCartType;
        [self.addCartButton setTitle:ZFLocalizedString(@"Detail_Product_AddToBag", nil) forState:UIControlStateNormal];
        self.outOfStockLabel.hidden = YES;
        
    } else {
        //下架，没有货 -> V4.6.0 提示找相似
        if (![_model.is_on_sale boolValue] || _model.goods_number <= 0) {
            self.addCartButton.tag = GoodsDetailActionA_similarType;
            NSString *title = ZFLocalizedString(@"cart_unline_findsimilar_tag", nil);
            [self.addCartButton setTitle:[title uppercaseString] forState:UIControlStateNormal];
            
            self.outOfStockLabel.hidden = NO;
            if (_model.goods_number <= 0) {
                self.outOfStockLabel.text = ZFLocalizedString(@"Detail_Product_OutOfStock", nil);
            } else {
                self.outOfStockLabel.text = ZFLocalizedString(@"Detail_Product_SoldOut", nil);
            }
            tipHeight = 32.0;
            
        } else {
            self.addCartButton.tag = GoodsDetailActionA_addCartType;
            [self.addCartButton setTitle:ZFLocalizedString(@"Detail_Product_AddToBag", nil) forState:UIControlStateNormal];
            self.outOfStockLabel.hidden = YES;
        }
    }
    [self.outOfStockLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(tipHeight);
    }];
    // 刷新购物车数量
    [self changeCartNumberInfo];
    
    //V5.5.0商详优化Bts实验
    ZFBTSModel *btsModel = [ZFBTSManager getBtsModel:kZFBtsIosxaddbag defaultPolicy:kZFBts_A];
    BOOL hideCartBtn = ![btsModel.policy isEqualToString:kZFBts_A];
    self.cartButton.hidden = hideCartBtn;
    
    CGFloat carBtnWidth = hideCartBtn ? (KScreenWidth - 16 * 2) : (KScreenWidth - (kCarBtnWidth + 11 + 16));
    [self.addCartButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(carBtnWidth, kCarBtnHeight));
    }];
}

#pragma mark - getter
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    }
    return _lineView;
}

- (UILabel *)outOfStockLabel {
    if (!_outOfStockLabel) {
        _outOfStockLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _outOfStockLabel.textAlignment = NSTextAlignmentCenter;
        _outOfStockLabel.backgroundColor = ZFCOLOR(204, 204, 204, 1);
        _outOfStockLabel.textColor = ZFCOLOR_WHITE;
        _outOfStockLabel.font = ZFFontSystemSize(14);
        _outOfStockLabel.text = ZFLocalizedString(@"Detail_Product_OutOfStock", nil);
    }
    return _outOfStockLabel;
}

- (UIButton *)cartButton {
    if (!_cartButton) {
        _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cartButton setImage:[UIImage imageNamed:@"public_bag"] forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        _cartButton.tag = GoodsDetailActionA_pushCarType;
    }
    return _cartButton;
}

- (UIButton *)addCartButton {
    if (!_addCartButton) {
        _addCartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addCartButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_addCartButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        [_addCartButton setBackgroundColor:ColorHex_Alpha(0xcccccc, 1) forState:UIControlStateDisabled];
        
        [_addCartButton setTitle:ZFLocalizedString(@"Detail_Product_AddToBag", nil) forState:UIControlStateNormal];
        [_addCartButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        [_addCartButton setTitle:ZFLocalizedString(@"Detail_Product_OutOfStock", nil) forState:UIControlStateDisabled];
        [_addCartButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateDisabled];
        [_addCartButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        _addCartButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _addCartButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _addCartButton.layer.cornerRadius = 3;
        _addCartButton.layer.masksToBounds = YES;
        _addCartButton.tag = 2019;
    }
    return _addCartButton;
}
@end
