//
//  OSSVCategoryRefinesNormalsCCell.m
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVCategoryRefinesNormalsCCell.h"

@implementation OSSVCategoryRefinesNormalsCCell
@synthesize model = _model;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {

        [self.mainView addSubview:self.titleLabel];
        [self.mainView addSubview:self.closeImageView];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mainView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.mainView.mas_centerY);
        }];
        
        [self.closeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-4);
            make.centerY.mas_equalTo(self.mainView.mas_centerY);
            make.width.mas_equalTo(12);
            make.height.mas_equalTo(12);
        }];
    }
    return self;
}

+ (CGSize)contentSize:(NSString *)title maxWidt:(CGFloat)maxWidth isSelect:(BOOL)isSelect {
    
    if (STLIsEmptyString(title)) {
        return CGSizeZero;
    }
    
    // 计算cell里面textfield的宽度
    CGRect frame = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 28) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:11],NSFontAttributeName, nil] context:nil];
    
//    // 如果内容宽度 大于显示cell的宽度，显示会卡死
//    CGFloat maxW = 150;
//    if (self.superview) {
//        CGFloat suprW = CGRectGetWidth(self.superview.frame);
//        if (suprW > maxW) {
//            maxW = suprW - 24;
//        }
//    }
    
    // 这里在本身宽度的基础上 又增加了10
//    if (isSelect) {
//        frame.size.width += 8 + 12 + 12;
//    } else {
        frame.size.width += 12 * 2 + 6;
//    }
    
    if (frame.size.width >= maxWidth && maxWidth > 44) {
        frame.size.width = maxWidth;
    }
    
    if (frame.size.width <= 44) {
        frame.size.width = 44;
    }
    
    frame.size.height = 28;

    return frame.size;
}

- (void)setModel:(STLCategoryFilterValueModel *)model {
    _model = model;
    
    self.titleLabel.text = STLToString(model.editName);
    [self hightLightState:model.tempSelected];
    
    self.closeImageView.hidden = YES;
    if (model.tempSelected) {
        self.closeImageView.hidden = NO;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mainView.mas_leading).offset(8);
            make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-16);
        }];
    } else {
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.mainView.mas_leading).offset(12);
            make.trailing.mas_equalTo(self.mainView.mas_trailing).offset(-12);
        }];
    }
}
#pragma mark - Property Method

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [OSSVThemesColors col_666666];
        _titleLabel.font = [UIFont systemFontOfSize:11];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIImageView *)closeImageView {
    if (!_closeImageView) {
        _closeImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _closeImageView.image = [UIImage imageNamed:@"filter_close_gray"];
        _closeImageView.hidden = YES;
    }
    return _closeImageView;
}
@end
