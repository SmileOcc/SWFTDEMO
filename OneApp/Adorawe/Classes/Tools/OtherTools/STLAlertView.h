//
//  STLAlertView.h
//  Staradora
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 Staradora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLAlertView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *alertView;

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content OkButton:(NSString *)okButton andAlertTag:(NSString *)alertTag isTextAlignmentCenter:(BOOL)isTextAlignmentCenter;

- (void)show;

@end
