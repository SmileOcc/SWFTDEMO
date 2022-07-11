//
//  YXStockAnalyzeBaseView.m
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2022/5/18.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import "YXStockAnalyzeBaseView.h"
#import <Masonry/Masonry.h>
@interface YXStockAnalyzeBaseView ()

@end

@implementation YXStockAnalyzeBaseView


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {

}

- (void)setContentHeight:(CGFloat)contentHeight {
    
    BOOL isNeedChange = NO;
    if (contentHeight != self.contentHeight) {
        isNeedChange = YES;
    }
    _contentHeight = contentHeight;
    if (isNeedChange && self.contentHeightChange) {
        self.contentHeightChange(contentHeight);
    }
}

- (void)setHidden:(BOOL)hidden {
    BOOL isNeedChange = NO;
    if (hidden != self.hidden) {
        isNeedChange = YES;
    }
    [super setHidden:hidden];
    if (isNeedChange && self.contentHeightChange) {
        self.contentHeightChange(self.contentHeight);
    }
}

@end
