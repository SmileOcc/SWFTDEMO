//
//  OSSVOrdereItemeButtonView.h
// XStarlinkProject
//
//  Created by odd on 2020/12/9.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface OSSVOrdereItemeButtonView : UIView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title tapBlock:(void (^)(void))block;

@property (nonatomic, strong) UIButton *button;

@property (nonatomic, copy) void(^tapBlock)(void);
@end


