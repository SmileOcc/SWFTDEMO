//
//  STLRegisterAdvView.h
// XStarlinkProject
//
//  Created by odd on 2021/4/20.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface STLRegisterAdvView : UIView

@property (nonatomic, strong) UIImageView    *bgImageView;
@property (nonatomic, strong) UIImageView    *leftCircleImageView;
@property (nonatomic, strong) UIImageView    *rightCircleImageView;
@property (nonatomic, strong) UILabel        *titleLabel;

@end


@interface STLRegisterAdvSmallView : UIView

@property (nonatomic, strong) UIImageView    *bgImageView;
@property (nonatomic, strong) UILabel        *titleLabel;

@end
