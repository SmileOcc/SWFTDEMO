//
//  OSSVCategoryssCCell.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCategoryssCCell.h"
#import "OSSVSecondsCategorysModel.h"

@interface OSSVCategoryssCCell ()

@end


@implementation OSSVCategoryssCCell

#pragma mark  - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [OSSVThemesColors stlWhiteColor];
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.titlesLabel];
        
        CGFloat imageWidth = (SCREEN_WIDTH - 105 - 12 * 2 - 14*2 - 8*2)/3;
        if (APP_TYPE == 3) {
            imageWidth = (SCREEN_WIDTH - 105 - 12 * 2 - 8 )/2.0;
        }
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top);
            make.leading.mas_equalTo(self.contentView.mas_leading);
            make.trailing.mas_equalTo(self.contentView.mas_trailing);
            make.width.mas_equalTo(imageWidth);
            make.height.mas_equalTo(imageWidth);
        }];
        
        
        [self.titlesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self.imageView);
            make.top.equalTo(self.imageView.mas_bottom).offset(4);
            make.height.mas_greaterThanOrEqualTo(36);
        }];
                
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageView.imageView yy_cancelCurrentImageRequest];
    self.imageView.imageView.image = nil;
    self.titlesLabel.text = nil;
}


#pragma mark - LazyLoad setters and getters

- (void)setCategoryChildModel:(OSSVCatagorysChildModel *)categoryChildModel {
    if (!categoryChildModel) {
        self.imageView.hidden = YES;
        self.titlesLabel.hidden = YES;
        return;
    }
    self.imageView.hidden = NO;
    self.titlesLabel.hidden = NO;
    self.imageView.imageView.hidden = NO;
    self.imageView.grayView.hidden = YES;
    
    [self.imageView.imageView yy_setImageWithURL:[NSURL URLWithString:categoryChildModel.img_addr]
                           placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                               options:kNilOptions
                              progress:nil
                             transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
        
                                    return image;
                             }
                                      completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
    }];
    
    if (categoryChildModel.isViewAll) {
        if (STLIsEmptyString(categoryChildModel.img_addr)) {
            self.imageView.placeImageView.hidden = NO;
            self.imageView.placeImageView.image = [UIImage imageNamed:@"category_yijia"];
            self.imageView.grayView.backgroundColor = [OSSVThemesColors col_FAFAFA];
            self.imageView.imageView.hidden = YES;
            self.imageView.grayView.hidden = NO;
        } else {
            self.imageView.placeImageView.hidden = YES;
        }

    } else {
        self.imageView.placeImageView.hidden = YES;
        self.imageView.grayView.backgroundColor = [OSSVThemesColors col_EEEEEE];

    }


    self.titlesLabel.text = [NSString stringWithFormat:@"%@",categoryChildModel.cat_name];
}

- (STLProductImagePlaceholder *)imageView {
    
    if (!_imageView) {
        _imageView = [[STLProductImagePlaceholder alloc] initWithFrame:CGRectZero isCategory:YES];
        _imageView.backgroundColor = [UIColor whiteColor];
        _imageView.imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.imageView.backgroundColor = [OSSVThemesColors stlWhiteColor];
//        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (YYLabel *)titlesLabel {
    
    if (!_titlesLabel) {
        _titlesLabel = [[YYLabel alloc] initWithFrame:CGRectZero];
        _titlesLabel.backgroundColor = [UIColor whiteColor];
        _titlesLabel.numberOfLines = 2;
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            _titlesLabel.textAlignment = NSTextAlignmentRight;
//
//        } else {
//            _titlesLabel.textAlignment = NSTextAlignmentLeft;
//        }
        _titlesLabel.textAlignment = NSTextAlignmentCenter;
        _titlesLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titlesLabel.font = [UIFont systemFontOfSize:12];
        _titlesLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _titlesLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
    }
    return _titlesLabel;
}
@end
