//
//  ZFPriceView.m
//  ZZZZZ
//
//  Created by YW on 14/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFPriceView.h"
#import "ZFBaseGoodsModel.h"
#import "ZFInitViewProtocol.h"
#import "ZFLabel.h"
#import "ZFCellHeightManager.h"
#import "ZFThemeManager.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "BigClickAreaButton.h"
#import "Masonry.h"
#import "AccountManager.h"
#import "ZFGoodsListColorBlockView.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "ZFGoodsModel.h"
#import "YWCFunctionTool.h"
#import "UIImage+ZFExtended.h"

@interface ZFPriceView ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel                               *shopLabel;
@property (nonatomic, strong) UIView                                *tagView;
@property (nonatomic, strong) UILabel                               *soldoutLabel; // 失效商品显示Sold out
@property (nonatomic, strong) BigClickAreaButton                    *collectionButton;
@property (nonatomic, strong) CABasicAnimation                      *scaleAnimation;
@property (nonatomic, strong) UILabel *installmentLabel;  // 分期付款提示语
// 色块选择view
@property (nonatomic, strong) ZFGoodsListColorBlockView             *colorBlockView;
@property (nonatomic, strong) MASConstraint                         *colorBlockTopHeightCons;
@property (nonatomic, strong) MASConstraint                         *colorBlockHeightCons;
@end

@implementation ZFPriceView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR(255, 255, 255, 1.0);
    [self addSubview:self.shopLabel];
    [self addSubview:self.tagView];
    [self addSubview:self.soldoutLabel];
    [self addSubview:self.installmentLabel];
    [self addSubview:self.colorBlockView];
}

- (void)zfAutoLayoutView {
    [self.shopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.offset(0);
        make.top.offset(0);
    }];

//    [self.marketLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(self.shopLabel.mas_trailing).offset(4);
//        make.bottom.equalTo(self.shopLabel);
//    }];

    CGFloat cellWidth = floor((KScreenWidth - 36) * 0.5);
    CGFloat colorBlockCellWidth = floor((cellWidth-12*4-15) / 4.5);
    [self.colorBlockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        self.colorBlockTopHeightCons = make.top.mas_equalTo(self.shopLabel.mas_bottom).offset(8);
        self.colorBlockHeightCons = make.height.mas_equalTo(colorBlockCellWidth);
    }];
    
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.shopLabel);
        make.top.mas_equalTo(self.colorBlockView.mas_bottom).offset(8);
//        make.top.mas_equalTo(self.shopLabel.mas_bottom).offset(8);
//        make.bottom.offset(0).priorityLow();
        make.height.mas_equalTo(40);
    }];
    
    [self.soldoutLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.mas_leading).offset(0);
        make.top.equalTo(self.mas_top).offset(0);;
    }];
    
    [self.installmentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.top.mas_equalTo(self.colorBlockView.mas_bottom).offset(8);
//        make.top.mas_equalTo(self.shopLabel.mas_bottom).offset(8);
    }];
}

