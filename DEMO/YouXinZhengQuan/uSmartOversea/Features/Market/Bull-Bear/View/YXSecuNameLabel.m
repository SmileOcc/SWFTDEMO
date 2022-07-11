//
//  YXSecuNameLabel.m
//  uSmartOversea
//
//  Created by ellison on 2019/1/23.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXSecuNameLabel.h"
#import <Masonry/Masonry.h>

@interface YXSecuNameLabel ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation YXSecuNameLabel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.defaultFont = [UIFont systemFontOfSize:16];
        self.smallFont = [UIFont systemFontOfSize:12];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.label = [[UILabel alloc] init];
//        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.bottom.equalTo(self);
        }];
    }
    return self;
}

- (void)setText:(NSString *)text {
    if (text == nil) {
        text = @"--";
    }
    _text = text;
    self.label.font = self.defaultFont;
    self.label.text = _text;
    
    [self setNeedsLayout];
}

- (UIFont *)font {
    return self.label.font;
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    _attributedText = attributedText;
    self.label.attributedText = _attributedText;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.label.textColor = _textColor;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    self.label.textAlignment = _textAlignment;
}

- (void)layoutSubviews {
    
//    [self invalidateIntrinsicContentSize];

    [super layoutSubviews];
    
    [self sizeThatFits];
}

- (void)sizeThatFits
{
    UIFont *font = self.defaultFont;
    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName:font}];
    if (textSize.width > self.bounds.size.width && textSize.width > self.preferredMaxLayoutWidth) {
        font = self.smallFont;
//        textSize = [self.text sizeWithAttributes:@{NSFontAttributeName:font}];
//
//        if (textSize.width > size.width) {
//            textSize.width = size.width;
//            self.text = [self.text stringByAppendingString:@"..."];
//        }
    }
    self.label.font = font;
}

//- (CGSize)intrinsicContentSize
//{
//    if (CGRectEqualToRect(self.bounds, CGRectZero)) {
//        return [super intrinsicContentSize];
//    }
//    return [self sizeThatFits:CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))];
//}

//- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize
//{
//    return [self sizeThatFits:targetSize];
//}
//
//- (void)drawRect:(CGRect)rect
//{
//    [self.text drawInRect:rect withAttributes:@{NSFontAttributeName:self.font, NSForegroundColorAttributeName: self.textColor}];
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
