//
//  ZFCommunityOutfitsResultShowView.h
//  ZZZZZ
//
//  Created by YW on 2019/10/15.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFCommunityOutfitsResultShowView : UIView

@property (nonatomic, strong) UIButton                  *saveButton;

@property (nonatomic, strong) UIImageView               *imageView;

@property (nonatomic, assign) CGPoint                   currentItemCenterPoint;
@property (nonatomic, assign) CGRect                    currentItemFrame;

- (void)setCoverImage:(UIImage *)image;
- (void)showView:(BOOL)isShow;
@end

