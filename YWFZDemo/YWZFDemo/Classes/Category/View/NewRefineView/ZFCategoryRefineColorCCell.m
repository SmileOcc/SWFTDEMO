//
//  ZFCategoryRefineColorCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCategoryRefineColorCCell.h"


@implementation ZFCategoryRefineColorCCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.colorView.backgroundColor = ZFCOLOR_RANDOM;
    [self.mainView addSubview:self.colorView];
    [self.mainView addSubview:self.colorTitleLabel];
}

- (void)zfAutoLayoutView {
    
    
    [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.mainView.mas_centerY);
        make.leading.mas_equalTo(self.mainView.mas_leading).offset(10);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    
    [self.colorTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.colorView.mas_trailing).offset(2);
        make.centerY.mas_equalTo(self.mainView.mas_centerY);
        make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-8);
    }];
}

//- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//
//    // 获得每个cell的属性集
//    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
//    // 计算cell里面textfield的宽度
//    CGRect frame = [self.colorTitleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 28) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.colorTitleLabel.font,NSFontAttributeName, nil] context:nil];
//
//    // 如果内容宽度 大于显示cell的宽度，显示会卡死
//    CGFloat maxW = 150;
//    if (self.superview) {
//        CGFloat suprW = CGRectGetWidth(self.superview.frame);
//        if (suprW > maxW) {
//            maxW = suprW - 24;
//        }
//    }
//
//    // 这里在本身宽度的基础上 又增加了10
//    frame.size.width += 12 * 2 + 14;
//
//    if (frame.size.width >= maxW) {
//        frame.size.width = maxW;
//    }
//
//    frame.size.height = 28;
//
//    // 重新赋值给属性集
//    attributes.frame = frame;
//
//    return attributes;
//}

+ (CGSize)contentSize:(NSString *)title maxWidt:(CGFloat)maxWidth {
    if (ZFIsEmptyString(title)) {
        title = @"";
    }
    CGRect frame = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 28) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12],NSFontAttributeName, nil] context:nil];
    
    // 如果内容宽度 大于显示cell的宽度，显示会卡死
    CGFloat maxW = 150;
    if (maxWidth > maxW) {
        maxW = maxWidth - 24;
    }

    // 这里在本身宽度的基础上 又增加了10
    frame.size.width += 12 * 2 + 14;
    
    if (frame.size.width >= maxW) {
        frame.size.width = maxW;
    }
    
    frame.size.height = 28;

    return frame.size;
}

#pragma mark - Property Method


- (UIView *)colorView {
    if (!_colorView) {
        _colorView = [[UIView alloc] initWithFrame:CGRectZero];
        _colorView.layer.cornerRadius = 7.0;
        _colorView.layer.masksToBounds = YES;
    }
    return _colorView;
}

- (UILabel *)colorTitleLabel {
    if (!_colorTitleLabel) {
        _colorTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _colorTitleLabel.textColor = ZFC0x666666();
        _colorTitleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _colorTitleLabel;
}
@end
