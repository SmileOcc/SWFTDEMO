//
//  ZFCartFreeGiftHearderView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCartFreeGiftHearderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFCartGoodsListModel.h"
#import "YWCFunctionTool.h"
#import "ExchangeManager.h"
#import "UIImage+ZFExtended.h"
#import "NSStringUtils.h"

@interface ZFCartFreeGiftHearderView() <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView           *iconImageView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UILabel               *accessoryLabel;
@property (nonatomic, strong) UIImageView           *arrowImageView;
@property (nonatomic, strong) UIView                *emptyView;

@end

@implementation ZFCartFreeGiftHearderView
#pragma mark - init methods
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addTapGestureBock];
    }
    return self;
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    [self addTopLeftRightCorners];
//}
//
//- (void)addTopLeftRightCorners {
//    [self.emptyView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];
//
//}

- (void)addTapGestureBock {
    @weakify(self);
    [self.contentView addTapGestureWithComplete:^(UIView * _Nonnull view) {
        @strongify(self);
        if (self.cartFreeGiftActionCompltionHandler) {
            self.cartFreeGiftActionCompltionHandler();
        }
    }];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFC0xF2F2F2();
    [self.contentView addSubview:self.emptyView];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.accessoryLabel];
    [self.contentView addSubview:self.arrowImageView];
}

- (void)zfAutoLayoutView {
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(4);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.size.mas_equalTo(CGSizeMake(7, 10));
    }];
    
    [self.accessoryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.arrowImageView.mas_leading).offset(-6);
        make.centerY.mas_equalTo(self.arrowImageView.mas_centerY);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconImageView.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.accessoryLabel.mas_leading).offset(-3);;
        make.centerY.mas_equalTo(self.iconImageView.mas_centerY);
    }];
    
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.mas_equalTo(self.contentView);
    }];
    
    [self.titleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow
                                           forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow
                                                         forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - setter
- (void)setModel:(ZFCartGoodsListModel *)model {
    _model = model;
    self.titleLabel.attributedText = model.freeGiftHeaderAttrText;
    
//    if (!ZFIsEmptyString(model.diff_msg) && !ZFIsEmptyString(model.diff_amount)) {
//        NSString *replaceStr = @"$diff_amount";
//        if ([model.diff_msg containsString:replaceStr]) {
//            NSString *locationPrice = [ExchangeManager transforPrice:model.diff_amount];
//            NSString *convertPrice = [model.diff_msg stringByReplacingOccurrencesOfString:replaceStr withString:locationPrice];
//            self.subTitleLabel.text = ZFToString(convertPrice);
//            self.subTitleLabel.hidden = NO;
//        }
//    }
    CGFloat offsetY = (model.cartList.count == 0) ? 8 : 0;
    [self.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(offsetY);
    }];
}

#pragma mark - getter
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.image = [UIImage imageNamed:@"free_gift_icon"];
        _iconImageView.userInteractionEnabled = YES;
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.preferredMaxLayoutWidth = KScreenWidth - 160;
        _titleLabel.numberOfLines = 0;
        _titleLabel.textColor = ZFCOLOR_BLACK;
        _titleLabel.text = ZFLocalizedString(@"FreeGift", nil);
    }
    return _titleLabel;
}

- (UILabel *)accessoryLabel {
    if (!_accessoryLabel) {
        _accessoryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _accessoryLabel.font = [UIFont systemFontOfSize:14];
        _accessoryLabel.textColor = ZFC0xFE5269();
        _accessoryLabel.text = [NSStringUtils firstCharactersCapitalized:ZFLocalizedString(@"CarVC_more_gift", nil)];
        _accessoryLabel.numberOfLines = 0;
        _accessoryLabel.textAlignment = NSTextAlignmentRight;
    }
    return _accessoryLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowImageView.image = [[UIImage imageNamed: @"next-right"] imageWithColor:ZFC0xFE5269()];
        _arrowImageView.userInteractionEnabled = YES;
        [_arrowImageView convertUIWithARLanguage];
    }
    return _arrowImageView;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectZero];
        _emptyView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _emptyView;
}
@end
