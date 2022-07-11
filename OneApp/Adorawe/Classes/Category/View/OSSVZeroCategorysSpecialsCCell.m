//
//  OSSVZeroCategorysSpecialsCCell.m
// XStarlinkProject
//
//  Created by odd on 2020/9/15.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVZeroCategorysSpecialsCCell.h"
#import "STLCLineLabel.h"
#import "OSSVGoodssPricesView.h"
#import "OSSVZerosActitvitysProgresssView.h"

@interface OSSVZeroCategorysSpecialsCCell ()

@property (nonatomic, strong) YYAnimatedImageView         *contentImageView; // 内容图片
@property (nonatomic, strong) UIView                      *soldView;
//@property (nonatomic, strong) UIView                      *bottomBackView; // 底部背景View
@property (nonatomic, strong) UILabel                     *titLab;
@property (nonatomic, strong) UILabel                     *priceLabel; // 现价
@property (nonatomic, strong) STLCLineLabel               *originalPriceLabel; // 原价
@property (nonatomic, strong) UIButton                    *freeBtn; // 原价
@property (nonatomic, strong) OSSVZerosActitvitysProgresssView *progressView;
//活动水印标签
//@property (nonatomic, strong) YYAnimatedImageView           *activityTipImgView;
////折扣标 闪购
//@property (nonatomic, strong) GoodsDetailsHeaderActivityStateView   *activityStateView;
//@property (nonatomic, strong) OSSVGoodssPricesView     *priceView;


@end

@implementation OSSVZeroCategorysSpecialsCCell


+ (OSSVZeroCategorysSpecialsCCell *)categorySpecialCCellWithCollectionView:(UICollectionView *)collectionView andIndexPath:(NSIndexPath *)indexPath {
    //注册cell
    [collectionView registerClass:[OSSVZeroCategorysSpecialsCCell class] forCellWithReuseIdentifier:NSStringFromClass(OSSVZeroCategorysSpecialsCCell.class)];
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(OSSVZeroCategorysSpecialsCCell.class) forIndexPath:indexPath];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentView.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self.contentView addSubview:self.contentImageView];
        [self.contentImageView addSubview:self.soldView];
        [self.contentView addSubview:self.titLab];
        [self.contentView addSubview:self.priceLabel];
        [self.contentView addSubview:self.originalPriceLabel];
        [self.contentView addSubview:self.freeBtn];
        [self.contentView addSubview:self.progressView];

        [self.contentImageView mas_makeConstraints:^(MASConstraintMaker *make){
            make.leading.mas_equalTo(self.contentView.mas_leading).offset(8);
            make.top.mas_equalTo(self.contentView.mas_top).offset(8);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(-8);
            make.width.mas_equalTo(self.contentImageView.mas_height).multipliedBy(0.75);
        }];
        
        [self.soldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
        
        [self.titLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentImageView.mas_top);
            make.leading.mas_equalTo(self.contentImageView.mas_trailing).offset(8);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-8);
        }];
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentImageView.mas_trailing).offset(8);
            make.top.mas_equalTo(self.titLab.mas_bottom).offset(8);
            make.height.mas_equalTo(16);
            make.width.mas_equalTo(144);
            
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentImageView.mas_trailing).offset(8);
            make.bottom.mas_equalTo(self.contentImageView.mas_bottom);
        }];
        
        [self.originalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentImageView.mas_trailing).offset(8);
            make.bottom.mas_equalTo(self.priceLabel.mas_top).offset(2);
        }];
        
        [self.freeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-8);
            make.width.mas_equalTo(100);
            make.height.mas_equalTo(28);
            make.bottom.mas_equalTo(self.contentImageView.mas_bottom);
        }];
        
        
