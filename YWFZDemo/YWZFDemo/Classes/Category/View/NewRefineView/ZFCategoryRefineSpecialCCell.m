//
//  ZFCategoryRefineSpecialCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCategoryRefineSpecialCCell.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFThemeManager.h"

@implementation ZFCategoryRefineSpecialCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self.mainView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mainView.mas_leading).offset(8);
            make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-8);
            make.centerY.mas_equalTo(self.mainView.mas_centerY);
        }];
    }
    return self;
}

//- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
//    
//    // 获得每个cell的属性集
//    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
//    // 计算cell里面textfield的宽度
//    CGRect frame = [self.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 28) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.titleLabel.font,NSFontAttributeName, nil] context:nil];
//
//    // 如果内容宽度 大于显示cell的宽度，显示会卡死
//    CGFloat maxW = 110;
//
//    frame.size.width += 10 * 2 + 4;
//    if (frame.size.width >= maxW) {
//        frame.size.width = maxW;
//    }
//
//    frame.size.height = 36;
//    // 重新赋值给属性集
//    attributes.frame = frame;
//    
//    return attributes;
//}

+ (CGSize)contentSize:(NSString *)title maxWidt:(CGFloat)maxWidth {
    
    if (ZFIsEmptyString(title)) {
        return CGSizeZero;
    }
    CGRect frame = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 28) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:12],NSFontAttributeName, nil] context:nil];
    
    // 如果内容宽度 大于显示cell的宽度，显示会卡死
    CGFloat maxW = 110;
    
    frame.size.width += 10 * 2 + 4;
    if (frame.size.width >= maxW) {
        frame.size.width = maxW;
    }
    
    frame.size.height = 36;
    
    return frame.size;
}

#pragma mark - Property Method

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = ZFC0x666666();
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

@end
