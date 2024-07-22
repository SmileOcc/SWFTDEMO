//
//  ZFCMSCouponItemBaseView.m
//  ZZZZZ
//
//  Created by YW on 2019/10/31.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSCouponItemView.h"
#import "YYText.h"
#import "NSStringUtils.h"
#import <YYWebImage/YYWebImage.h>
#import "UIImage+ZFExtended.h"
#import "ExchangeManager.h"
#import "AccountManager.h"
#import "UIColor+ExTypeChange.h"
#import "NSStringUtils.h"

@interface ZFCMSCouponItemView()

@end

@implementation ZFCMSCouponItemView
@synthesize itemModel = _itemModel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.couponState = ZFCMSCouponBaseStateUnknow;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.descContentView];
        [self addSubview:self.lineView];
        [self addSubview:self.whiteCircleViewOne];
        [self addSubview:self.whiteCircleViewTwo];
        [self.descContentView addSubview:self.couponTitleLabel];
        [self.descContentView addSubview:self.couponDescLabel];
        
        [self addSubview:self.bgImageView];
        [self addSubview:self.horizontalProgressView];
        [self addSubview:self.circleProgressView];
        [self addSubview:self.progressLabel];
        [self addSubview:self.numsPercentageLabel];
        [self addSubview:self.couponStateImageView];
        [self addSubview:self.couponStateContentView];
        [self addSubview:self.couponStateButton];
        
        [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
        }];
        
        [self.couponStateImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self).offset(-6);
            make.top.mas_equalTo(self.mas_top).offset(-6);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        self.couponStateImageView.transform = CGAffineTransformMakeRotation(-M_PI_4);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)actionTap:(UITapGestureRecognizer *)tap {
    if (self.tapBlock) {
        self.tapBlock();
    }
}

/// 赋值
- (void)updateItem:(ZFCMSItemModel *)itemModel sectionModel:(ZFCMSSectionModel *)sectionModel contentSize:(CGSize )contentSize {
        
    if (CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
        self.contentSize = !CGSizeEqualToSize(contentSize, CGSizeZero) ? contentSize : self.frame.size;
    }
    
    self.sectionModel = sectionModel;
    self.itemModel = itemModel;
    [self createLineViewUpdate:NO];
    [self updateViewState:itemModel];
}

- (void)updateViewState:(ZFCMSItemModel *)itemModel {
    
    ZFCMSCouponState couponState = ZFCMSCouponStateNoCounts;
    if (itemModel.couponModel.couponState <= 1) {
        couponState = ZFCMSCouponStateCanReceive;
    } else if(itemModel.couponModel.couponState == 2){
        couponState = ZFCMSCouponStateHadReceive;
    }

    
    if (ZFIsEmptyString(itemModel.couponModel.idx) || ([itemModel.couponModel.left_rate integerValue] <= 0 && [self.itemModel.couponModel.is_no_limit isEqualToString:@"1"])) {
        couponState = ZFCMSCouponStateNoCounts;
    }
    
    // 未登录，有数量，都可以领取
    if((![AccountManager sharedManager].isSignIn && [itemModel.couponModel.left_rate integerValue] > 0) || [self.itemModel.couponModel.is_no_limit isEqualToString:@"0"]) {
        couponState = ZFCMSCouponStateCanReceive;
    }
    
    [self updateBgState:couponState iamgeUrl:self.itemModel.image];
    [self updateTitleState:couponState itemMode:itemModel];
    [self updateDescLabState:couponState];
    [self updateCountsLefts:itemModel];
    
    // 显示处理
    [self progressState:couponState];
    [self updateProgress:itemModel];

    [self couponButtonState:couponState];
    [self couponStateImageState:couponState];
    
    if (self.sectionModel.remain == 0 || [self.itemModel.couponModel.is_no_limit isEqualToString:@"0"]) {
        self.progressLabel.hidden = YES;
        self.circleProgressView.hidden = YES;
        self.horizontalProgressView.percentageLabel.hidden = YES;
        self.horizontalProgressView.hidden = YES;
        YWLog(@"---- hide: %@",self.itemModel.name);

    } else {
        self.progressLabel.hidden = NO;
        self.circleProgressView.hidden = NO;
        self.horizontalProgressView.percentageLabel.hidden = NO;
        self.horizontalProgressView.hidden = NO;
        YWLog(@"---- show: %@",self.itemModel.name);
    }
    
    self.bgImageView.hidden = YES;
    self.whiteCircleViewOne.hidden = NO;
    self.whiteCircleViewTwo.hidden = NO;
    
    if (self.sectionModel.selection_style == 1) {
        if (!ZFIsEmptyString(self.itemModel.image)) {
            self.bgImageView.hidden = NO;
            self.whiteCircleViewOne.hidden = YES;
            self.whiteCircleViewTwo.hidden = YES;
        }
    }
    
    [self updateViewConstraints];
}

- (void)updateViewConstraints {
    
}

- (void)updateProgress:(ZFCMSItemModel *)itemModel {
    
    CGFloat percentate =  (1.0 - [itemModel.couponModel.left_rate floatValue] / 100.0);
    if (self.circleProgressView.superview) {
        self.circleProgressView.progress = percentate;
        
    } else if(self.horizontalProgressView.superview) {
        [self.horizontalProgressView updateProgressMax:1.0 min:percentate];
    }
}