//        [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.contentImageView.mas_bottom);
//            make.bottom.leading.mas_equalTo(self.contentImageView);
//            make.height.mas_equalTo(19);
//        }];
//
//        [self.activityTipImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.trailing.equalTo(@0);
//            make.bottom.equalTo(self.contentImageView.mas_bottom);
//            make.height.equalTo(@(24*kScale_375));
//        }];
//
//        //闪购标签
//        [self.activityStateView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.equalTo(self.contentView.mas_leading);
//            make.top.equalTo(self.contentView.mas_top);
//        }];
        
        [self setShadowAndCornerCell];

    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.contentImageView yy_cancelCurrentImageRequest];
    self.contentImageView.image = nil;
}

+ (CGFloat)categorySpecialCCellRowHeightForListModel:(OSSVThemeZeroPrGoodsModel *)model {
//    if (model.goods_img_w == 0) {
//        return 0.01;
//    }
//    
//    //满减活动
//    CGFloat fullHeight = model.goodsListPriceHeight;
//    if (!(model.flash_sale && [model.flash_sale isOnlyFlashActivity]) && !model.hadHandlePriceHeight) {
//        model.hadHandlePriceHeight = YES;
//        CGFloat activityHeight = [OSSVGoodssPricesView activithHeight:model.tips_reduction contentWidth:kGoodsWidth];
//        fullHeight = [OSSVGoodssPricesView contentHeight:activityHeight];
//        model.goodsListPriceHeight = fullHeight;
//        model.goodsListFullActitityHeight = activityHeight;
//    }
//    if (model.goods_img_w == 0 || model.goods_img_h == 0) {
//        return kGoodsWidth * 4.0 / 3.0 + fullHeight;
//    }
//    return kGoodsWidth / model.goods_img_w * model.goods_img_h + fullHeight;
    return 128.0f;
}

#pragma mark - LazyLoad

- (void)setModel:(OSSVThemeZeroPrGoodsModel *)model {
    _model = model;

    [self.contentImageView yy_setImageWithURL:[NSURL URLWithString:STLToString(model.goods_img)]
                                  placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                      options:kNilOptions
                                     progress:nil
                                    transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                                return image;
                                            }
                                   completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
    }];
    
    self.titLab.text = STLToString(model.goods_title);
    self.originalPriceLabel.text = STLToString(model.shop_price_converted);
    self.priceLabel.text = STLToString(model.exchange_price_converted);
    
    NSString *str = nil;
    if (model.sold_out == 1) {
        self.soldView.hidden = NO;
        self.freeBtn.enabled = NO;
        [self.progressView setValue:100];
        str = [NSString stringWithFormat:@"%@ %@",  STLLocalizedString_(@"sold", nil), @"100%"];
        [self.progressView setTitStr:str];
    }else{
        self.soldView.hidden = YES;
        self.freeBtn.enabled = YES;
        //进度条规则更新,当剩余库存<10时，进度条固定98% 显示Only left 4；正常有库存时，显示60-98间的百分比进度条
        if (model.goods_number < 10) {
            [self.progressView setValue:98];
            str = [NSString stringWithFormat:@"%@ %ld", STLLocalizedString_(@"Left", nil), model.goods_number];
            [self.progressView setTitStr:str];
        }else{
            NSMutableString *skuStr =  [NSMutableString stringWithString:STLToString(model.goodsSn)];
            [skuStr substringToIndex:skuStr.length-3];
            
            NSInteger asciiSum = 0;
            for (int i = 0; i<skuStr.length; i++) {
                asciiSum += [skuStr characterAtIndex:i];
            }
            NSInteger bili = (asciiSum % 38) + 60;
            [self.progressView setValue:bili];
            str = [NSString stringWithFormat:@"%@ %ld%@",  STLLocalizedString_(@"sold", nil), bili, @"%"];
            [self.progressView setTitStr:str];
        }
    }

}

- (void)freeBtnDidSelected:(UIButton *)sender{
    if (self.getFreeblock) {
        self.getFreeblock(_model);
    }
}


