//
//  OSSVCartTableMayLikeHeaderView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartTableMayLikeHeaderView.h"

@implementation OSSVCartTableMayLikeHeaderView

+ (OSSVCartTableMayLikeHeaderView *)cartHeaderViewWithTableView:(UITableView *)tableView {
    [tableView registerClass:[OSSVCartTableMayLikeHeaderView class] forHeaderFooterViewReuseIdentifier:@"OSSVCartTableMayLikeHeaderView"];
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"OSSVCartTableMayLikeHeaderView"];
}

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {

        [self addSubview:self.bgView];
        [self addSubview:self.goodsImgView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.lineView];

        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.bottom.top.mas_equalTo(self);
        }];
        
        [self.goodsImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
            make.top.mas_equalTo(self.mas_top).mas_offset(7);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-7);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.goodsImgView.mas_trailing).mas_offset(12);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
            make.top.bottom.mas_equalTo(self.bgView);
        }];
        
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mas_leading);
            make.trailing.mas_equalTo(self.mas_trailing);
            make.bottom.mas_equalTo(self.mas_bottom);
            make.height.mas_equalTo(@(0.5));
        }];
    }
    return self;
}

- (void)updateImage:(NSString *)imgUrl title:(NSString *)title {
    
    self.titleLabel.text = STLToString(title);
    self.goodsImgView.hidden = [OSSVNSStringTool isEmptyString:imgUrl] ? YES : NO;
    [self.goodsImgView yy_setImageWithURL:[NSURL URLWithString:imgUrl]
                              placeholder:[UIImage imageNamed:@"ProductImageLogo"]
                                  options:kNilOptions
                                 progress:nil
                                transform:^UIImage * _Nullable(UIImage * _Nonnull image, NSURL * _Nonnull url) {
                                    image = [image yy_imageByResizeToSize:CGSizeMake(40, 40) contentMode:UIViewContentModeScaleAspectFill];
                                    return image;
                                }
                               completion:nil];
}


#pragma mark - LazyLoad

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = OSSVThemesColors.col_FFFFFF;
    }
    return _bgView;
}

- (YYAnimatedImageView *)goodsImgView {
    if (!_goodsImgView) {
        _goodsImgView = [[YYAnimatedImageView alloc] initWithFrame:CGRectZero];
        _goodsImgView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImgView.clipsToBounds = YES;

    }
    return _goodsImgView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 2;
        _titleLabel.font = [UIFont boldSystemFontOfSize:13];
        _titleLabel.textColor = OSSVThemesColors.col_FF9522;
        //_titleLabel.text = STLLocalizedString_(@"mayLike",nil);
    }
    return _titleLabel;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor = [OSSVThemesColors col_EEEEEE];
    }
    return _lineView;
}
@end
