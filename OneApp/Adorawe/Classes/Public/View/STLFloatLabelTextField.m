//
//  STLFloatLabelTextField.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/26.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLFloatLabelTextField.h"

@implementation STLFloatLabelTextField


-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIButton *clearBtn = [self valueForKey:@"_clearButton"];
        // 在此处进行 clearBtn 样式的设置
        [clearBtn setImage:[UIImage imageNamed:@"text_field_close"] forState:UIControlStateNormal];
    }
    return self;
}


@end