#pragma mark - Public method
- (void)clearAllData {
    self.shopLabel.text = nil;
    [self.colorBlockView.colorBlockCollectionView reloadData];
//    self.marketLabel.text = nil;
    self.installmentLabel.hidden = YES;
    self.installmentLabel.text = nil;
    [self.tagView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void)setIsInvalidGoods:(BOOL)isInvalidGoods
{
    _isInvalidGoods = isInvalidGoods;
    // 判断为失效就显示sold out 标签
    if (isInvalidGoods) {
        self.shopLabel.hidden = YES;
//        self.marketLabel.hidden = YES;
        self.soldoutLabel.hidden = NO;
    } else {
        self.shopLabel.hidden = NO;
//        self.marketLabel.hidden = NO;
        self.soldoutLabel.hidden = YES;
    }
}

#pragma mark - Setter
- (void)setModel:(ZFBaseGoodsModel *)model {
    _model = model;
    // 色块约束
    if (model.showColorBlock && model.groupGoodsList.count > 1) {
        CGFloat cellWidth = floor((KScreenWidth - 36) * 0.5);
        CGFloat colorBlockCellWidth = floor((cellWidth-12*4-15) / 4.5);
        self.colorBlockHeightCons.mas_equalTo(colorBlockCellWidth);
        self.colorBlockTopHeightCons.mas_equalTo(8);
    } else {
        self.colorBlockHeightCons.mas_equalTo(0);
        self.colorBlockTopHeightCons.mas_equalTo(0);
    }

    if ([_model showMarketPrice]) {
        self.shopLabel.text = nil;
        self.shopLabel.attributedText = model.RRPAttributedPriceString;
    } else {
        self.shopLabel.attributedText = nil;
        self.shopLabel.text = [ExchangeManager transforPrice:model.shopPrice];
    }
    
//    self.shopLabel.text = text;//[ExchangeManager transforPrice:model.shopPrice];
    
//    if (!model.isHideMarketPrice) {
////        NSString *marketPrice = [NSString stringWithFormat:@"%.2f",[_model.marketPrice floatValue] * [ExchangeManager localRate]];
//        NSString *marketPrice = [ExchangeManager transPurePriceforPrice:_model.marketPrice];
//        NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
//        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc] initWithString:marketPrice attributes:attribtDic];
//        self.marketLabel.attributedText = attribtStr;
//    }
    
    if (model.isShowCollectButton) {
        [self addSubview:self.collectionButton];
        [self.collectionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.trailing.equalTo(self).offset(-12);
            make.size.mas_equalTo(CGSizeMake(22, 22));
        }];
        self.collectionButton.selected = [model.isCollect boolValue];
    }
    
    if (model.tagsArray.count < 1) return;
    
    if (model.isInstallment) {
        // 分期付款   其他图标均隐藏
        self.installmentLabel.hidden = NO;
        self.installmentLabel.text = [NSString stringWithFormat:@"%@ x %@ %@", model.instalmentModel.instalments, [ExchangeManager transforPrice:model.instalmentModel.per], ZFToString(model.instalmentModel.installment_str)];
    } else {
        self.installmentLabel.hidden = YES;
        self.installmentLabel.text = nil;
        
        BOOL isNewLine = [[ZFCellHeightManager shareManager] isNewLineWithModelHash:model.tagsArray.hash];
        
        NSInteger count = model.tagsArray.count;
        CGFloat tagVerticalMargin       = 4.0f;
        CGFloat tagHorizontalMargin     = 4.0f;
        CGFloat tagHeight               = 16.0f;
        ZFLabel *lastTagLabel = nil;
        
        for (int i = 0; i < count; ++i) {
            ZFGoodsTagModel *tagModel = model.tagsArray[i];
            ZFLabel *tagLabel =  [self configureTagLabelWithText:tagModel.tagTitle color:tagModel.tagColor];
            [self.tagView addSubview:tagLabel];
            [tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(tagHeight);
                if (i == 0) {
                    make.leading.top.mas_equalTo(self.tagView);
                } else {
                    if (i == count - 1 && isNewLine) {
                        make.leading.mas_equalTo(self.tagView);
                        make.top.equalTo(lastTagLabel.mas_bottom).offset(tagVerticalMargin);
                    } else {
                        make.top.mas_equalTo(self.tagView);
                        make.leading.mas_equalTo(lastTagLabel.mas_trailing).offset(tagHorizontalMargin);
                        make.trailing.lessThanOrEqualTo(self.tagView); // 右边不超出
                    }
                }
            }];
            lastTagLabel = tagLabel;
        }
    }
}

- (void)setGoodsModel:(ZFGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    self.colorBlockView.goodsModel = goodsModel;
    [self layoutIfNeeded];
}

- (void)setIsPriceHighlight:(BOOL)isPriceHighlight {
    _isPriceHighlight = isPriceHighlight;
    self.shopLabel.textColor = isPriceHighlight ? ZFC0xFE5269() : ZFC0x2D2D2D();
}