/// 进度条及数量文案都读配置
- (void)updateCountsLefts:(ZFCMSItemModel *)itemModel {
    
    NSString *percent = ZFToString(itemModel.couponModel.left_rate);
    if (ZFIsEmptyString(percent)) {
        percent = @"0";
    }
    NSString *content = [NSString stringWithFormat:@"%@ %%%@",percent,ZFLocalizedString(@"Hom_Coupon_Left", nil)];
    
    if (self.circleProgressView.superview) {
        
        if ([self isKindOfClass:[ZFCMSCouponBigItemBaseView class]]) {
            content = [NSString stringWithFormat:@"%@%%\n%@",percent,ZFLocalizedString(@"Hom_Coupon_Left", nil)];
        }
        
        NSMutableAttributedString *attrContent = [[NSMutableAttributedString alloc] initWithString:content];
        
        if (self.couponState == ZFCMSCouponBaseStateHighlighted) {
            
            [attrContent addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0] range:NSMakeRange(0, percent.length)];
            if (!ZFIsEmptyString(self.sectionModel.attributes.range_text_color)) {
                self.progressLabel.textColor = [UIColor colorWithHexString:self.sectionModel.attributes.range_text_color];
            } else {
                self.progressLabel.textColor = ColorHex_Alpha(0x5F1818, 1);
            }
            
        } else {
            [attrContent addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12.0] range:NSMakeRange(0, percent.length)];
            if (!ZFIsEmptyString(self.sectionModel.attributes.cannot_text_color)) {
                self.progressLabel.textColor = [UIColor colorWithHexString:self.sectionModel.attributes.cannot_text_color];

            } else {
                self.progressLabel.textColor = ColorHex_Alpha(0x8E8E8E, 1);
            }
        }

        self.progressLabel.attributedText = attrContent;
        
    } else if(self.horizontalProgressView.superview) {
        
        if (self.couponState == ZFCMSCouponBaseStateHighlighted) {
            
            if (!ZFIsEmptyString(self.sectionModel.attributes.range_text_color)) {
                self.horizontalProgressView.textColor = [UIColor colorWithHexString:self.sectionModel.attributes.range_text_color];
            } else {
                self.horizontalProgressView.textColor = ColorHex_Alpha(0x5F1818, 1);
            }
            
        } else {
            if (!ZFIsEmptyString(self.sectionModel.attributes.cannot_text_color)) {
                self.horizontalProgressView.textColor = [UIColor colorWithHexString:self.sectionModel.attributes.cannot_text_color];

            } else {
                self.horizontalProgressView.textColor = ColorHex_Alpha(0x8E8E8E, 1);
            }
        }
        self.horizontalProgressView.percentageLabel.text = content;
    }
}


/// 划线
- (void)createLineViewUpdate:(BOOL)update {
    
}

/// 内容标题
- (void)updateTitleState:(ZFCMSCouponState)couponState itemMode:(ZFCMSItemModel *)itemModel {
    
    UIColor *color = ColorHex_Alpha(0x8E8E8E, 1.0);
    if (couponState <= ZFCMSCouponStateCanReceive || couponState ==ZFCMSCouponStateHadReceive) {
        color = ColorHex_Alpha(0x5F1818, 1.0);
    }
    
    NSString *currency = ZFToString(self.itemModel.couponModel.currency);
    NSString *youhuilv = ZFToString(self.itemModel.couponModel.youhuilv);
    NSString *fangshi = ZFToString(self.itemModel.couponModel.fangshi);
    NSString *realyCurrency = ZFToString([ExchangeManager symbolOfCurrency:currency]);

    
    //本地货币金额符号
    NSString *localTypeCurrency = [ExchangeManager localTypeCurrency];
    //本地货币名称
    NSString *localCurrencyName = [ExchangeManager localCurrencyName];

    RateModel *localCurrencyRateModel = [ExchangeManager rateModelOfCurrency:localTypeCurrency];
    
    if (self.currencySmallFontSize <= 0) {
        self.currencySmallFontSize = 10;
    }
    if (self.titleMaxFontSize <= 0) {
        self.titleMaxFontSize = 28;
    }
    
    BOOL isMatch = [currency isEqualToString:localCurrencyName] ? YES : NO;
    // fangshi=1 百分比 2 满减
    __block NSMutableArray *resultsArray = [[NSMutableArray alloc] init];
    NSArray *youhuilvArrays = [youhuilv componentsSeparatedByString:@","];
    
    [youhuilvArrays enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //示例： 12-10
        if ([obj containsString:@"-"]) {
            
            NSArray *subArrays = [obj componentsSeparatedByString:@"-"];
            NSString *firstString = @"";
            NSString *lastString = [NSString stringWithFormat:@"%@%%",subArrays.lastObject];
            
            if(isMatch) {
                
//                BOOL isUpFetch = [ExchangeManager isNeedUpFetch:localCurrencyRateModel];
//                firstString = [ExchangeManager currencyIsRightOrLeftWithRateModel:realyCurrency price:subArrays.firstObject isUpFetch:isUpFetch isSpace:NO isAppendCurrency:YES];
                
                firstString = [ExchangeManager transPurePriceForCurrencyPrice:subArrays.firstObject purposeCurrency:realyCurrency priceType:PriceType_Coupon isSpace:NO isAppendCurrency:YES];

            } else {
                firstString = [ExchangeManager transPurePriceForCurrencyPrice:subArrays.firstObject sourceCurrency:currency purposeCurrency:localTypeCurrency priceType:PriceType_Coupon isSpace:NO isAppendCurrency:YES];
            }
            
            if (![fangshi isEqualToString:@"1"]) {//满减
                if (isMatch) {
                    
//                    BOOL isUpFetch = [ExchangeManager isNeedUpFetch:localCurrencyRateModel];
//                    lastString = [ExchangeManager currencyIsRightOrLeftWithRateModel:realyCurrency price:subArrays.lastObject isUpFetch:isUpFetch isSpace:NO isAppendCurrency:YES];
                    
                    lastString = [ExchangeManager transPurePriceForCurrencyPrice:subArrays.lastObject purposeCurrency:realyCurrency priceType:PriceType_Coupon isSpace:NO isAppendCurrency:YES];
                    
                } else {
                    lastString = [ExchangeManager transPurePriceForCurrencyPrice:subArrays.lastObject sourceCurrency:currency purposeCurrency:localTypeCurrency priceType:PriceType_Coupon isSpace:NO isAppendCurrency:YES];
                }
            }
            
            firstString = [firstString stringByAppendingFormat:@"-%@",lastString];
            [resultsArray addObject:firstString];
            
        } else {//示例：12
            NSString *firstString = [NSString stringWithFormat:@"%@%%",obj];
            if (![fangshi isEqualToString:@"1"]) {
                if(isMatch) {
                    
//                    BOOL isUpFetch = [ExchangeManager isNeedUpFetch:localCurrencyRateModel];
//                    firstString = [ExchangeManager currencyIsRightOrLeftWithRateModel:realyCurrency price:obj isUpFetch:isUpFetch isSpace:NO isAppendCurrency:YES];
                    
                    firstString = [ExchangeManager transPurePriceForCurrencyPrice:obj purposeCurrency:realyCurrency priceType:PriceType_Coupon isSpace:NO isAppendCurrency:YES];
                    
                } else {
                    firstString = [ExchangeManager transPurePriceForCurrencyPrice:obj sourceCurrency:currency purposeCurrency:localTypeCurrency priceType:PriceType_Coupon isSpace:NO isAppendCurrency:YES];
                }
            }
            [resultsArray addObject:firstString];
        }
    }];
    
    
    NSString *resultString = @"";
    if (resultsArray.count > 1) {
        resultString = [resultsArray componentsJoinedByString:@","];
    } else {
        resultString = resultsArray.firstObject;
    }
    
    NSString *content = resultString;
    
    NSMutableAttributedString *attrContent = [[NSMutableAttributedString alloc] initWithString:content];
    
    NSInteger lengt = localTypeCurrency.length;
    
    
    if (lengt > 0 && !ZFIsEmptyString(resultString)) {
        NSArray *curenyRanges = [NSStringUtils getRangeStr:resultString findText:localTypeCurrency];
        
        [curenyRanges enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSInteger start = [obj integerValue];
            
            [attrContent addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(start, lengt)];
            [attrContent addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.currencySmallFontSize] range:NSMakeRange(start, lengt)];
        }];
    }
   
    self.couponTitleLabel.attributedText = attrContent;
}


