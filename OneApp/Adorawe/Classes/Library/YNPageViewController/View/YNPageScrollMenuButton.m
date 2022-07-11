//
//  YNPageScrollMenuButton.m
// XStarlinkProject
//
//  Created by mac on 2019/1/7.
//  Copyright © 2019年 XStarlinkProject. All rights reserved.
//

#import "YNPageScrollMenuButton.h"

@interface YNPageScrollMenuButton ()

@end

@implementation YNPageScrollMenuButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.size = 0.6;
        self.btnType = YNPageScrollMenuButtonTypeNor;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [self addSubview:self.subTitle];
    }
    return self;
}

- (void)setBtnType:(YNPageScrollMenuButtonType)btnType {
    _btnType = btnType;
    [self layoutSubviews];
}

- (void)setSize:(float)size {
    _size = size;
    [self layoutSubviews];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    switch (self.btnType) {
        case YNPageScrollMenuButtonTypeSubTitle: {
            //设置标题大小
//            self.titleLabel.font = [UIFont systemFontOfSize:14];
//            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            CGRect titleLabelframe = self.titleLabel.frame;
            titleLabelframe.origin.x = 0;
            titleLabelframe.origin.y = 0;
            titleLabelframe.size.width = self.frame.size.width;
            titleLabelframe.size.height = self.frame.size.height * self.size;
            self.titleLabel.frame = titleLabelframe;
            
            self.subTitle.frame = CGRectMake(0, self.frame.size.height * self.size, self.frame.size.width, self.frame.size.height * (1 - self.size));
        }
            break;
        default:
            break;
    }
}

- (UILabel *)subTitle {
    if(!_subTitle) {
        _subTitle = [[UILabel alloc] init];
        _subTitle.font = [UIFont systemFontOfSize:12];
        _subTitle.textColor = [UIColor whiteColor];
        _subTitle.textAlignment = NSTextAlignmentCenter;
    }
    return _subTitle;
}

@end

