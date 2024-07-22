//
//  ZFColorBlockCell.m
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFColorBlockCell.h"
#import "ZFColorDefiner.h"
#import "Masonry.h"
#import "ZFGoodsModel.h"
#import "UIColor+ExTypeChange.h"
#import "YWCFunctionTool.h"
#import "NSStringUtils.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFThemeManager.h"

@interface ZFColorBlockCell ()

@property (nonatomic, strong) UIImageView *colorView;

@end

@implementation ZFColorBlockCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.contentView.layer.borderColor = ZFCOLOR(204, 204, 204, 1.0).CGColor;
    self.contentView.layer.borderWidth = 1;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    [self.contentView addSubview:self.colorView];
}

- (void)zfAutoLayoutView {
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(3, 3, 3, 3));
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.contentView.layer.borderColor = ZFCOLOR(204, 204, 204, 1.0).CGColor;
    self.colorView.backgroundColor = [UIColor clearColor];
    self.colorView.image = nil;
    self.model = nil;
}

- (void)setModel:(ZFGoodsModel *)model indexPath:(NSIndexPath *)indexPath seletedIndex:(NSInteger)seletedIndex {
    _model = model;
    if (seletedIndex == indexPath.item) {
        self.contentView.layer.borderColor = ZFC0x2D2D2D().CGColor;
    } else {
        self.contentView.layer.borderColor = ZFCOLOR(204, 204, 204, 1.0).CGColor;
    }
    self.colorView.backgroundColor = [UIColor colorWithHexString:model.color_code];
    if (![NSStringUtils isEmptyString:model.color_img]) { // 有色块图就显示图片，没有则显示颜色块
        [self.colorView yy_setImageWithURL:[NSURL URLWithString:ZFToString(model.color_img)]
                                       placeholder:nil
                                           options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                        completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                                            
                                        }];
    }
}

- (UIImageView *)colorView {
    if (!_colorView) {
        _colorView = [[UIImageView alloc] init];
        _colorView.contentMode = UIViewContentModeScaleAspectFill;
        _colorView.clipsToBounds = YES;
    }
    return _colorView;
}

@end