/// 优惠券描述
- (void)updateDescLabState:(ZFCMSCouponState)couponState {
    
    if (couponState <= ZFCMSCouponStateCanReceive || couponState ==ZFCMSCouponStateHadReceive) {
        self.couponDescLabel.textColor = ColorHex_Alpha(0xCA7373, 1.0);
    } else {
        self.couponDescLabel.textColor = ColorHex_Alpha(0xB4B4B4, 1.0);
    }
    
    self.couponDescLabel.text = ZFToString(self.itemModel.couponModel.use_range);
}

/// 进度条状态
- (void)progressState:(ZFCMSCouponState)couponState {
    
    if (self.circleProgressView.superview) {
        self.circleProgressView.fillColor = [self progressColor:couponState isTrack:NO];
        self.circleProgressView.mainColor =  [self progressColor:couponState isTrack:YES];
    }
    if (self.horizontalProgressView.superview) {
        self.horizontalProgressView.trackColor = [self progressColor:couponState isTrack:YES];
        self.horizontalProgressView.backColor = [self progressColor:couponState isTrack:NO];
        self.horizontalProgressView.pathLineColor = ColorHex_Alpha(0xFFFFFF, 0.15);
    }
}

/// 进度条及数量文案都读配置

- (UIColor *)progressColor:(ZFCMSCouponState)couponState isTrack:(BOOL)isTrack {
    if (couponState <= ZFCMSCouponStateCanReceive || couponState ==ZFCMSCouponStateHadReceive) {
    
        if (isTrack) {
            if (!ZFIsEmptyString(self.sectionModel.attributes.range_fg_color)) {
                return [UIColor colorWithHexString:self.sectionModel.attributes.range_fg_color];
            }
        } else if (!ZFIsEmptyString(self.sectionModel.attributes.range_bg_color)) {
            return [UIColor colorWithHexString:self.sectionModel.attributes.range_bg_color];
        }
        
        return isTrack ? ZFC0xFE5269() : ZFC0x000000_A(0.1);
    }
    
    if (isTrack) {
        if (!ZFIsEmptyString(self.sectionModel.attributes.cannot_range_color)) {
            return [UIColor colorWithHexString:self.sectionModel.attributes.cannot_range_color];
        }
    } else if (!ZFIsEmptyString(self.sectionModel.attributes.cannot_range_color)) {
        return [UIColor colorWithHexString:self.sectionModel.attributes.cannot_range_color];
    }
    return ColorHex_Alpha(0xC8C8C8, 1.0);
}


