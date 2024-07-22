//
//  ZFCMSNormalBannerCell.m
//  ZZZZZ
//
//  Created by YW on 2018/12/10.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFCMSNormalBannerCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFCMSSectionModel.h"
#import "ZFBannerTimeView.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIImage+ZFExtended.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCMSNormalBannerCell ()<ZFInitViewProtocol>
@property (nonatomic, strong) ZFBannerTimeView      *countDownView;
@property (nonatomic, strong) YYAnimatedImageView   *bannerImageView;

// 用到倒计时才需要赋值该模型
@property (nonatomic, strong) ZFCMSAttributesModel *cmsAttributes;
@property (nonatomic, assign) CGFloat              currentCellHeight;
@end

@implementation ZFCMSNormalBannerCell

+ (ZFCMSNormalBannerCell *)reusableNormalBannerCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

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
    [self.bannerImageView yy_cancelCurrentImageRequest];
    self.bannerImageView.image = nil;
}

- (void)updateCmsAttributes:(ZFCMSAttributesModel *)cmsAttributes cellHeight:(CGFloat)height {
    if (height > 0) {
        self.currentCellHeight = height;
    }
    self.cmsAttributes = cmsAttributes;
    
}
#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.bannerImageView];
}

- (void)zfAutoLayoutView {
    [self.bannerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.edges.equalTo(self.contentView).insets(UIEdgeInsetsZero);
        // 为什么需要偏出Cell上下左右0.5: 是因为解决多分管时可能会导致在滑动时出现白色细线的问题 V5.0.0-modify: mwx
        make.top.mas_equalTo(self.contentView.mas_top).offset(-MIN_PIXEL);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(-MIN_PIXEL);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(MIN_PIXEL);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).offset(MIN_PIXEL);
    }];
}

#pragma mark - Setter
/**
 * 设置背景颜色
 */
- (void)setCellBackgroundColor:(UIColor *)cellBackgroundColor {
    _cellBackgroundColor = cellBackgroundColor;
    self.contentView.backgroundColor = cellBackgroundColor;
}

- (void)setItemModel:(ZFCMSItemModel *)itemModel {
    _itemModel = itemModel;
    
    [self.bannerImageView yy_setImageWithURL:[NSURL URLWithString:itemModel.image]
                                 placeholder:[UIImage imageNamed:@"index_banner_loading"]
                                     options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                    progress:nil
                                   transform:^UIImage *(UIImage *image, NSURL *url) {
                                       if ([image isKindOfClass:[YYImage class]]) {
                                           YYImage *showImage = (YYImage *)image;
                                           if (showImage.animatedImageType == YYImageTypeGIF || showImage.animatedImageData) {
                                               return image;
                                           }
                                       }
                                       return [image zf_drawImageToOpaque];
                                       
                                   } completion:nil];
}

/**
 * 用到倒计时才需要赋值该模型
 * 倒计时对齐样式模型
 */
- (void)setCmsAttributes:(ZFCMSAttributesModel *)cmsAttributes
{
    if ([_cmsAttributes isEqual:cmsAttributes]) {
        return;
    }
    
    _cmsAttributes = cmsAttributes;
    if (_countDownView) {
        self.countDownView.hidden = YES;
    }
    unsigned long long timcountdownTime = [self.itemModel.countdown_time longLongValue];
    if (timcountdownTime > 0 && !ZFIsEmptyString(self.itemModel.countDownCMSTimerKey)) {
       // CGFloat h = CGRectGetHeight(self.contentView.frame); 计算不准
        if (self.currentCellHeight < 20) return;

        YWLog(@"更新配置倒计时位置1===%@", cmsAttributes.countdown_align);
        self.countDownView.hidden = NO;
        // 配置文案对齐位置
        [self layoutCountDownModulePosition];
        //开启倒计时任务
        [self.countDownView startCountDownTimerStamp:self.itemModel.countdown_time withTimerKey:self.itemModel.countDownCMSTimerKey];
    }
}

// 配置倒计时 文案对齐位置
- (void)layoutCountDownModulePosition {
    NSString *textAlignType = self.cmsAttributes.countdown_align;
    ZFCMSModulePosition position = [textAlignType integerValue];
    
    if (ZFIsEmptyString(textAlignType) || [textAlignType isEqualToString:@"0"]) {
        position = ZFCMSModulePositionCenter;
    }
    
    switch (position) {
        case ZFCMSModulePositionTopLeft: {
            [self.countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.mas_top).offset(self.cmsAttributes.countdown_padding_top);
                make.left.mas_equalTo(self.contentView.mas_left).offset(self.cmsAttributes.countdown_padding_left);
            }];
        }
            break;
        case ZFCMSModulePositionTopCenter: {
            [self.countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.mas_top).offset(self.cmsAttributes.countdown_padding_top);
                make.centerX.mas_equalTo(self.contentView.mas_centerX);
            }];
        }
            break;
        case ZFCMSModulePositionTopRight: {
            [self.countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView.mas_top).offset(self.cmsAttributes.countdown_padding_top);
                make.right.mas_equalTo(self.contentView.mas_right).offset(-self.cmsAttributes.countdown_padding_right);
            }];
        }
            break;
        case ZFCMSModulePositionCenterLeft: {
            [self.countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.left.mas_equalTo(self.contentView.mas_left).offset(self.cmsAttributes.countdown_padding_left);
            }];
        }
            break;
        case ZFCMSModulePositionCenter: {
            [self.countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.centerX.mas_equalTo(self.contentView.mas_centerX);
            }];
        }
            break;
        case ZFCMSModulePositionCenterRight: {
            [self.countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.right.mas_equalTo(self.contentView.mas_right).offset(-self.cmsAttributes.countdown_padding_right);
            }];
        }
            break;
        case ZFCMSModulePositionBottomLeft: {
            [self.countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-self.cmsAttributes.countdown_padding_bottom);
                make.left.mas_equalTo(self.contentView.mas_left).offset(self.cmsAttributes.countdown_padding_left);
            }];
        }
            break;
        case ZFCMSModulePositionBottomCenter: {
            [self.countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-self.cmsAttributes.countdown_padding_bottom);
                make.centerX.mas_equalTo(self.contentView.mas_centerX);
            }];
        }
            break;
        case ZFCMSModulePositionBottomRight: {
            [self.countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.contentView.mas_bottom).offset(-self.cmsAttributes.countdown_padding_bottom);
                make.right.mas_equalTo(self.contentView.mas_right).offset(-self.cmsAttributes.countdown_padding_right);
            }];
        }
            break;
        default: // 默认倒计时位置为: 上下左右居中
            [self.countDownView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView.mas_centerY);
                make.centerX.mas_equalTo(self.contentView.mas_centerX);
            }];
            break;
    }
}

#pragma mark - Getter

- (YYAnimatedImageView *)bannerImageView {
    if (!_bannerImageView) {
        _bannerImageView = [YYAnimatedImageView new];
        _bannerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bannerImageView.clipsToBounds  = YES;
    }
    return _bannerImageView;
}

- (ZFBannerTimeView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[ZFBannerTimeView alloc] init];
        [self.contentView addSubview:_countDownView];
    }
    return _countDownView;
}

@end
