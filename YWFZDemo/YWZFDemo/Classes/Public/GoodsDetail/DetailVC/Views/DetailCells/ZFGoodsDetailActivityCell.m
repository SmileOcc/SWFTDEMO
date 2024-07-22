//
//  ZFGoodsDetailActivityCell.m
//  ZZZZZ
//
//  Created by YW on 2019/7/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsDetailActivityCell.h"
#import "GoodsDetailModel.h"
#import "ZFCountDownView.h"
#import "NSDate+ZFExtension.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ExchangeManager.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFGoodsDetailGroupBuyModel.h"
#import "ZFGoodsDetailActivityTimeView.h"
#import "ZFFrameDefiner.h"
#import "ZFGoodsDetailEnumDefiner.h"

@interface ZFGoodsDetailActivityCell ()
@property (nonatomic, strong) UILabel               *priceLabel;
@property (nonatomic, strong) UIButton              *activityButton;
@property (nonatomic, strong) ZFGoodsDetailActivityTimeView      *timeView;
@property (nonatomic, strong) YYAnimatedImageView   *activityIconView;
@end


@implementation ZFGoodsDetailActivityCell

@synthesize cellTypeModel = _cellTypeModel;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    [self.contentView addSubview:self.priceLabel];
    [self.contentView addSubview:self.activityButton];
}

- (void)zfAutoLayoutView {
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.top.mas_equalTo(2);
    }];
    
    [self.activityButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.priceLabel.mas_bottom);
        make.leading.equalTo(self.priceLabel.mas_leading);
    }];
}

#pragma mark - Setter

- (void)setCellTypeModel:(ZFGoodsDetailCellTypeModel *)cellTypeModel {
    _cellTypeModel = cellTypeModel;
    
    self.contentView.backgroundColor = ZFC0xFF827A();
    [self.timeView removeFromSuperview];
    [self.activityIconView removeFromSuperview];
    
    self.priceLabel.text = [ExchangeManager transforPrice:cellTypeModel.detailModel.activityModel.price];
    self.priceLabel.hidden = NO;
    self.activityButton.hidden = NO;
    
    /**
     * v3.6.0 (预秒杀/秒杀)>新人专享>活动氛围 type返回1，2，3则是预秒杀,秒杀，新人专享,如果返回不是1，2，3则判断是否有配置活动氛围,有就显示.不然就不显示. modify by HYZ 20180726
     * V4.5.1 拼团优先级最高-> 拼团 > (预秒杀/秒杀) > 新人专享 > 活动氛围
     */
    if (cellTypeModel.detailModel.activityModel.type == GoodsDetailActivityTypeFlashing) { // 秒杀进行时
        self.contentView.backgroundColor = ZFCOLOR(255, 54, 95, 1);
        self.timeView.countDownCompleteBlock = ^{
            if (cellTypeModel.detailCellActionBlock) {
                cellTypeModel.detailCellActionBlock(cellTypeModel.detailModel, @(ActivityCountDownCompleteActionType), nil);
            }
        };
        [self.contentView addSubview:self.timeView];
        self.timeView.activityModel = cellTypeModel.detailModel.activityModel;
        [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.trailing.mas_equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(110, 52));
        }];
        
        // Flash Sale
        [self.activityButton setTitle:ZFLocalizedString(@"ListTimeCountDown_Tip", nil) forState:UIControlStateNormal];
        [self.activityButton setImage:ZFImageWithName(@"count_down_clock") forState:UIControlStateNormal];
        self.activityButton.imageEdgeInsets = UIEdgeInsetsMake(10, -6, -10, 0);
        self.activityButton.titleLabel.font = ZFFontSystemSize(18);
        [self.activityButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(7);
            make.leading.mas_equalTo(16);
        }];
        
        
        self.priceLabel.hidden = NO;
        self.priceLabel.text = nil;
        self.priceLabel.attributedText = cellTypeModel.detailModel.activityModel.flashingTotalText;
        [self.priceLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.activityButton.mas_bottom).offset(-2);
            make.leading.mas_equalTo(self.activityButton.mas_leading).offset(22);
        }];
        
    } else if (cellTypeModel.detailModel.activityModel.type == GoodsDetailActivityTypeFlashNotice){ // 秒杀预告
        self.contentView.backgroundColor = ZFCOLOR(255, 54, 95, 1);
        self.timeView.countDownCompleteBlock = ^{
            if (cellTypeModel.detailCellActionBlock) {
                cellTypeModel.detailCellActionBlock(cellTypeModel.detailModel, @(ActivityCountDownCompleteActionType), nil);
            }
        };
        [self.contentView addSubview:self.timeView];
        [self.timeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.trailing.mas_equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(142, 52));
        }];
        
        self.timeView.activityModel = cellTypeModel.detailModel.activityModel;
        [self.activityButton setImage:ZFImageWithName(@"clock") forState:UIControlStateNormal];
        [self.activityButton setTitle:ZFLocalizedString(@"ListTimeCountDown_Tip", nil) forState:UIControlStateNormal];
        self.activityButton.titleLabel.font = ZFFontSystemSize(12);
        self.activityButton.imageEdgeInsets = UIEdgeInsetsMake(0, -6, 0, 0);
        
    } else if (cellTypeModel.detailModel.activityModel.type == GoodsDetailActivityTypeNewMember){ // 新人专享价
        [self.activityButton setImage:ZFImageWithName(@"GoodsDetail_newMember") forState:UIControlStateNormal];
        [self.activityButton setTitle:ZFLocalizedString(@"new_member", nil) forState:UIControlStateNormal];
        
    } else { // 活动氛围
        if (!ZFIsEmptyString(cellTypeModel.detailModel.activityIconModel.activityIcon)) {
            [self.contentView addSubview:self.activityIconView];
            [self.activityIconView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(self.contentView);
            }];
            [self.activityIconView yy_setImageWithURL:[NSURL URLWithString:cellTypeModel.detailModel.activityIconModel.activityIcon]
                                          placeholder:ZFImageWithName(@"index_loading")
                                              options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                           completion:nil];
            
            self.contentView.backgroundColor = [UIColor clearColor];
            self.priceLabel.hidden = YES;
            self.activityButton.hidden = YES;
        }
    }
}

#pragma mark - Getter
- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = ZFFontSystemSize(24);
        _priceLabel.textColor = ZFC0xFFFFFF();
        _priceLabel.backgroundColor = ZFCClearColor();
        _priceLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _priceLabel;
}

- (UIButton *)activityButton {
    if (!_activityButton) {
        _activityButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _activityButton.backgroundColor = ZFCClearColor();
        [_activityButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        _activityButton.titleLabel.font = ZFFontSystemSize(14);
        _activityButton.adjustsImageWhenHighlighted = NO;
    }
    return _activityButton;
}

- (ZFGoodsDetailActivityTimeView *)timeView {
    if (!_timeView) {
        _timeView = [[ZFGoodsDetailActivityTimeView alloc] init];
    }
    return _timeView;
}

- (YYAnimatedImageView *)activityIconView {
    if (!_activityIconView) {
        _activityIconView = [[YYAnimatedImageView alloc] init];
        _activityIconView.contentMode = UIViewContentModeScaleAspectFill;
        _activityIconView.clipsToBounds  = YES;
        @weakify(self);
        [_activityIconView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.cellTypeModel.detailCellActionBlock) {
                self.cellTypeModel.detailCellActionBlock(self.cellTypeModel.detailModel, @(ActivityTapImageViewActionType), self.cellTypeModel.detailModel);
            }
        }];
    }
    return _activityIconView;
}

@end
