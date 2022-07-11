//
//  YXReturnbackPictureView.h
//  uSmartOversea
//
//  Created by Kelvin on 2018/8/15.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^VoidBlock_int)(int);
@interface YXReturnbackPictureView : UIView

@property (nonatomic, copy) VoidBlock_int isExpandBlock;
@property (nonatomic, strong, readonly) NSMutableArray *imageArr; //图片
@property (nonatomic, strong, readonly) NSMutableArray *imgLocationUrlArr; //图片本地临时缓存图片

@end
