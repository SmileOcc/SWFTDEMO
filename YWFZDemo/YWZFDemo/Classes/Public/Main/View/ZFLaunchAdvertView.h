//
//  ZFLaunchAdvertView.h
//  ZZZZZ
//
//  Created by YW on 2018/5/2.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFLaunchAdvertView : UIView

+ (void)showAdvertWithImageData:(NSData *)imageData
                jumpBannerBlock:(void(^)(void))jumpBannerBlock
                skipBannerBlock:(void(^)(void))skipBannerBlock;

@end