/// 按钮状态
- (void)couponButtonState:(ZFCMSCouponState)couponState {
    
    if (!ZFIsEmptyString(self.sectionModel.attributes.btn_text_color) && self.sectionModel.selection_style == 1) {
        [self.couponStateButton setTitleColor:[UIColor colorWithHexString:self.sectionModel.attributes.btn_text_color] forState:UIControlStateNormal];
    } else {
        [self.couponStateButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
    }
    
    if (couponState <= ZFCMSCouponStateCanReceive) {
        [self.couponStateButton setTitle:ZFLocalizedString(@"Hom_Coupon_Claim", nil) forState:UIControlStateNormal];

        if (!ZFIsEmptyString(self.sectionModel.attributes.not_btn_color) && self.sectionModel.selection_style == 1) {
            [self.couponStateButton setBackgroundColor:[UIColor colorWithHexString:self.sectionModel.attributes.not_btn_color]];
            self.couponStateButton.layer.borderColor = [UIColor colorWithHexString:self.sectionModel.attributes.not_btn_color].CGColor;
        } else {
            [self.couponStateButton setBackgroundColor:ColorHex_Alpha(0xFE5269, 1.0)];
            self.couponStateButton.layer.borderColor = ColorHex_Alpha(0xED3F5C, 1.0).CGColor;
        }
        
        self.couponTitleLabel.textColor = ColorHex_Alpha(0x5F1818, 1.0);
        self.couponDescLabel.textColor = ColorHex_Alpha(0xCA7373, 1.0);
        
    } else if (couponState == ZFCMSCouponStateHadReceive) {
        
        [self.couponStateButton setTitle:ZFLocalizedString(@"Hom_Coupon_Claimed", nil) forState:UIControlStateNormal];

        if (!ZFIsEmptyString(self.sectionModel.attributes.got_btn_color) && self.sectionModel.selection_style == 1) {
            [self.couponStateButton setBackgroundColor:[UIColor colorWithHexString:self.sectionModel.attributes.got_btn_color]];
            self.couponStateButton.layer.borderColor = [UIColor colorWithHexString:self.sectionModel.attributes.got_btn_color].CGColor;
        } else {
            [self.couponStateButton setBackgroundColor:ColorHex_Alpha(0xEB7686, 1.0)];
            self.couponStateButton.layer.borderColor = ColorHex_Alpha(0xEB7686, 1.0).CGColor;
        }

        self.couponTitleLabel.textColor = ColorHex_Alpha(0x5F1818, 1.0);
        self.couponDescLabel.textColor = ColorHex_Alpha(0xCA7373, 1.0);
        
    } else {
        
        if (self.itemModel.couponModel.couponState == ZFCMSCouponStateHadReceive) {
            [self.couponStateButton setTitle:ZFLocalizedString(@"Hom_Coupon_Claimed", nil) forState:UIControlStateNormal];

        } else {
            [self.couponStateButton setTitle:ZFLocalizedString(@"Hom_Coupon_No_Left", nil) forState:UIControlStateNormal];
        }

        if (!ZFIsEmptyString(self.sectionModel.attributes.finished_btn_color) && self.sectionModel.selection_style == 1) {
            [self.couponStateButton setBackgroundColor:[UIColor colorWithHexString:self.sectionModel.attributes.finished_btn_color]];
            self.couponStateButton.layer.borderColor = [UIColor colorWithHexString:self.sectionModel.attributes.finished_btn_color].CGColor;
        } else {
            [self.couponStateButton setBackgroundColor:ColorHex_Alpha(0xC8C8C8, 1.0)];
            self.couponStateButton.layer.borderColor = ColorHex_Alpha(0xC8C8C8, 1.0).CGColor;
        }
    
        self.couponTitleLabel.textColor = ColorHex_Alpha(0x8E8E8E, 1.0);
        self.couponDescLabel.textColor = ColorHex_Alpha(0xBBBBBB, 1.0);
    }
}
/// 状态图片
- (void)couponStateImageState:(ZFCMSCouponState)couponState {
    
    NSString *languageCode = [ZFLocalizationString shareLocalizable].currentLanguageName;
    NSString *lang = @"en";
    if ([languageCode hasPrefix:@"Es"]) {
        lang = @"es";
    } else if ([languageCode hasPrefix:@"Fr"]) {
        lang = @"fr";
    }
    
    NSString *imagName = @"";
    
    self.couponStateImageView.hidden = YES;
    if (couponState <= ZFCMSCouponStateCanReceive) {
        
    } else if(couponState == ZFCMSCouponStateHadReceive) {
        self.couponStateImageView.hidden = NO;
        imagName = [NSString stringWithFormat:@"coupon_claimed_%@",lang];
        self.couponStateImageView.image = [[UIImage imageNamed:imagName] imageWithColor:ZFC0xFFFFFF()];
    } else {
        self.couponStateImageView.hidden = NO;
        imagName = [NSString stringWithFormat:@"coupon_used_%@",lang];
        self.couponStateImageView.image = [[UIImage imageNamed:imagName] imageWithColor:ColorHex_Alpha(0xBBBBBB, 0.8)];
    }
}

- (void)updateBgState:(ZFCMSCouponState)couponState iamgeUrl:(NSString *)url {
    
    if (!ZFIsEmptyString(url) && self.sectionModel.selection_style == 1) {
        [self.bgImageView yy_setImageWithURL:[NSURL URLWithString:url]
                                 placeholder:[UIImage imageNamed:@"index_banner_loading"]
                                     options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                    progress:nil
                                   transform:^UIImage *(UIImage *image, NSURL *url) {
            
                                        if ([image isKindOfClass:[YYImage class]]) {
                                            YYImage *showImage = (YYImage *)image;
                                            if (showImage.animatedImageType == YYImageTypeGIF || showImage.animatedImageData) {
                                                return image;
                                            }
                                        }
                                        return [image zf_drawImageToOpaque];
        
        } completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        }];
        
        self.layer.cornerRadius = 0;
        self.layer.masksToBounds = YES;
    } else {
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
    }
    
    CGSize size = self.contentSize;
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return;
    }
    
    // 处理当前状态与数据状态
    ZFCMSCouponBaseState tempState;
    if (couponState <= ZFCMSCouponStateCanReceive || couponState ==ZFCMSCouponStateHadReceive) {
        tempState = ZFCMSCouponBaseStateHighlighted;
    } else {
        tempState = ZFCMSCouponBaseStateNormal;
    }
    
    if (self.couponState != tempState) {
        self.couponState = tempState;
        
        if (self.couponState == ZFCMSCouponBaseStateHighlighted) {
            [self createLineViewUpdate:YES];
        } else {
            [self createLineViewUpdate:YES];
        }
    }
}


- (void)backColorHighlight:(BOOL)highlight {
    if (highlight) {
        UIColor *gradColor = [UIView bm_colorGradientChangeWithSize:self.contentSize direction:IHGradientChangeDirectionUpwardDiagonalLine startColor:ColorHex_Alpha(0xFFDAB1, 1.0) endColor:ColorHex_Alpha(0xFF7173, 1.0)];
        self.backgroundColor = gradColor;
    } else {
        UIColor *gradColor = [UIView bm_colorGradientChangeWithSize:self.contentSize direction:IHGradientChangeDirectionUpwardDiagonalLine startColor:ColorHex_Alpha(0xF0F0F0, 1.0) endColor:ColorHex_Alpha(0xE1E1E1, 1.0)];
        self.backgroundColor = gradColor;
    }
}

@end


#pragma mark -

@implementation ZFCMSCouponBigItemBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.circleProgressView.hidden = NO;
        self.couponStateButton.layer.borderWidth = 2.0;
        self.couponStateButton.layer.cornerRadius = 13.0;
        self.couponStateButton.layer.masksToBounds = YES;
        
        
        self.currencySmallFontSize = 14;
        self.titleMaxFontSize = 28;
        self.couponTitleLabel.font = [UIFont boldSystemFontOfSize:28];
        //        self.couponTitleLabel.minimumScaleFactor = 14;
        self.couponDescLabel.font = [UIFont systemFontOfSize:12];
        self.couponStateButton.titleLabel.font = [UIFont systemFontOfSize:13];
        
        self.circleProgressView.hidden = NO;
        self.horizontalProgressView.hidden = YES;
        if (self.horizontalProgressView.superview) {
            [self.horizontalProgressView removeFromSuperview];
        }
        
        [self.couponStateContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.top.bottom.mas_equalTo(self);
            make.width.mas_equalTo(125);
        }];
        

        [self.couponStateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.couponStateContentView.mas_centerY);
            make.centerX.mas_equalTo(self.couponStateContentView.mas_centerX);
            make.height.mas_equalTo(28);
            make.width.mas_lessThanOrEqualTo(100);
            make.width.mas_greaterThanOrEqualTo(64);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.couponStateContentView.mas_leading);
            make.top.bottom.mas_equalTo(self);
            make.width.mas_equalTo(2);
        }];
        
        [self.whiteCircleViewOne mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.lineView.mas_centerX);
            make.centerY.mas_equalTo(self.mas_top);
            make.size.mas_equalTo(CGSizeMake(kCouponItemWhiteH, kCouponItemWhiteH));
        }];
        
        [self.whiteCircleViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.lineView.mas_centerX);
            make.centerY.mas_equalTo(self.mas_bottom);
            make.size.mas_equalTo(CGSizeMake(kCouponItemWhiteH, kCouponItemWhiteH));
        }];
        
        [self.circleProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.trailing.mas_equalTo(self.couponStateContentView.mas_leading).offset(-10);
            make.size.mas_equalTo(CGSizeMake(62, 62));
        }];
        
        [self.progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.circleProgressView.mas_centerY);
            make.leading.mas_equalTo(self.circleProgressView.mas_leading).offset(5);
            make.trailing.mas_equalTo(self.circleProgressView.mas_trailing).offset(-5);
        }];
        
        [self.descContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.circleProgressView.mas_leading);
            make.top.bottom.mas_equalTo(self);
        }];
        
        [self.couponTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.descContentView.mas_leading).offset(5);
            make.bottom.mas_equalTo(self.descContentView.mas_centerY).offset(4);
            make.trailing.mas_equalTo(self.descContentView.mas_trailing).offset(-5);
        }];
        
        [self.couponDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.descContentView.mas_centerX);
            make.top.mas_equalTo(self.couponTitleLabel.mas_bottom).offset(2);
            make.leading.mas_equalTo(self.descContentView.mas_leading).offset(5);
            make.trailing.mas_equalTo(self.descContentView.mas_trailing).offset(-5);
        }];
        
        
        
    }
    return self;
}

- (void)createLineViewUpdate:(BOOL)update {
    
    CGSize size = CGSizeMake(2, self.contentSize.height);
    
    // 首次默认创建高亮
    if (!self.lineChartLayer) {
        self.couponState = ZFCMSCouponBaseStateHighlighted;
        
        //背景色
        [self backColorHighlight:YES];
        
        /** 创建并设置渐变背景图层 */
        //初始化CAGradientlayer对象，使它的大小为渐变背景视图的大小
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
        //设置渐变区域的起始和终止位置（范围为0-1），即渐变路径
        self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);
        
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(size.width / 2.0 - 0.5, 0)];
        
        [path addLineToPoint:CGPointMake(size.width / 2.0 - 0.5, size.height)];
        
        self.lineChartLayer = [CAShapeLayer new];
        self.lineChartLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.lineChartLayer.fillColor = [[UIColor clearColor] CGColor];
        
        self.lineChartLayer.path = path.CGPath;
        self.lineChartLayer.lineCap = kCALineCapRound;
        self.lineChartLayer.lineJoin = kCALineJoinRound;
        self.lineChartLayer.lineWidth = 1;
        self.lineChartLayer.lineDashPattern = @[@(5), @(3)];
        
        // 设置折线图层为渐变图层的mask
        self.lineView.layer.mask = self.lineChartLayer;

        //设置颜色的渐变过程
        self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)ColorHex_Alpha(0xE9A174, 1.0).CGColor, (__bridge id)ColorHex_Alpha(0xDE6F6F, 1.0).CGColor]];
        self.gradientLayer.colors = self.gradientLayerColors;
        //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
        [self.lineView.layer addSublayer:self.gradientLayer];
    }
    
    if (update) {
        if (self.couponState == ZFCMSCouponBaseStateHighlighted) {
            
            //背景色
            [self backColorHighlight:YES];
            
            //设置颜色的渐变过程
            self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)ColorHex_Alpha(0xE9A174, 1.0).CGColor, (__bridge id)ColorHex_Alpha(0xDE6F6F, 1.0).CGColor]];
            self.gradientLayer.colors = self.gradientLayerColors;

        } else {
            //背景色
            [self backColorHighlight:NO];
            
            //设置颜色的渐变过程
            self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)ColorHex_Alpha(0xCECECE, 1.0).CGColor, (__bridge id)ColorHex_Alpha(0xB6B6B6, 1.0).CGColor]];
            self.gradientLayer.colors = self.gradientLayerColors;
        }
    }
}

@end

@implementation ZFCMSCouponMediumItemBaseView
@synthesize horizontalProgressView = _horizontalProgressView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.couponStateButton.layer.borderWidth = 2.0;
        self.couponStateButton.layer.cornerRadius = 8.0;
        self.couponStateButton.layer.masksToBounds = YES;
        
        self.couponTitleLabel.font = [UIFont boldSystemFontOfSize:28];
        self.currencySmallFontSize = 14;
        self.titleMaxFontSize = 28;
//        self.couponTitleLabel.minimumScaleFactor = 9;
        self.couponDescLabel.font = [UIFont systemFontOfSize:12];
        self.couponStateButton.titleLabel.font = [UIFont systemFontOfSize:8];
        
        self.horizontalProgressView.hidden = NO;
        self.circleProgressView.hidden = YES;
        if (self.circleProgressView.superview) {
            [self.circleProgressView removeFromSuperview];
        }
        [self.couponStateContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(self);
            make.height.mas_equalTo(32);
        }];

        [self.couponStateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.couponStateContentView.mas_centerY);
            make.trailing.mas_equalTo(self.couponStateContentView.mas_trailing).offset(-10);
            make.height.mas_equalTo(16);
            make.width.mas_lessThanOrEqualTo(66);
            make.width.mas_greaterThanOrEqualTo(44);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.couponStateContentView.mas_top);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(2);
        }];
        
        [self.whiteCircleViewOne mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.couponStateContentView.mas_leading);
            make.centerY.mas_equalTo(self.couponStateContentView.mas_top);
            make.size.mas_equalTo(CGSizeMake(kCouponItemWhiteH, kCouponItemWhiteH));
        }];
        
        [self.whiteCircleViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.couponStateContentView.mas_trailing);
            make.centerY.mas_equalTo(self.couponStateContentView.mas_top);
            make.size.mas_equalTo(CGSizeMake(kCouponItemWhiteH, kCouponItemWhiteH));
        }];
        
        [self.horizontalProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.couponStateContentView.mas_leading).offset(10);
            make.centerY.mas_equalTo(self.couponStateContentView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(80, 10));
        }];
        
        
        [self.descContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(2);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-2);
            make.top.mas_equalTo(self);
            make.bottom.mas_equalTo(self.couponStateContentView.mas_top);
        }];
         
        
        [self.couponTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.descContentView.mas_leading).offset(2);
            make.centerY.mas_equalTo(self.descContentView.mas_centerY).offset(-5);
            make.trailing.mas_equalTo(self.descContentView.mas_trailing).offset(-2);
        }];
        
        [self.couponDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.descContentView.mas_centerX);
            make.top.mas_equalTo(self.couponTitleLabel.mas_bottom);
            make.leading.mas_equalTo(self.descContentView.mas_leading).offset(5);
            make.trailing.mas_equalTo(self.descContentView.mas_trailing).offset(-5);
        }];
        
    }
    return self;
}

