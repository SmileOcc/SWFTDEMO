//
//  ZFCartDiscountHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2019/4/26.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCartDiscountHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCartGoodsListModel.h"
#import "UILabel+HTML.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCartDiscountHeaderView () <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView           *iconImageView;
@property (nonatomic, strong) UILabel               *discountTipsLabel;
@property (nonatomic, strong) UIButton              *nextButton;
@property (nonatomic, strong) UIView                *emptyView;

@end

@implementation ZFCartDiscountHeaderView
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
//}

- (void)addTapGestureBock {
    @weakify(self);
    [self addTapGestureWithComplete:^(UIView * _Nonnull view) {
        @strongify(self);
        if (![NSStringUtils isEmptyString:self.model.url]) {
            if (self.cartDiscountTopicJumpCompletionHandler) {
                self.cartDiscountTopicJumpCompletionHandler();
            }
        } else {
            if (!ZFIsEmptyString(self.model.reduc_id) &&
                !ZFIsEmptyString(self.model.activity_type)) {
                if (self.fullReductionCompletionHandler) { // 满减活动跳转
                    self.fullReductionCompletionHandler(self.model.reduc_id, self.model.activity_type, self.model.activity_title);
                }
            }
        }
    }];
}

#pragma mark - action methods
- (void)nextButtonAction:(UIButton *)sender {
    if (self.cartDiscountTopicJumpCompletionHandler && ![NSStringUtils isEmptyString:self.model.url]) {
        self.cartDiscountTopicJumpCompletionHandler();
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFC0xF2F2F2();
    [self.contentView addSubview:self.emptyView];
    [self.contentView addSubview:self.iconImageView];
    [self.contentView addSubview:self.discountTipsLabel];
    [self.contentView addSubview:self.nextButton];
}

- (void)zfAutoLayoutView {
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY).offset(4);
        make.leading.mas_equalTo(self.contentView.mas_leading).offset(12);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    
    [self.discountTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.iconImageView.mas_trailing).offset(4);
        make.centerY.mas_equalTo(self.iconImageView.mas_centerY);
    }];
    
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.iconImageView.mas_centerY);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.size.mas_equalTo(CGSizeMake(7, 10));
    }];
    
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.mas_equalTo(self.contentView);
    }];
}

#pragma mark - setter
- (void)setModel:(ZFCartGoodsListModel *)model {
    _model = model;
//    [self.discountTipsLabel zf_setHTMLFromString:_model.msg];
    
    self.discountTipsLabel.attributedText = nil;
    NSString *name = self.discountTipsLabel.font.fontName;
    CGFloat pointSize = self.discountTipsLabel.font.pointSize;
    
    // 使用 NSHTMLTextDocumentType 时，要在子线程初始化，在主线程赋值，否则会不定时出现 webthread crash
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (model.headerHtmlAttr) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.discountTipsLabel.attributedText = model.headerHtmlAttr;
            });
        } else {
            NSAttributedString *htmlAttr = [model configHeaderHtmlAttr:name fontSize:pointSize];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.discountTipsLabel.attributedText = htmlAttr;
                if (htmlAttr && self.refreshHandler) { //设置完html后一定要反向刷新Cell否则会出现Cell重用问题
                    self.refreshHandler();
                }
            });
        }
    });
    self.discountTipsLabel.textAlignment = NSTextAlignmentLeft;
    
    if (![NSStringUtils isEmptyString:self.model.url]) {
        self.nextButton.hidden = NO;
        
    } else if(!ZFIsEmptyString(self.model.reduc_id) &&
              !ZFIsEmptyString(self.model.activity_type)) {
        self.nextButton.hidden = NO;
        
    } else {
        self.nextButton.hidden = YES;
    }
}

#pragma mark - getter
- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"off_tag"]];
    }
    return _iconImageView;
}

- (UILabel *)discountTipsLabel {
    if (!_discountTipsLabel) {
        _discountTipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _discountTipsLabel.font = [UIFont systemFontOfSize:14];
        _discountTipsLabel.preferredMaxLayoutWidth = KScreenWidth - 67;
        _discountTipsLabel.numberOfLines = 2;
        [_discountTipsLabel sizeToFit];
        _discountTipsLabel.textColor = ZFCOLOR_BLACK;
        _discountTipsLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _discountTipsLabel;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *arrowIImage = [UIImage imageNamed:@"next-right"];
        [_nextButton setImage:arrowIImage forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_nextButton convertUIWithARLanguage];
    }
    return _nextButton;
}

- (UIView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] initWithFrame:CGRectZero];
        _emptyView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _emptyView;
}
@end