- (YYAnimatedImageView *)contentImageView {
    if (!_contentImageView) {
        _contentImageView = [[YYAnimatedImageView alloc] init];
        _contentImageView.userInteractionEnabled = YES;
        /**
         此处是否后期需要调整呢？目前此处是这样理解和处理的
         UIViewContentModeCenter是为了让 placeholder 的正常显示，
         clipsToBounds = YES，为了防止图片溢出
         但是，当图片的宽或者高比frame的宽高更小的时候，可能出现空白的情况。
         背景颜色，暂时这样设置，后期可以删掉
         
         */
        _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
        _contentImageView.clipsToBounds = YES;
        _contentImageView.backgroundColor = [UIColor whiteColor];
    }
    return _contentImageView;
}


//- (UIView *)bottomBackView {
//    if (!_bottomBackView) {
//        _bottomBackView = [[UIView alloc] init];
//        _bottomBackView.backgroundColor = [UIColor whiteColor];
//    }
//    return _bottomBackView;
//}

- (UILabel *)titLab{
    if (!_titLab) {
        _titLab = [UILabel new];
        _titLab.font = FontWithSize(12);
        _titLab.numberOfLines = 2;
        _titLab.textColor = OSSVThemesColors.col_6C6C6C;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titLab.textAlignment = NSTextAlignmentRight;
        }
    }
    return _titLab;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _priceLabel.font = [UIFont boldSystemFontOfSize:16];
        _priceLabel.textColor = OSSVThemesColors.col_B62B21;
        _priceLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _priceLabel;
}

- (STLCLineLabel *)originalPriceLabel {
    if (!_originalPriceLabel) {
        _originalPriceLabel = [[STLCLineLabel alloc] init];
        _originalPriceLabel.font = [UIFont systemFontOfSize:10];
        _originalPriceLabel.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _originalPriceLabel.textColor = [OSSVThemesColors col_999999];
        _originalPriceLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _originalPriceLabel;
}

- (UIButton *)freeBtn{
    if (!_freeBtn) {
        _freeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_freeBtn setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        [_freeBtn setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateDisabled];
        _freeBtn.titleLabel.font = FontWithSize(12);
        [_freeBtn setTitle:STLLocalizedString_(@"getFree", nil) forState:UIControlStateNormal];
        [_freeBtn setTitle:STLLocalizedString_(@"soldOut", nil) forState:UIControlStateDisabled];
        [_freeBtn setBackgroundImage:[UIImage yy_imageWithColor:OSSVThemesColors.col_CCCCCC] forState:UIControlStateDisabled];
        [_freeBtn setBackgroundImage:[UIImage yy_imageWithColor:OSSVThemesColors.col_0D0D0D] forState:UIControlStateNormal];
        
        [_freeBtn addTarget:self action:@selector(freeBtnDidSelected:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _freeBtn;
}

- (UIView *)soldView{
    if (!_soldView) {
        _soldView = [UIView new];
        _soldView.backgroundColor = [UIColor colorWithRed:0.051 green:0.051 blue:0.051 alpha:0.3];
        UIImageView *imgV = [UIImageView new];
        imgV.image = [UIImage imageNamed:@"zero_hangers"];
        UILabel *lab = [UILabel new];
        lab.text = STLLocalizedString_(@"soldOut", nil);
        lab.textColor = [UIColor whiteColor];
        lab.font = FontWithSize(12);
        lab.textAlignment = NSTextAlignmentCenter;
        
        [_soldView addSubview:imgV];
        [_soldView addSubview:lab];
        
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_soldView.mas_centerX);
            make.centerY.mas_equalTo(_soldView.mas_centerY).offset(-20);
        }];
        
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_soldView.mas_centerX);
            make.top.mas_equalTo(imgV.mas_bottom).offset(2);
            make.leading.trailing.mas_equalTo(_soldView);
        }];
        _soldView.hidden = YES;
    }
    return _soldView;
}

- (OSSVZerosActitvitysProgresssView *)progressView{
    if (!_progressView) {
        _progressView = [[OSSVZerosActitvitysProgresssView alloc] initWithFrame:CGRectZero];
    }
    return _progressView;
}


@end
