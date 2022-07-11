//
//  OSSVMessageMenuItemView.h
// XStarlinkProject
//
//  Created by odd on 2020/8/6.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"
#import "OSSVMessageModel.h"
#import "Adorawe-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVMessageMenuItemView : UIControl

@property (nonatomic, strong) UIImageView  *imageView;
@property (nonatomic, strong) UILabel      *titleLabel;
//@property (nonatomic, strong) JSBadgeView  *badgeView;
//@property (nonatomic, strong) UIImageView  *redDotImgview;

@property (nonatomic, strong) STLBadgeViewNew *badgeViewNew;

@property (nonatomic, strong) OSSVMessageModel  *messageModel;

@property (nonatomic, strong) UIView           *bottomLineView;

- (void)showLine:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
