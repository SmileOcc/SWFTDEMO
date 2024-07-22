//
//  ZFHomeFloatingView.h
//  ZZZZZ
//
//  Created by YW on 2018/11/31.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZFHomeFloatingView : UIView

+ (void)showFloatingViewWithUrl:(NSString *)imageurl
                       tapBlock:(void(^)(void))tapBlock
                     closeBlock:(void(^)(void))closeBlock;
@end
