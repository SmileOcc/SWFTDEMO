//
//  ZFCommunityNavBarView.h
//  ZZZZZ
//
//  Created by YW on 2019/10/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFCommunityNavBarView : UIView

- (instancetype)initWithFrame:(CGRect)frame withMaxWidth:(CGFloat)maxWidth;

@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *confirmButton;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) CGFloat  confirmMaxWidth;


@property (nonatomic, copy) void (^closeBlock)(BOOL flag);
@property (nonatomic, copy) void (^confirmBlock)(BOOL flag);

@end

