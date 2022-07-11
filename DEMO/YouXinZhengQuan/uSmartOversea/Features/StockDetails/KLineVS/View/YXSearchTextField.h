//
//  YXSearchTextField.h
//  YouXinZhengQuan
//
//  Created by rrd on 2018/7/30.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YXSearchTextField : UIView

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIButton *importButton;

- (void)showImportButton;

@end
