//
//  OSSVAccounteOrdereDetaileView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVAccounteOrdereDetaileView.h"
#import "OSSVAccounteOrdersDetaileGoodsModel.h"

@interface OSSVAccounteOrdereDetaileView ()

@property (nonatomic, weak) YYAnimatedImageView *productImg;    //图片
@property (nonatomic, weak) UILabel *productName;     //产品名
@property (nonatomic, weak) UILabel *productSize;     //产品规格
@property (nonatomic, weak) UILabel *productNum;  //产品数量
@property (nonatomic, weak) UILabel *productPrice;  //价格
@property (nonatomic, assign) NSInteger goodsStatue;  //订单状态
@property (nonatomic, strong) UILabel *wareHouseName; //仓库名称
@end

@implementation OSSVAccounteOrdereDetaileView

- (void)initWithGoodsModel:(OSSVAccounteOrdersDetaileGoodsModel *)goodsModel orderStatue:(NSInteger)orderStatue {
    _goodsModel = goodsModel;
    
    [self.productImg yy_setImageWithURL:[NSURL URLWithString:goodsModel.goodsThumb]
                            placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                options:kNilOptions
                               progress:nil
                              transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
//                                            image = [image yy_imageByResizeToSize:CGSizeMake(80,80) contentMode:UIViewContentModeScaleAspectFit];
                                            return image;
                                        }
                             completion:nil];
    self.productName.text  = STLToString(goodsModel.goodsName);
    self.productSize.text =  STLToString(goodsModel.goodsAttr);
    self.wareHouseName.text = STLToString(goodsModel.wareHouseName);

//    if (STLToString(goodsModel.wareHouseName).length) {
//        self.wareHouseName.hidden = NO;
//    } else {
        self.wareHouseName.hidden = YES;
//    }
    self.productPrice.text = STLToString(goodsModel.money_info.goods_price_converted_symbol);
    self.productNum.text = [NSString stringWithFormat:@"x %@",goodsModel.goodsNumber];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(actionTap)];
    [self addGestureRecognizer:tap];
    
}

- (void)actionTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(OSSVAccounteOrdereDetaileView:goodsModel:)]) {
        [self.delegate OSSVAccounteOrdereDetaileView:self goodsModel:self.goodsModel];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        __weak typeof(self) ws = self;
        ws.backgroundColor = OSSVThemesColors.col_FFFFFF;
        
        YYAnimatedImageView *productImg = [YYAnimatedImageView new];
        productImg.layer.borderWidth = 0.5;
        productImg.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        productImg.contentMode = UIViewContentModeScaleAspectFill;
        productImg.clipsToBounds = YES;
        [ws addSubview:productImg];
        
        [productImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(ws.mas_leading).offset(14);
            make.top.mas_equalTo(ws.mas_top).offset(8);
            make.height.mas_equalTo(@96);
            make.width.mas_equalTo(@72);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-8);
        }];
        self.productImg = productImg;
        
        UILabel *productName = [UILabel new];
        productName.numberOfLines = 1;
        productName.textAlignment = NSTextAlignmentLeft;

        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            productName.lineBreakMode = NSLineBreakByTruncatingHead;
            productName.textAlignment = NSTextAlignmentRight;
        }
        productName.font = [UIFont systemFontOfSize:12];
        productName.textColor = [OSSVThemesColors col_6C6C6C];
        
        [ws addSubview:productName];
        
        [productName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(productImg.mas_top);
            make.leading.mas_equalTo(productImg.mas_trailing).offset(8);
            make.trailing.mas_equalTo(ws.mas_trailing).offset(-14);
        }];
        self.productName = productName;
        
        UILabel *productSize = [UILabel new];
        productSize.font = [UIFont boldSystemFontOfSize:12];
        productSize.textColor = [OSSVThemesColors col_6C6C6C];
        [ws addSubview:productSize];
        
        [productSize mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(productName.mas_bottom).offset(3);
            make.leading.mas_equalTo(productName.mas_leading);
        }];
        self.productSize = productSize;
        
        //仓库名称
        UILabel *wareName = [UILabel new];
        wareName.font = [UIFont systemFontOfSize:11];
        wareName.textColor = OSSVThemesColors.col_24A600;
        wareName.backgroundColor = OSSVThemesColors.col_E1F2DA;
        [ws addSubview:wareName];
        [wareName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(productSize.mas_leading);
            make.top.mas_equalTo(productSize.mas_bottom).offset(5);
        }];
        self.wareHouseName = wareName;
        self.wareHouseName.hidden = YES;
        
        UILabel *productPrice = [UILabel new];
        productPrice.font = [UIFont boldSystemFontOfSize:14];
        productPrice.textColor = [OSSVThemesColors col_0D0D0D];
        [ws addSubview:productPrice];
        
        [productPrice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(productImg.mas_bottom);
            make.leading.mas_equalTo(productSize.mas_leading);
        }];
        self.productPrice = productPrice;
        
        UILabel *productNum = [UILabel new];
        productNum.font = [UIFont systemFontOfSize:14];
        productNum.textColor = [OSSVThemesColors col_0D0D0D];
        [ws addSubview:productNum];
        
        [productNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(productPrice.mas_centerY);
            make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
        }];
        self.productNum = productNum;
    }
    return self;
}

@end
