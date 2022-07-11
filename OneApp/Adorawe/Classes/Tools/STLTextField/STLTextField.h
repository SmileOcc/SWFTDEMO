//
//  STLTextField.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/10.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLTextField : UITextField

- (instancetype)initLeftPadding:(CGFloat )leftPadding rightPadding:(CGFloat)rightPadding;

@property (nonatomic, assign) CGFloat leftPadding;
@property (nonatomic, assign) CGFloat rightPadding;
@property (nonatomic, assign) CGFloat leftPlaceholderNormalPadding;

@end
