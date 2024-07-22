//
//  ZFProductCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/6/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFProductCCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCMSSectionModel.h"
#import "ZFThemeManager.h"
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "YWCFunctionTool.h"
#import "Constants.h"
#import "ZFLocalizationString.h"
#import "ZFAccountCategorySectionModel.h"

#import "UIButton+ZFButtonCategorySet.h"
#import "UIImage+ZFExtended.h"
#import "NSString+Extended.h"

#import <YYWebImage/YYWebImage.h>
#import <Masonry/Masonry.h>

@interface ZFProductTitleCCell ()
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation ZFProductTitleCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.titleLabel.text = nil;
}

+ (CGSize)itemSize:(NSInteger)sectionRows protocol:(id<ZFCollectionCellDatasourceProtocol>)protocol
{
    return CGSizeMake(KScreenWidth, 40);
}

#pragma mark - ZFInitViewProtocol

-(void)setModel:(id<ZFCollectionCellDatasourceProtocol>)model
{
    _model = model;
    
    if ([_model isKindOfClass:[ZFProductTitleCCellModel class]]) {
        ZFProductTitleCCellModel *titleModel = (ZFProductTitleCCellModel *)_model;
        self.titleLabel.text = titleModel.title;
    }
}

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.titleLabel];
}

- (void)zfAutoLayoutView {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.width.lessThanOrEqualTo(self.contentView.mas_width);
    }];
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = ZFCOLOR_WHITE;
        _titleLabel.text = ZFLocalizedString(@"Account_RecomTitle", nil);
    }
    return _titleLabel;
}

@end

@interface ZFProductCCell ()

@property (nonatomic, strong) YYAnimatedImageView *goodsImageView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIButton *discountTabView;            //折扣标签

@end

@implementation ZFProductCCell
@synthesize model = _model;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.goodsImageView yy_cancelCurrentImageRequest];
    self.goodsImageView.image = nil;
    self.priceLabel.text = nil;
    self.model = nil;
}

#pragma mark - ZFInitViewProtocol

- (void)zfInitView {
    [self addSubview:self.goodsImageView];
    [self addSubview:self.priceLabel];
    [self addSubview:self.discountTabView];
}

- (void)zfAutoLayoutView {
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsImageView.mas_bottom).mas_offset(5);
        make.leading.trailing.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(self.mas_width).multipliedBy(1.35);
    }];
    
    [self.discountTabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(4);
        make.trailing.mas_equalTo(self.mas_trailing);
        make.height.mas_equalTo(16);
    }];
}

#pragma mark - Setter

- (void)setModel:(id<ZFCollectionCellDatasourceProtocol>)model
{
    _model = model;
    
    if ([_model isKindOfClass:[ZFGoodsModel class]]) {
        ZFGoodsModel *goodsModel = _model;
        NSString *imageURL = goodsModel.goods_thumb;
        if (ZFIsEmptyString(imageURL)) {
            imageURL = goodsModel.wp_image;
        }
        self.goodsImageView.backgroundColor = [UIColor redColor];
        [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:imageURL]
                                      placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                          options:YYWebImageOptionAvoidSetImage
                                       completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                           if (image && stage == YYWebImageStageFinished) {
                                               self.goodsImageView.image = image;
                                               if (from != YYWebImageFromMemoryCacheFast) {
                                                   CATransition *transition = [CATransition animation];
                                                   transition.duration = KImageFadeDuration;
                                                   transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                                   transition.type = kCATransitionFade;
                                                   [self.goodsImageView.layer addAnimation:transition forKey:@"fadeAnimation"];
                                               }
                                           }
                                       }];
        if ([goodsModel showMarketPrice]) {
            self.priceLabel.textColor = ZFC0xFE5269();
        } else {
            self.priceLabel.textColor = ZFCOLOR_BLACK;
        }
        
        self.priceLabel.text = [ExchangeManager transforPrice:goodsModel.shop_price];
        
        if ([goodsModel.channel_type intValue] == 1 ||[goodsModel.channel_type intValue] == 2 || [goodsModel.channel_type intValue] == 3){
            //        /** 1热卖品 */
            //        ZFMarketingTagTypeHot = 1,
            //        /** 2潜力品 */
            //        ZFMarketingTagTypePopular,
            //        /** 3 新品 */
            //        ZFMarketingTagTypeNew,
            self.discountTabView.hidden = NO;
            NSString *marketingTagString = @"";//自营销标签名字
            if ([goodsModel.channel_type intValue] == 1) {
                marketingTagString = ZFLocalizedString(@"HOT", nil);
            }else if ([goodsModel.channel_type intValue] == 2){
                marketingTagString = ZFLocalizedString(@"POPULAR", nil);
            }else if ([goodsModel.channel_type intValue] == 3){
                marketingTagString = ZFLocalizedString(@"NEW", nil);
            }
            [self.discountTabView setTitle:marketingTagString forState:UIControlStateNormal];
        }else{
            self.discountTabView.hidden = YES;
        }
    }
}

#pragma mark - Getter
- (YYAnimatedImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [YYAnimatedImageView new];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.clipsToBounds  = YES;
    }
    return _goodsImageView;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = ZFFontBoldSize(14);
        _priceLabel.textAlignment = NSTextAlignmentCenter;
        _priceLabel.textColor = ZFCOLOR_BLACK;
    }
    return _priceLabel;
}

- (UIButton *)discountTabView{
    if (!_discountTabView) {
        _discountTabView = [UIButton buttonWithType:UIButtonTypeCustom];
        _discountTabView.backgroundColor = ZFC0xFE5269();
        _discountTabView.layer.cornerRadius = 2;
        _discountTabView.layer.masksToBounds = YES;
//        [_discountTabView setBackgroundImage:[[[UIImage imageNamed:@"topbg"] imageWithColor:ZFC0xFE5269()] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 0) resizingMode:UIImageResizingModeStretch] forState:UIControlStateNormal];
        _discountTabView.titleLabel.font = [UIFont systemFontOfSize:12];
        [_discountTabView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _discountTabView.contentEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 6);
    }
    return _discountTabView;
}

@end
