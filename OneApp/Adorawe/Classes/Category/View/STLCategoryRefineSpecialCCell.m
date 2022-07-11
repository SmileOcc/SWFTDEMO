//
//  OSSVCategoryRefinessSpeciallCCell.m
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryRefinessSpeciallCCell.h"

@implementation OSSVCategoryRefinessSpeciallCCell

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

+ (CGSize)contentSize:(NSString *)title maxWidt:(CGFloat)maxWidth {
    
    if (STLIsEmptyString(title)) {
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
        _titleLabel.textColor = [STLThemeColor col_999999];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
@end