- (void)updateViewConstraints {
    if (self.horizontalProgressView.superview) {
        if (self.horizontalProgressView.isHidden) {
            [self.couponStateButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.couponStateContentView.mas_centerY);
                make.centerX.mas_equalTo(self.couponStateContentView.mas_centerX);
                make.height.mas_equalTo(16);
                make.width.mas_lessThanOrEqualTo(110);
                make.width.mas_greaterThanOrEqualTo(44);
            }];
            
        } else {
            
            [self.couponStateButton mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.couponStateContentView.mas_centerY);
                make.trailing.mas_equalTo(self.couponStateContentView.mas_trailing).offset(-10);
                make.height.mas_equalTo(16);
                make.width.mas_lessThanOrEqualTo(66);
                make.width.mas_greaterThanOrEqualTo(44);
            }];
        }
    }
}

- (void)createLineViewUpdate:(BOOL)update {
    
    CGSize size = CGSizeMake(self.contentSize.width, 2);

    if (!self.lineChartLayer) {
        self.couponState = ZFCMSCouponBaseStateHighlighted;

        //背景色
        [self backColorHighlight:YES];
        
        /** 创建并设置渐变背景图层 */
        //初始化CAGradientlayer对象，使它的大小为渐变背景视图的大小
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
        //设置渐变区域的起始和终止位置（范围为0-1），即渐变路径
        self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);
        
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(0, size.height / 2.0 - 0.5)];
        
        [path addLineToPoint:CGPointMake(size.width, size.height / 2.0 - 0.5)];
        
        self.lineChartLayer = [CAShapeLayer new];
        self.lineChartLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.lineChartLayer.fillColor = [[UIColor clearColor] CGColor];
        
        self.lineChartLayer.path = path.CGPath;
        self.lineChartLayer.lineCap = kCALineCapRound;
        self.lineChartLayer.lineJoin = kCALineJoinRound;
        self.lineChartLayer.lineWidth = 1;
        self.lineChartLayer.lineDashPattern = @[@(5), @(3)];
        
        // 设置折线图层为渐变图层的mask
        self.lineView.layer.mask = self.lineChartLayer;
        self.lineView.backgroundColor = [UIColor whiteColor];
        //设置颜色的渐变过程
        self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)ColorHex_Alpha(0xE9A174, 1.0).CGColor, (__bridge id)ColorHex_Alpha(0xDE6F6F, 1.0).CGColor]];
        self.gradientLayer.colors = self.gradientLayerColors;
        //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
        [self.lineView.layer addSublayer:self.gradientLayer];
    }
    
    if (update) {
        if (self.couponState == ZFCMSCouponBaseStateHighlighted) {
            
            //背景色
            [self backColorHighlight:YES];
            
            //设置颜色的渐变过程
            self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)ColorHex_Alpha(0xE9A174, 1.0).CGColor, (__bridge id)ColorHex_Alpha(0xDE6F6F, 1.0).CGColor]];
            self.gradientLayer.colors = self.gradientLayerColors;

        } else {
            
            //背景色
            [self backColorHighlight:NO];

            //设置颜色的渐变过程
            self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)ColorHex_Alpha(0xCECECE, 1.0).CGColor, (__bridge id)ColorHex_Alpha(0xB6B6B6, 1.0).CGColor]];
            self.gradientLayer.colors = self.gradientLayerColors;
        }
    }
}

- (ZFCMSLineProgressView *)horizontalProgressView {
    if (!_horizontalProgressView) {
        _horizontalProgressView = [[ZFCMSLineProgressView alloc] initWithFrame:CGRectMake(0, 0, 80, 10)];
        _horizontalProgressView.trackColor = ColorHex_Alpha(0xFE5269, 1.0);
        _horizontalProgressView.backColor = ColorHex_Alpha(0x000000, 0.1);
        _horizontalProgressView.pathLineColor = ColorHex_Alpha(0xFFFFFF, 0.15);
        _horizontalProgressView.textFont = [UIFont systemFontOfSize:8];
        _horizontalProgressView.layer.cornerRadius = 5;
        _horizontalProgressView.layer.masksToBounds = YES;
    }
    return _horizontalProgressView;
}
@end


@implementation ZFCMSCouponTrisectionItemBaseView
@synthesize horizontalProgressView = _horizontalProgressView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.horizontalProgressView.hidden = NO;
        self.circleProgressView.hidden = YES;
        if (self.circleProgressView.superview) {
            [self.circleProgressView removeFromSuperview];
        }
        
        self.couponStateButton.layer.borderWidth = 2.0;
        self.couponStateButton.layer.cornerRadius = 8.0;
        self.couponStateButton.layer.masksToBounds = YES;
        
        self.couponTitleLabel.font = [UIFont boldSystemFontOfSize:20];
        self.currencySmallFontSize = 10;
        self.titleMaxFontSize = 20;
        
