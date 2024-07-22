//
//  ZFCommunityRemmondPageControl.m
//  ZZZZZ
//
//  Created by YW on 2019/3/1.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityRemmondPageControl.h"
#import "ZFThemeManager.h"
#import "ZFFrameDefiner.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "SystemConfigUtils.h"

@implementation ZFCommunityRemmondPageControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.minWidth = 10;
        self.maxWidth = 14;
        self.minHeight = 4;
        self.maxHeight = 4;
        self.limitCorner = 0;
        self.highColor = ZFC0xFE5269();
        self.defaultColor = ZFC0xDDDDDD();
    }
    return self;
}

- (void)configeMaxWidth:(CGFloat)maxWidth minWidth:(CGFloat)minWidth maxHeight:(CGFloat)maxHeight minHeight:(CGFloat)minHeight limitCorner:(CGFloat)limitCorner {
    if (minWidth > 0) {
        self.minWidth = minWidth;
    }
    if (maxWidth > 0) {
        self.maxWidth = maxWidth;
    }
    if (minHeight > 0) {
        self.minHeight = minHeight;
    }
    if (maxHeight) {
        self.maxHeight = maxHeight;
    }
    if (limitCorner > 0) {
        self.limitCorner = limitCorner;
    }
}


- (void)updateDotHighColor:(UIColor *)highColor defaultColor:(UIColor *)defaultColor counts:(NSInteger)count currentIndex:(NSInteger)currentIndex {
    
    if (count < 1) {
        return;
    }
    
    if (highColor) {
        self.highColor = highColor;
    }
    if (defaultColor) {
        self.defaultColor = defaultColor;
    }
    
    if (count > 0) {
        self.allCounts = count;
    }
    if (currentIndex >= 0 && currentIndex < count) {
        self.currentIndex = currentIndex;
    }
    
    NSArray *subsView = self.subviews;
    for (UIView *sub in subsView) {
        [sub removeFromSuperview];
    }
    

    UIButton *tempButton;
    for (int i=0; i<count; i++) {
        UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        itemButton.tag = 37100 + i;
        [itemButton setBackgroundColor:(i == self.currentIndex ? self.highColor : self.defaultColor)];
        if (self.limitCorner > 0) {
            itemButton.layer.cornerRadius = self.limitCorner;
            itemButton.layer.masksToBounds = YES;
        }
        [self addSubview:itemButton];
        
        CGFloat width = self.minWidth;
        CGFloat height = self.minHeight;
        if (i == self.currentIndex) {
            width = self.maxWidth;
            height = self.maxHeight;
        }
        
        if (tempButton) {
            [itemButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.mas_centerY);
                make.leading.mas_equalTo(tempButton.mas_trailing).offset(4);
                make.size.mas_equalTo(CGSizeMake(width, height));
                if (i == count -1) {
                    make.trailing.mas_equalTo(self.mas_trailing);
                }
            }];
        } else {
            [itemButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(width, height));
                make.leading.mas_equalTo(self.mas_leading);
            }];
        }
        tempButton = itemButton;
    }
}

- (void)selectIndex:(NSInteger)index {
    if (self.allCounts > index && index != self.currentIndex) {
        
        UIButton *selectButton = [self viewWithTag:(37100 + index)];
        if (selectButton) {
            NSArray *subsView = self.subviews;
            self.currentIndex = index;
            
            for (UIButton *subBtn in subsView) {
                if (subBtn == selectButton) {
                    [subBtn setBackgroundColor:self.highColor];
                    [subBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.size.mas_equalTo(CGSizeMake(self.maxWidth, self.maxHeight));
                    }];
                } else {
                    [subBtn setBackgroundColor:self.defaultColor];
                    [subBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                        make.size.mas_equalTo(CGSizeMake(self.minWidth, self.minHeight));
                    }];
                }
            }
        }
    }
}

@end
