//
//  OSSVCheckOutProductCollectionCell.m
// XStarlinkProject
//
//  Created by fan wang on 2021/8/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVCheckOutProductCollectionCell.h"


@implementation OSSVCheckOutProductCollectionCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self.contentView addSubview:self.prodcutImage];
        [self.contentView addSubview:self.countLabel];
        
        [self.contentView addSubview:self.markView];
        [self.markView addSubview:self.stateLabel];
        
        [self.prodcutImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.width.mas_offset(72);
            if (APP_TYPE == 3) {
                make.height.mas_equalTo(72);
            } else {
                make.height.mas_offset(96);
            }
            make.bottom.equalTo(0);
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            if (APP_TYPE == 3) {
                make.leading.trailing.top.bottom.mas_equalTo(self.prodcutImage);
            } else {
                make.leading.trailing.bottom.mas_equalTo(self.prodcutImage);
                make.height.mas_offset(16);

            }
        }];
        
        [self.markView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.prodcutImage);
        }];
        
        [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.countLabel.mas_top).offset(-2);
            make.leading.mas_equalTo(self.markView.mas_leading).offset(4);
            make.trailing.mas_equalTo(self.markView.mas_trailing).offset(-4);
        }];
        
        UIImageView *stateImage = [[UIImageView alloc] init];
        stateImage.image = [UIImage imageNamed:@"goods_hanger"];
        [self.markView addSubview:stateImage];
        self.stateImageView = stateImage;
        [stateImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.stateLabel.mas_top).offset(-8);
            make.centerX.mas_equalTo(self.markView.mas_centerX);
            make.width.height.equalTo(24);
        }];
        
        
    }
    return self;
}

#pragma mark - setter and getter

-(void)setGoodsModel:(OSSVCartGoodsModel *)goodsModel {
    _goodsModel = goodsModel;
    [self.prodcutImage yy_setImageWithURL:[NSURL URLWithString:goodsModel.goodsThumb]
                              placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                  options:kNilOptions
                               completion:nil];
    self.countLabel.text = [NSString stringWithFormat:@"x %ld", (long)goodsModel.goodsNumber];
}

- (UIImageView *)prodcutImage {
    if (!_prodcutImage) {
        _prodcutImage = ({
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            if (APP_TYPE != 3) {
                imageView.layer.masksToBounds = true;
                imageView.layer.borderWidth = 0.5*kScale_375;
                imageView.layer.borderColor = [OSSVThemesColors col_EEEEEE].CGColor;
            }
            imageView;
        });
    }
    return _prodcutImage;
}

-(UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentCenter;
            if (APP_TYPE == 3) {
                label.textColor = OSSVThemesColors.col_0D0D0D;
                label.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];

            } else {
                label.textColor = [UIColor whiteColor];
                label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
            }
            label.font = [UIFont boldSystemFontOfSize:10];
            label;
        });
    }
    return _countLabel;
}

- (UIView *)markView {
    if (!_markView) {
        _markView = [[UIView alloc] initWithFrame:CGRectZero];
        _markView.backgroundColor = [OSSVThemesColors col_0D0D0D:0.3];
        _markView.hidden = YES;
    }
    return _markView;
}

- (UILabel *)stateLabel {
    if (!_stateLabel) {
        _stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _stateLabel.textColor = [OSSVThemesColors stlWhiteColor];
        _stateLabel.font = [UIFont boldSystemFontOfSize:12];
        _stateLabel.textAlignment = NSTextAlignmentCenter;
        _stateLabel.text = STLLocalizedString_(@"Goods_Unavailable", nil);
        _stateLabel.numberOfLines = 0;
    }
    return _stateLabel;
}

@end
