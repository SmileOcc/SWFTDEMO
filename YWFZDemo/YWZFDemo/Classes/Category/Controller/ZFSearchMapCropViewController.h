//
//  ZFSearchMapCropViewController.h
//  ZZZZZ
//
//  Created by YW on 24/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"

typedef void(^ConfirmHandler)(UIImage *cropImage, CGRect cutFrame);

@interface ZFSearchMapCropViewController : ZFBaseViewController

@property (nonatomic, strong) UIImage   *sourceImage;

@property (nonatomic, copy) ConfirmHandler   confirmHandler;
- (instancetype)initWithCutFrame:(CGRect)cutFrame;

@end
