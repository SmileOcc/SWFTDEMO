//
//  ZFMultiAttributeInfoView.m
//  ZZZZZ
//
//  Created by YW on 2018/11/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFMultiAttributeInfoView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "Masonry.h"

@interface ZFMultiAttributeInfoView() <ZFInitViewProtocol>

@end

@implementation ZFMultiAttributeInfoView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
}

- (void)zfAutoLayoutView {}

#pragma mark - setter
- (void)setAttrsArray:(NSArray *)attrsArray {
    _attrsArray = attrsArray;
    CGFloat height = 16;
    __block CGFloat position_y = 0;
    
    [_attrsArray enumerateObjectsUsingBlock:^(ZFMultAttributeModel  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @autoreleasepool {
            UILabel *attrValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            attrValueLabel.text = obj.attr_value;
            attrValueLabel.font = [UIFont boldSystemFontOfSize:12];
            attrValueLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
            [self addSubview:attrValueLabel];
            [attrValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.mas_equalTo(self);
                make.top.mas_equalTo(self.mas_top).offset(position_y);
                make.height.mas_equalTo(16);
            }];
            position_y += height;
        }
    }];
}
@end