//        self.couponTitleLabel.minimumScaleFactor = 9;
        self.couponDescLabel.font = [UIFont systemFontOfSize:10];
        self.couponStateButton.titleLabel.font = [UIFont systemFontOfSize:8];
        
        [self.couponStateContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(self);
            make.height.mas_equalTo(32);
        }];
        
        [self.couponStateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.couponStateContentView.mas_centerY);
            make.centerX.mas_equalTo(self.couponStateContentView.mas_centerX);
            make.height.mas_equalTo(16);
            make.width.mas_lessThanOrEqualTo(99);
            make.width.mas_greaterThanOrEqualTo(64);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.couponStateContentView.mas_top);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(2);
        }];
        
        [self.whiteCircleViewOne mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.couponStateContentView.mas_leading);
            make.centerY.mas_equalTo(self.couponStateContentView.mas_top);
            make.size.mas_equalTo(CGSizeMake(kCouponItemWhiteH, kCouponItemWhiteH));
        }];
        
        [self.whiteCircleViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.couponStateContentView.mas_trailing);
            make.centerY.mas_equalTo(self.couponStateContentView.mas_top);
            make.size.mas_equalTo(CGSizeMake(kCouponItemWhiteH, kCouponItemWhiteH));
        }];
        
        [self.descContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(2);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-2);
            make.top.mas_equalTo(self);
            make.bottom.mas_equalTo(self.couponStateContentView.mas_top);
        }];
        
        [self.horizontalProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.descContentView.mas_centerX);
            make.bottom.mas_equalTo(self.descContentView.mas_bottom).offset(-10);
            make.size.mas_equalTo(CGSizeMake(44, 8));
        }];
        
        [self.couponDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.descContentView.mas_centerY);
            make.leading.mas_equalTo(self.descContentView.mas_leading).offset(5);
            make.trailing.mas_equalTo(self.descContentView.mas_trailing).offset(-5);
        }];
        
        [self.couponTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.couponDescLabel.mas_top).offset(-1);
            make.leading.mas_equalTo(self.descContentView.mas_leading).offset(5);
            make.trailing.mas_equalTo(self.descContentView.mas_trailing).offset(-5);
        }];

    }
    return self;
}

- (void)updateViewConstraints {
    if (self.horizontalProgressView.superview) {
        if (self.horizontalProgressView.hidden) {
            
            [self.couponDescLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.descContentView.mas_centerY).offset(5);
                make.leading.mas_equalTo(self.descContentView.mas_leading).offset(5);
                make.trailing.mas_equalTo(self.descContentView.mas_trailing).offset(-5);
            }];
        } else {
            
            [self.couponDescLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.descContentView.mas_centerY);
                make.leading.mas_equalTo(self.descContentView.mas_leading).offset(5);
                make.trailing.mas_equalTo(self.descContentView.mas_trailing).offset(-5);
            }];
        }
    }
}

- (void)createLineViewUpdate:(BOOL)update {

    CGSize size = CGSizeMake(self.contentSize.width, 2);

    if (!self.lineChartLayer) {
        self.couponState = ZFCMSCouponBaseStateHighlighted;
        
        //背景色
        [self backColorHighlight:YES];
        
        /** 创建并设置渐变背景图层 */
        //初始化CAGradientlayer对象，使它的大小为渐变背景视图的大小
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
        //设置渐变区域的起始和终止位置（范围为0-1），即渐变路径
        self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);
        
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(0, size.height / 2.0 - 0.5)];
        
        [path addLineToPoint:CGPointMake(size.width, size.height / 2.0 - 0.5)];
        
        self.lineChartLayer = [CAShapeLayer new];
        self.lineChartLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.lineChartLayer.fillColor = [[UIColor clearColor] CGColor];
        
        self.lineChartLayer.path = path.CGPath;
        self.lineChartLayer.lineCap = kCALineCapRound;
        self.lineChartLayer.lineJoin = kCALineJoinRound;
        self.lineChartLayer.lineWidth = 1;
        self.lineChartLayer.lineDashPattern = @[@(5), @(3)];
        
        // 设置折线图层为渐变图层的mask
        self.lineView.layer.mask = self.lineChartLayer;
        self.lineView.backgroundColor = [UIColor whiteColor];
        //设置颜色的渐变过程
        self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)ColorHex_Alpha(0xE9A174, 1.0).CGColor, (__bridge id)ColorHex_Alpha(0xDE6F6F, 1.0).CGColor]];
        self.gradientLayer.colors = self.gradientLayerColors;
        //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
        [self.lineView.layer addSublayer:self.gradientLayer];
    }

    if (update) {
        if (self.couponState == ZFCMSCouponBaseStateHighlighted) {
            
            //背景色
            [self backColorHighlight:YES];

            //设置颜色的渐变过程
            self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)ColorHex_Alpha(0xE9A174, 1.0).CGColor, (__bridge id)ColorHex_Alpha(0xDE6F6F, 1.0).CGColor]];
            self.gradientLayer.colors = self.gradientLayerColors;

        } else {
            
            //背景色
            [self backColorHighlight:NO];

            //设置颜色的渐变过程
            self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)ColorHex_Alpha(0xCECECE, 1.0).CGColor, (__bridge id)ColorHex_Alpha(0xB6B6B6, 1.0).CGColor]];
            self.gradientLayer.colors = self.gradientLayerColors;
        }
    }
    
}

- (ZFCMSLineProgressView *)horizontalProgressView {
    if (!_horizontalProgressView) {
        _horizontalProgressView = [[ZFCMSLineProgressView alloc] initWithFrame:CGRectMake(0, 0, 44, 8)];
        _horizontalProgressView.trackColor = ColorHex_Alpha(0xFE5269, 1.0);
        _horizontalProgressView.backColor = ColorHex_Alpha(0x000000, 0.1);
        _horizontalProgressView.pathLineColor = ColorHex_Alpha(0xFFFFFF, 0.15);
        _horizontalProgressView.textFont = [UIFont systemFontOfSize:6];
        _horizontalProgressView.layer.cornerRadius = 4;
        _horizontalProgressView.layer.masksToBounds = YES;
    }
    return _horizontalProgressView;
}
@end


