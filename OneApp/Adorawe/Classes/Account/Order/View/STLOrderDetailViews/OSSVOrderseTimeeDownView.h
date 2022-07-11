//
//  OSSVOrderseTimeeDownView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/17.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.

#import <UIKit/UIKit.h>

@interface OSSVOrderseTimeeDownView : UIView

@property (nonatomic, copy) void(^timeEndBlock)(void);

@property (nonatomic, copy) NSString *title;
-(void)handleCountDownView:(NSString *)second;

- (void)updateTipsTypeMsg:(NSString *)tipMsg;

@end
