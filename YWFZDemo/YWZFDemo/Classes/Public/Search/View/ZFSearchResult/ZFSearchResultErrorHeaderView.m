//
//  ZFSearchResultErrorHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2018/6/22.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchResultErrorHeaderView.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFThemeManager.h"

@interface ZFSearchResultErrorHeaderView()

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *keywordLabel;

@end

@implementation ZFSearchResultErrorHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.messageLabel];
    [self addSubview:self.keywordLabel];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(self).offset(12.0f);
        make.trailing.mas_equalTo(self).offset(-12.0f);
    }];
    
    [self.keywordLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).offset(12.0f);
        make.top.mas_equalTo(self.messageLabel.mas_bottom).offset(8.0f);
    }];
}

- (void)configWithSearchword:(NSString *)searchword errorKeyword:(NSArray *)keywords {
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[UILabel class]] && subView != self.messageLabel && subView != self.keywordLabel) {
            [subView removeFromSuperview];
        }
    }
    self.messageLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"search_result_matches_tip", nil), searchword];
    NSString *titleString  = ZFLocalizedString(@"search_result_matches_keyword", nil);
    self.keywordLabel.text = titleString;
    UILabel *preLabel = nil;
    for (NSInteger i = 0; i < keywords.count; i++) {
        NSMutableString *keywordString = [NSMutableString new];
        [keywordString appendString:keywords[i]];
        
        UILabel *keyLabel  = [[UILabel alloc] init];
        keyLabel.font      = [UIFont systemFontOfSize:14.0];
        keyLabel.textColor = ZFCThemeColor();
        keyLabel.text      = keywordString;
        keyLabel.userInteractionEnabled = YES;
        [self addSubview:keyLabel];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
        [tapGesture addTarget:self action:@selector(keywordTapAction:)];
        [keyLabel addGestureRecognizer:tapGesture];
        
        if (preLabel == nil) {
            [keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.keywordLabel.mas_top);
                make.bottom.mas_equalTo(self.keywordLabel.mas_bottom);
                make.leading.mas_equalTo(self.keywordLabel.mas_trailing).offset(5.0);
            }];
        } else {
            if ((preLabel.x + preLabel.width) + preLabel.width + 12.0 > KScreenWidth) {
                [keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(preLabel.mas_bottom).offset(8.0);
                    make.height.mas_equalTo(preLabel.height);
                    make.leading.mas_equalTo(self.keywordLabel.mas_trailing).offset(5.0);
                }];
            } else {
                [keyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.keywordLabel.mas_top);
                    make.bottom.mas_equalTo(self.keywordLabel.mas_bottom);
                    make.leading.mas_equalTo(preLabel.mas_trailing).offset(16.0);
                }];
            }
        }
        [self layoutIfNeeded];
        preLabel = keyLabel;
    }
}

- (void)keywordTapAction:(UITapGestureRecognizer *)tapGesture {
    id view = tapGesture.view;
    if ([view isKindOfClass:[UILabel class]]) {
        UILabel *keyLabel = view;
        if (self.clickKeywordHandle) {
            self.clickKeywordHandle(keyLabel.text);
        }
    }
}

#pragma mark - getter/setter
- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:14.0];
        _messageLabel.textColor = [UIColor colorWithHex:0x2d2d2d];
    }
    return _messageLabel;
}

- (UILabel *)keywordLabel {
    if (!_keywordLabel) {
        _keywordLabel = [[UILabel alloc] init];
        _keywordLabel.font = [UIFont systemFontOfSize:14.0];
        _keywordLabel.textColor = [UIColor colorWithHex:0x2d2d2d];
    }
    return _keywordLabel;
}

@end
