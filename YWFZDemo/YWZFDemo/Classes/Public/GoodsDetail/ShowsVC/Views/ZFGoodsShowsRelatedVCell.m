//
//  ZFGoodsShowsRelatedVCell.m
//  ZZZZZ
//
//  Created by YW on 2019/3/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsShowsRelatedVCell.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFColorDefiner.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"

#define labelHeight 40

@interface ZFGoodsShowsRelatedVCell ()
@property (nonatomic, strong) UIImageView *productImageView;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UIButton *similarTagButton;
@property (nonatomic, strong) UILabel *markerPriceLabel;
@end

@implementation ZFGoodsShowsRelatedVCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ZFCOLOR_WHITE;
        [self addSubview:self.productImageView];
        [self addSubview:self.similarTagButton];
        [self addSubview:self.priceLabel];
        [self addSubview:self.markerPriceLabel];
        
        [self.productImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(self);
            make.height.mas_equalTo(self.mas_width).multipliedBy(1.33);
        }];
        
        [self.similarTagButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(6);
            make.trailing.offset(0);
            make.height.mas_equalTo(18);
        }];
        
        [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.productImageView);
            make.top.mas_equalTo(self.productImageView.mas_bottom);
            make.height.mas_offset(labelHeight);
        }];
        
//        [self.markerPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(self.priceLabel.mas_trailing).offset(5);
//            make.top.mas_equalTo(self.priceLabel);
//            make.height.mas_equalTo(self.priceLabel);
//        }];
    }
    return self;
}

- (void)setRelatedModel:(ZFGoodsShowsRelatedModel *)relatedModel {
    _relatedModel = relatedModel;
    
    [self.productImageView yy_setImageWithURL:[NSURL URLWithString:relatedModel.pic_url]
                                  placeholder:[UIImage imageNamed:@"community_loading_product"]
                                      options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                     progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                                    transform:^UIImage *(UIImage *image, NSURL *url) {
                                        return image;
                                    }
                                   completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                                   }];
    
    NSString *price = [ExchangeManager transforPrice:relatedModel.price];
    self.priceLabel.text = price;
    
//    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
//    NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:price attributes:attribtDic];
//    self.markerPriceLabel.attributedText = attribtStr;
}

#pragma mark - Property Method

- (UIImageView *)productImageView {
    if (!_productImageView) {
        _productImageView = ({
            UIImageView *img = [[UIImageView alloc] init];
            img.backgroundColor = [UIColor groupTableViewBackgroundColor];
            img;
        });
    }
    return _productImageView;
}

-(UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textColor = ZFC0xFE5269();
            label.font = [UIFont boldSystemFontOfSize:16];
            label.textAlignment = NSTextAlignmentLeft;
            label;
        });
    }
    return _priceLabel;
}

- (UIButton *)similarTagButton{
    if (!_similarTagButton) {
        _similarTagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_similarTagButton setTitle:ZFLocalizedString(@"community_post_simalar", nil) forState:UIControlStateNormal];
        _similarTagButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_similarTagButton setTitleColor:ZFC0xFE5269() forState:UIControlStateNormal];
        _similarTagButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        _similarTagButton.layer.cornerRadius = 2.0f;
        _similarTagButton.layer.borderColor = ZFC0xFE5269().CGColor;
        _similarTagButton.layer.borderWidth = 1.0;
        _similarTagButton.backgroundColor = ZFC0xFFFFFF();
        
//        _similarTagButton.hidden = YES;
    }
    return _similarTagButton;
}

//-(UILabel *)markerPriceLabel {
//    if (!_markerPriceLabel) {
//        _markerPriceLabel = ({
//            UILabel *label = [[UILabel alloc] init];
//            label.textColor = ZFCOLOR(153, 153, 153, 1);
//            label.font = [UIFont systemFontOfSize:12];
//            label.textAlignment = NSTextAlignmentLeft;
//            label;
//        });
//    }
//    return _markerPriceLabel;
//}

@end
