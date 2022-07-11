//
//  STLTextField.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLTextField.h"

@implementation STLTextField


//- (instancetype)initWithFrame:(CGRect)frame iconLeftView:(UIView *)leftView iconRightView:(UIView *)rightView
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        if (leftView) {
//            self.leftView = leftView;
//            self.leftViewMode = UITextFieldViewModeAlways;
//        }
//        if (rightView) {
//            self.rightView = rightView;
//            self.rightViewMode = UITextFieldViewModeAlways;
//        }
//    }
//    return self;
//}

- (instancetype)init {
    
    if (self = [super init]) {
        // 设置默认的一些情况
        _leftPadding = 8;
        _rightPadding = 8;
        _leftPlaceholderNormalPadding = 10; // 10 === 代表普通设置离左边的距离
    }
    return self;
}

- (instancetype)initLeftPadding:(CGFloat )leftPadding rightPadding:(CGFloat)rightPadding {
    if (self = [self init]) {
        // 设置默认的一些情况
        _leftPadding = leftPadding > 0 ? leftPadding : 8;
        _rightPadding = rightPadding > 0 ? rightPadding : 8;
        _leftPlaceholderNormalPadding = leftPadding > 0 ? leftPadding : 10; // 10 === 代表普通设置离左边的距离
    }
    return self;
}

// 左边View 距离边界的距离
- (CGRect)leftViewRectForBounds:(CGRect)bounds {
    CGRect leftRect = [super leftViewRectForBounds:bounds];
    leftRect.origin.x += _leftPadding; //右边偏8
    return leftRect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds {
    CGRect rightRect = [super rightViewRectForBounds:bounds];
    rightRect.origin.x -= _rightPadding; //右边偏8
    return rightRect;
}

//UITextField 文字与输入框的距离
- (CGRect)textRectForBounds:(CGRect)bounds{
    
    if (self.leftView) {
        return CGRectInset(bounds, _leftPadding * 2 + self.leftView.frame.size.width, 0);
    }
    return CGRectInset(bounds, _leftPlaceholderNormalPadding, 0);
    
}
//控制编辑文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds{
    if (self.leftView) {
        return CGRectInset(bounds, _leftPadding * 2 + self.leftView.frame.size.width, 0);
    }
    return CGRectInset(bounds, _leftPlaceholderNormalPadding, 0);
}

- (void)dealloc {
    STLLog(@"-----STLTextField  dealloc");
}

@end