#pragma mark - Private method
- (ZFLabel *)configureTagLabelWithText:(NSString *)text color:(NSString *)color {
    ZFLabel *tagLabel = [[ZFLabel alloc] init];
    tagLabel.textColor = [UIColor colorWithHexString:color];
    tagLabel.font = [UIFont systemFontOfSize:10];
    tagLabel.textAlignment = NSTextAlignmentCenter;
    tagLabel.backgroundColor = ZFCOLOR(255, 255, 255, 1);
    tagLabel.edgeInsets = UIEdgeInsetsMake(2, 4, 2, 4);
    tagLabel.text = text;
    tagLabel.layer.borderColor = [UIColor colorWithHexString:color].CGColor;
    tagLabel.layer.borderWidth = 1.0f;
    return tagLabel;
}

#pragma mark - action methods
- (void)collectionButtonAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    [self.collectionButton.layer addAnimation:self.scaleAnimation forKey:@"scaleAnimation"];
    if (self.CollectCompletionHandler) {
        self.CollectCompletionHandler(sender.selected);
    }
}

#pragma mark - Getter
- (UILabel *)shopLabel {
    if (!_shopLabel) {
        _shopLabel = [[UILabel alloc] init];
        _shopLabel.textColor = ZFCOLOR_BLACK;
        _shopLabel.backgroundColor = ZFCOLOR_WHITE;
        _shopLabel.font = [UIFont boldSystemFontOfSize:16];
        _shopLabel.numberOfLines = 0;
    }
    return _shopLabel;
}

- (UILabel *)installmentLabel {
    if (!_installmentLabel) {
        _installmentLabel = [[UILabel alloc] init];
        _installmentLabel.textColor = ZFCOLOR(102, 102, 102, 1);
        _installmentLabel.font = [UIFont systemFontOfSize:12];
        _installmentLabel.hidden = YES;
    }
    return _installmentLabel;
}

- (UIView *)tagView {
    if (!_tagView) {
        _tagView = [[UIView alloc] init];
        _tagView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _tagView;
}

- (BigClickAreaButton *)collectionButton {
    if (!_collectionButton) {
        _collectionButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        [_collectionButton setImage:[UIImage imageNamed:@"GoodsDetail_Uncollect"] forState:UIControlStateNormal];
        [_collectionButton setImage:[[UIImage imageNamed:@"GoodsDetail_collect"] imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
        [_collectionButton addTarget:self action:@selector(collectionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _collectionButton.clickAreaRadious = 64;
        _collectionButton.backgroundColor = ZFCOLOR_WHITE;
    }
    return _collectionButton;
}

- (CABasicAnimation *)scaleAnimation {
    if (!_scaleAnimation) {
        _scaleAnimation = [CABasicAnimation animation];
        _scaleAnimation.keyPath = @"transform.scale";
        _scaleAnimation.fromValue = @(0.6);
        _scaleAnimation.toValue = @(1.2);
        _scaleAnimation.duration = 0.35;
    }
    return _scaleAnimation;
}

- (UILabel *)soldoutLabel {
    if (!_soldoutLabel) {
        _soldoutLabel = [[UILabel alloc] init];
        _soldoutLabel.textColor       = ZFCOLOR(45, 45, 45, 1);
        _soldoutLabel.font            = [UIFont systemFontOfSize:16.0f];
        _soldoutLabel.hidden          = YES;
        _soldoutLabel.text            = ZFLocalizedString(@"Detail_Product_SoldOut", nil);
    }
    return _soldoutLabel;
}

- (ZFGoodsListColorBlockView *)colorBlockView {
    if (!_colorBlockView) {
        _colorBlockView = [[ZFGoodsListColorBlockView alloc] init];
        @weakify(self)
        _colorBlockView.colorBlockClick = ^(NSInteger index) {
            @strongify(self)
            // 色块选择
            if (self.colorBlockClick) {
                self.colorBlockClick(index);
            }
        };
    }
    return _colorBlockView;
}

@end
