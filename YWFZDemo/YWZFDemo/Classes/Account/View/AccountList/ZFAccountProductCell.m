//
//  ZFAccountProductCell.m
//  ZZZZZ
//
//  Created by YW on 2019/1/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountProductCell.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "UIImage+ZFExtended.h"
#import "ZFGoodsModel.h"
#import "ExchangeManager.h"
#import "ZFLocalizationString.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>

#pragma mark - ZFAccountProductView

#define labelHeight 40

@interface ZFAccountProductView : UIView
@property (nonatomic, strong) UIImageView *productImageView;        //商品图片
@property (nonatomic, strong) UILabel *priceLabel;                  //商品价格
@property (nonatomic, strong) UILabel *markerPriceLabel;            //市场价格
@property (nonatomic, strong) UIButton *discountTabView;            //折扣标签
@property (nonatomic, assign) NSInteger abFlag;                     //ab测试
@property (nonatomic, strong) ZFGoodsModel *goodsModel;
@end

@implementation ZFAccountProductView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ZFCOLOR_WHITE;
        [self addSubview:self.productImageView];
        [self addSubview:self.priceLabel];
        [self addSubview:self.markerPriceLabel];
        [self addSubview:self.discountTabView];
        
        [self.productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(self);
            make.height.mas_equalTo(self.mas_width).multipliedBy(1.33);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.productImageView);
            make.top.mas_equalTo(self.productImageView.mas_bottom);
            make.height.mas_offset(labelHeight);
        }];
        
        [self.markerPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.priceLabel.mas_trailing).offset(5);
            make.top.mas_equalTo(self.priceLabel);
            make.height.mas_equalTo(self.priceLabel);
        }];
        
        [self.discountTabView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(4);
            make.trailing.mas_equalTo(self.mas_trailing);
             make.height.mas_equalTo(16);
        }];
    }
    return self;
}

#pragma mark - Property Method

- (void)setGoodsModel:(ZFGoodsModel *)goodsModel
{
    _goodsModel = goodsModel;
    
    self.priceLabel.textColor = ZFCOLOR_BLACK;
    self.markerPriceLabel.hidden = YES;
    if (self.abFlag == 1) {
        //只有有生效价格
        self.markerPriceLabel.attributedText = nil;
    }else if (self.abFlag == 2) {
        //有生效价格，有划掉的本店售价
        NSString *marketPrice = [ExchangeManager transforPrice:_goodsModel.market_price];
        NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:marketPrice attributes:attribtDic];
        self.markerPriceLabel.attributedText = attribtStr;
    }
    
    NSString *imageURL = _goodsModel.goods_thumb;
    if (ZFIsEmptyString(imageURL)) {
        imageURL = _goodsModel.wp_image;
    }
    [self.productImageView yy_setImageWithURL:[NSURL URLWithString:imageURL]
                                  placeholder:[UIImage imageNamed:@"loading_cat_list"]
                                      options:YYWebImageOptionAvoidSetImage
                                   completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                       if (image && stage == YYWebImageStageFinished) {
                                           self.productImageView.image = image;
                                           if (from != YYWebImageFromMemoryCacheFast) {
                                               CATransition *transition = [CATransition animation];
                                               transition.duration = KImageFadeDuration;
                                               transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                                               transition.type = kCATransitionFade;
                                               [self.productImageView.layer addAnimation:transition forKey:@"fadeAnimation"];
                                           }
                                       }
                                   }];
    self.markerPriceLabel.text = [ExchangeManager transforPrice:_goodsModel.market_price];
    
    if ([_goodsModel showMarketPrice]) {
        self.priceLabel.textColor = ZFC0xFE5269();
    } else {
        self.priceLabel.textColor = ZFCOLOR_BLACK;
    }
    
    self.priceLabel.text = [ExchangeManager transforPrice:_goodsModel.shop_price];
    
    if ([_goodsModel.channel_type intValue] == 1 ||[_goodsModel.channel_type intValue] == 2 || [_goodsModel.channel_type intValue] == 3){
        //        /** 1热卖品 */
        //        ZFMarketingTagTypeHot = 1,
        //        /** 2潜力品 */
        //        ZFMarketingTagTypePopular,
        //        /** 3 新品 */
        //        ZFMarketingTagTypeNew,
        self.discountTabView.hidden = NO;
        NSString *marketingTagString = @"";//自营销标签名字
        if ([_goodsModel.channel_type intValue] == 1) {
            marketingTagString = ZFLocalizedString(@"HOT", nil);
        }else if ([_goodsModel.channel_type intValue] == 2){
            marketingTagString = ZFLocalizedString(@"POPULAR", nil);
        }else if ([_goodsModel.channel_type intValue] == 3){
            marketingTagString = ZFLocalizedString(@"NEW", nil);
        }
        [self.discountTabView setTitle:marketingTagString forState:UIControlStateNormal];
    }else{
        self.discountTabView.hidden = YES;
    }
}

