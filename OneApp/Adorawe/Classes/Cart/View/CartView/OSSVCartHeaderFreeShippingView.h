//
//  OSSVCartHeaderFreeShippingView.h
// XStarlinkProject
//
//  Created by Kevin on 2021/6/8.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  OSSVCartHeaderFreeShippingViewDelegate <NSObject>

@optional
- (void)rightButtonAction;
@end

@interface OSSVCartHeaderFreeShippingView : UIView
@property (nonatomic, weak)   id<OSSVCartHeaderFreeShippingViewDelegate>delegate;
@property (nonatomic, strong) UILabel *freeShippingLabel;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UILabel  *pickLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UIImageView *shipCartImageView;
@property (nonatomic, strong) UIView   *progressBgView;
@property (nonatomic, strong) UIView   *currentProgressView; //当前进度
@property (nonatomic, assign) float progress;

@end
