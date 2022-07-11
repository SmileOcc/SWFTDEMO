//
//  OSSVReviewssGoodssCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVReviewssGoodssCell.h"

@implementation OSSVReviewssGoodssCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.goodsImgView];
        [self.contentView addSubview:self.titleLab];
        [self.contentView addSubview:self.skuLab];
        [self.contentView addSubview:self.reviewButton];
//        [self.contentView addSubview:self.lineView];
        self.contentView.layer.cornerRadius = 6;
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.whiteColor;
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(UIEdgeInsetsMake(8, 12, 0, 12));
        }];
        
        [self.goodsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(14);
            make.top.mas_equalTo(self.contentView.mas_top).mas_offset(14);
            make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_offset(-14);
            make.width.mas_equalTo(60);
            make.height.mas_equalTo(80);
        }];
        
        [self.titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.goodsImgView.mas_top);
            make.leading.mas_equalTo(self.goodsImgView.mas_trailing).mas_offset(12);
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-16);
        }];
        
        [self.skuLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleLab.mas_bottom).mas_offset(5);
            make.leading.mas_equalTo(self.titleLab.mas_leading);
        }];
        
        [self.reviewButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-14);
            make.bottom.mas_equalTo(self.goodsImgView.mas_bottom);
            make.height.equalTo(28);
        }];
        
//        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.imageView.mas_bottom).mas_offset(16);
//            make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(16);
//            make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-16);
//            make.bottom.mas_equalTo(self.contentView.mas_bottom);
//            make.height.mas_equalTo(0.5);
//        }];
    }
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setModel:(OSSVAccounteOrdersDetaileGoodsModel *)model {
    _model = model;
    

    [self.goodsImgView yy_setImageWithURL:[NSURL URLWithString:model.goodsThumb]
                              placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                  options:kNilOptions
                                 progress:nil
                                transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
        return image;
                                }
                               completion:nil];
    
    self.titleLab.text = _model.goodsName;
    self.skuLab.text = _model.goodsAttr;
    
    if (_model.isReview == 1) {
        [_reviewButton setTitleColor:[OSSVThemesColors col_333333] forState:UIControlStateNormal];
        _reviewButton.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        _reviewButton.backgroundColor = [UIColor clearColor];
        [_reviewButton setTitle:STLLocalizedString_(@"checkMyReview", nil).uppercaseString forState:UIControlStateNormal];
    } else {
        _reviewButton.backgroundColor = [OSSVThemesColors col_262626];
        _reviewButton.layer.borderColor = [OSSVThemesColors col_262626].CGColor;
        [_reviewButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        [_reviewButton setTitle:STLLocalizedString_(@"writeReview", nil).uppercaseString forState:UIControlStateNormal];
    }
    
}
- (void)testModel {
    NSString *imgStr = @"https://gloimg.adorawe.com/adorawe/pdm-product-pic/Clothing/2016/08/30/grid-img/1477848722807801578.jpg";
    
    [self.goodsImgView yy_setImageWithURL:[NSURL URLWithString:imgStr]
                     placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                         options:kNilOptions
                        progress:nil
                       transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
        return image;
                       }
                      completion:nil];
    
    self.titleLab.text = @"测试视频视频饰品店的白色的沙发尅一超市";
    self.skuLab.text = @"sku/白色、高亮";
    
    if (self.model.isReview) {
        _reviewButton.layer.borderColor = [OSSVThemesColors col_CCCCCC].CGColor;
        _reviewButton.backgroundColor = [UIColor clearColor];
        [_reviewButton setTitleColor:[OSSVThemesColors col_333333] forState:UIControlStateNormal];
    } else {
        [_reviewButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        _reviewButton.backgroundColor = [OSSVThemesColors col_262626];
        _reviewButton.layer.borderColor = [OSSVThemesColors col_262626].CGColor;
    }
}

#pragma mark -

- (void)actionEvent:(UIButton *)sender {
    if (self.myDelegate && [self.myDelegate respondsToSelector:@selector(STL_ReviewsGoodsCell:flag:)]) {
        [self.myDelegate STL_ReviewsGoodsCell:self flag:YES];
    }
}

#pragma mark - LazyLoad

- (UIImageView *)goodsImgView {
    if (!_goodsImgView) {
        _goodsImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _goodsImgView.layer.borderWidth = 0.5;
        _goodsImgView.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
        _goodsImgView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImgView.layer.masksToBounds = true;
    }
    return _goodsImgView;
}

- (UILabel *)titleLab {
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLab.textColor = [OSSVThemesColors col_6C6C6C];
        _titleLab.font = [UIFont systemFontOfSize:12];
        _titleLab.textAlignment = NSTextAlignmentLeft;
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _titleLab.lineBreakMode = NSLineBreakByTruncatingHead;
            _titleLab.textAlignment = NSTextAlignmentRight;
        }
    }
    return _titleLab;
}

- (UILabel *)skuLab {
    if (!_skuLab) {
        _skuLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _skuLab.textColor = [OSSVThemesColors col_6C6C6C];
        _skuLab.font = [UIFont boldSystemFontOfSize:12];
    }
    return _skuLab;
}

- (UIButton *)reviewButton {
    if (!_reviewButton) {
        _reviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_reviewButton setTitle:@"评论" forState:UIControlStateNormal];
        _reviewButton.titleLabel.font = [UIFont systemFontOfSize:12];
        _reviewButton.layer.cornerRadius = 0;
        _reviewButton.layer.borderWidth = 1;
        _reviewButton.contentEdgeInsets = UIEdgeInsetsMake(6, 12, 6, 12);
        [_reviewButton setTitleColor:[OSSVThemesColors stlWhiteColor] forState:UIControlStateNormal];
        _reviewButton.backgroundColor = [OSSVThemesColors col_0D0D0D];
        _reviewButton.layer.borderColor = [OSSVThemesColors col_0D0D0D].CGColor;
        [_reviewButton addTarget:self action:@selector(actionEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reviewButton;
}

//- (UIView *)lineView {
//    if (!_lineView) {
//        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
//        _lineView.backgroundColor = OSSVThemesColors.col_F1F1F1;
//    }
//    return _lineView;
//}

@end