- (void)setAbFlag:(NSInteger)abFlag
{
    _abFlag = abFlag;
    
    if (_abFlag == 1) {
        //只有有生效价格
//        [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.mas_equalTo(self.productImageView);
//            make.top.mas_equalTo(self.productImageView.mas_bottom);
//            make.height.mas_offset(labelHeight);
//        }];
        self.markerPriceLabel.attributedText = nil;
    }else if (_abFlag == 2) {
        //有生效价格，有划掉的本店售价
        self.priceLabel.textColor = ZFC0xFE5269();
        self.markerPriceLabel.hidden = NO;
//        [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(self.productImageView);
//            make.top.mas_equalTo(self.productImageView.mas_bottom);
//            make.height.mas_offset(labelHeight);
//        }];
//
//        [self.markerPriceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(self.priceLabel.mas_trailing).mas_offset(5);
//            make.top.mas_equalTo(self.priceLabel);
//            make.height.mas_equalTo(self.priceLabel);
//        }];
    }
}

- (UIImageView *)productImageView
{
    if (!_productImageView) {
        _productImageView = ({
            UIImageView *img = [[UIImageView alloc] init];
            img;
        });
    }
    return _productImageView;
}

-(UILabel *)priceLabel
{
    if (!_priceLabel) {
        _priceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = @"价格价格";
            label.textColor = [UIColor blackColor];
            label.font = [UIFont boldSystemFontOfSize:14];
            label.textAlignment = NSTextAlignmentLeft;
            label;
        });
    }
    return _priceLabel;
}

-(UILabel *)markerPriceLabel
{
    if (!_markerPriceLabel) {
        _markerPriceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = @"市场价";
            label.textColor = ZFC0x999999();
            label.font = [UIFont systemFontOfSize:12];
            label.textAlignment = NSTextAlignmentLeft;
            label;
        });
    }
    return _markerPriceLabel;
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

#pragma mark - ZFAccountProductCell

#define kNumberRows 2

@interface ZFAccountProductCell ()

@property (nonatomic, strong) NSMutableArray *viewList;
@property (nonatomic, assign) NSInteger abFlag;

@end

@implementation ZFAccountProductCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier abFlag:(NSInteger)flag
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.abFlag = flag;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        NSInteger numberRows = [ZFAccountProductCell numberRowsWithFlag:flag];

        for (int i = 0; i < numberRows; i++) {
            ZFAccountProductView *view = [[ZFAccountProductView alloc] init];
            view.tag = i;
            view.hidden = YES;
            view.abFlag = flag;
            view.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectProdcut:)];
            [view addGestureRecognizer:tap];
            [self.contentView addSubview:view];
            [self.viewList addObject:view];
        }
        
        CGSize size = [ZFAccountProductCell productCellSize:flag];
        [self.viewList mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(size.height);
        }];
        UIView *prev = nil;
        for (int i = 0; i < self.viewList.count; i++) {
            UIView *v = self.viewList[i];
            [v mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.contentView);
                if (prev) {
                    make.width.equalTo(prev);
                    make.leading.equalTo(prev.mas_trailing).offset(10);
                    if (i == self.viewList.count - 1) {//last one
                        make.trailing.equalTo(self.contentView).offset(-10);
                    }
                }
                else {//first one
                    make.leading.equalTo(self.contentView).offset(10);
                    make.bottom.mas_equalTo(self.contentView.mas_bottom);
                }
            }];
            prev = v;
        }
    }
    return self;
}


+ (CGSize)productCellSize:(NSInteger)recommendFlag
{
    NSInteger rows = [self numberRowsWithFlag:recommendFlag];
    CGFloat viewWidth = (KScreenWidth - (rows * 10)) / rows;
    CGFloat viewHeight = viewWidth * 1.33 + labelHeight;
    CGSize size = CGSizeMake(viewWidth, viewHeight);
    return size;
}

+ (NSInteger)numberRowsWithFlag:(NSInteger)recommendFlag
{
    if (recommendFlag == 1) {
        return 3;
    }
    return 2;
}

#pragma mark - target method

- (void)selectProdcut:(UIGestureRecognizer *)sender
{
    UIView *targetView = sender.view;
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFAccountProductCellDidSelectProduct:)]) {
        [self.delegate ZFAccountProductCellDidSelectProduct:self.goodsList[targetView.tag]];
    }
}

#pragma mark - Property Method

- (void)setGoodsList:(NSArray<ZFGoodsModel *> *)goodsList
{
    _goodsList = goodsList;
    
    for (int i = 0; i < [self.viewList count]; i++) {
        ZFAccountProductView *view = self.viewList[i];
        if (i >= [goodsList count]) {
            view.hidden = YES;
            continue;
        }
        view.hidden = NO;
        view.goodsModel = goodsList[i];
    }
}

- (NSMutableArray *)viewList{
    if (!_viewList) {
        _viewList = [[NSMutableArray alloc] init];
    }
    return _viewList;
}

@end