@implementation ZFCMSCouponQuarterItemBaseView
@synthesize horizontalProgressView = _horizontalProgressView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.horizontalProgressView.hidden = NO;
        self.circleProgressView.hidden = YES;
        if (self.circleProgressView.superview) {
            [self.circleProgressView removeFromSuperview];
        }
        self.couponStateButton.layer.borderWidth = 2.0;
        self.couponStateButton.layer.cornerRadius = 7.0;
        self.couponStateButton.layer.masksToBounds = YES;
        self.couponTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.currencySmallFontSize = 8;
        self.titleMaxFontSize = 14;
        self.couponDescLabel.font = [UIFont systemFontOfSize:8];
        self.couponStateButton.titleLabel.font = [UIFont systemFontOfSize:8];
        
        self.whiteCircleViewOne.layer.cornerRadius = 6.0;
        self.whiteCircleViewTwo.layer.cornerRadius = 6.0;
        
       [self.couponStateContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.mas_equalTo(self);
            make.height.mas_equalTo(27);
        }];
        
        [self.couponStateButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.couponStateContentView.mas_centerY);
            make.centerX.mas_equalTo(self.couponStateContentView.mas_centerX);
            make.height.mas_equalTo(14);
            make.width.mas_lessThanOrEqualTo(75);
            make.width.mas_greaterThanOrEqualTo(44);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.couponStateContentView.mas_top);
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_equalTo(2);
        }];
        
        [self.whiteCircleViewOne mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.couponStateContentView.mas_leading);
            make.centerY.mas_equalTo(self.couponStateContentView.mas_top);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
        
        [self.whiteCircleViewTwo mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.couponStateContentView.mas_trailing);
            make.centerY.mas_equalTo(self.couponStateContentView.mas_top);
            make.size.mas_equalTo(CGSizeMake(12, 12));
        }];
        

        [self.descContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).offset(2);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-2);
            make.top.mas_equalTo(self);
            make.bottom.mas_equalTo(self.couponStateContentView.mas_top);
        }];
        
        [self.horizontalProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.descContentView.mas_centerX);
            make.bottom.mas_equalTo(self.descContentView.mas_bottom).offset(-kCouponItemWhiteH / 2.0);
            make.size.mas_equalTo(CGSizeMake(54, 8));
        }];
        
        [self.couponDescLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.descContentView.mas_centerY);
            make.leading.mas_equalTo(self.descContentView.mas_leading).offset(5);
            make.trailing.mas_equalTo(self.descContentView.mas_trailing).offset(-5);
        }];
        
        [self.couponTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.descContentView.mas_leading).offset(2);
            make.bottom.mas_equalTo(self.couponDescLabel.mas_top).offset(-3);
            make.trailing.mas_equalTo(self.descContentView.mas_trailing);
        }];
    
    }
    return self;
}

- (void)updateViewConstraints {
    if (self.horizontalProgressView.superview) {
        if (self.horizontalProgressView.hidden) {
            
            [self.couponDescLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.descContentView.mas_centerY).offset(5);
                make.leading.mas_equalTo(self.descContentView.mas_leading).offset(5);
                make.trailing.mas_equalTo(self.descContentView.mas_trailing).offset(-5);
            }];
        } else {
            
            [self.couponDescLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.descContentView.mas_centerY);
                make.leading.mas_equalTo(self.descContentView.mas_leading).offset(5);
                make.trailing.mas_equalTo(self.descContentView.mas_trailing).offset(-5);
            }];
        }
    }
}

- (void)createLineViewUpdate:(BOOL)update {
    
    CGSize size = CGSizeMake(self.contentSize.width, 2);

    if (!self.lineChartLayer) {
        self.couponState = ZFCMSCouponBaseStateHighlighted;
        
        //背景色
        [self backColorHighlight:YES];

        
        /** 创建并设置渐变背景图层 */
        //初始化CAGradientlayer对象，使它的大小为渐变背景视图的大小
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = CGRectMake(0, 0, size.width, size.height);
        //设置渐变区域的起始和终止位置（范围为0-1），即渐变路径
        self.gradientLayer.startPoint = CGPointMake(0.0, 0.0);
        self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);
        
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(0, size.height / 2.0 - 0.5)];
        
        [path addLineToPoint:CGPointMake(size.width, size.height / 2.0 - 0.5)];
        
        self.lineChartLayer = [CAShapeLayer new];
        self.lineChartLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.lineChartLayer.fillColor = [[UIColor clearColor] CGColor];
        
        self.lineChartLayer.path = path.CGPath;
        self.lineChartLayer.lineCap = kCALineCapRound;
        self.lineChartLayer.lineJoin = kCALineJoinRound;
        self.lineChartLayer.lineWidth = 1;
        self.lineChartLayer.lineDashPattern = @[@(5), @(3)];
        
        // 设置折线图层为渐变图层的mask
        self.lineView.layer.mask = self.lineChartLayer;
        self.lineView.backgroundColor = [UIColor whiteColor];
        //设置颜色的渐变过程
        self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)ColorHex_Alpha(0xE9A174, 1.0).CGColor, (__bridge id)ColorHex_Alpha(0xDE6F6F, 1.0).CGColor]];
        self.gradientLayer.colors = self.gradientLayerColors;
        //将CAGradientlayer对象添加在我们要设置背景色的视图的layer层
        [self.lineView.layer addSublayer:self.gradientLayer];
    }
    
    if (update) {
        if (self.couponState == ZFCMSCouponBaseStateHighlighted) {
            
            
            //背景色
            [self backColorHighlight:YES];

            //设置颜色的渐变过程
            self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)ColorHex_Alpha(0xE9A174, 1.0).CGColor, (__bridge id)ColorHex_Alpha(0xDE6F6F, 1.0).CGColor]];
            self.gradientLayer.colors = self.gradientLayerColors;

        } else {
            
            //背景色
            [self backColorHighlight:NO];

            //设置颜色的渐变过程
            self.gradientLayerColors = [NSMutableArray arrayWithArray:@[(__bridge id)ColorHex_Alpha(0xCECECE, 1.0).CGColor, (__bridge id)ColorHex_Alpha(0xB6B6B6, 1.0).CGColor]];
            self.gradientLayer.colors = self.gradientLayerColors;
        }
    }
}

- (ZFCMSLineProgressView *)horizontalProgressView {
    if (!_horizontalProgressView) {
        _horizontalProgressView = [[ZFCMSLineProgressView alloc] initWithFrame:CGRectMake(0, 0, 54, 8)];
        _horizontalProgressView.trackColor = ColorHex_Alpha(0xFE5269, 1.0);
        _horizontalProgressView.backColor = ColorHex_Alpha(0x000000, 0.1);
        _horizontalProgressView.pathLineColor = ColorHex_Alpha(0xFFFFFF, 0.15);
        _horizontalProgressView.textFont = [UIFont systemFontOfSize:6];
        _horizontalProgressView.layer.cornerRadius = 4;
        _horizontalProgressView.layer.masksToBounds = YES;
    }
    return _horizontalProgressView;
}
@end
