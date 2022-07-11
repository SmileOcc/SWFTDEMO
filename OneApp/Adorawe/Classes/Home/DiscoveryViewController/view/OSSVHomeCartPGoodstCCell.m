//
//  OSSVHomeCartPGoodstCCell.m
// OSSVHomeCartPGoodstCCell
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVHomeCartPGoodstCCell.h"
#import "OSSVCartGoodsModel.h"

@interface OSSVHomeCartPGoodstCCell ()
@property (nonatomic, strong) YYAnimatedImageView *goodsImgView;

@end

@implementation OSSVHomeCartPGoodstCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.goodsImgView];
            
        [self.goodsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.mas_equalTo(self);
        }];
    }
    return self;
}

- (void)setCartGoodsModel:(OSSVCartGoodsModel *)cartGoodsModel {
    
    _cartGoodsModel = cartGoodsModel;
    [self.goodsImgView yy_setImageWithURL:[NSURL URLWithString:cartGoodsModel.goodsThumb]
                                  placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                      options:kNilOptions
                                   completion:nil];
    
}


-(YYAnimatedImageView *)goodsImgView {
    if (!_goodsImgView) {
        _goodsImgView = ({
            YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            imageView;
        });
    }
    return _goodsImgView;
}

@end
