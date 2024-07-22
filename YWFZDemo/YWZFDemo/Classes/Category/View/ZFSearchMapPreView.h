//
//  ZFSearchMapPreView.h
//  ZZZZZ
//
//  Created by YW on 23/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CropImageHandler)(UIImage *image);

@interface ZFSearchMapPreView : UIView
@property (nonatomic, strong)  UIImage     *sourceImage;
@property (nonatomic, copy)    NSString    *totalNum;
@property (nonatomic, copy)    CropImageHandler   cropImageHandler;
@end
