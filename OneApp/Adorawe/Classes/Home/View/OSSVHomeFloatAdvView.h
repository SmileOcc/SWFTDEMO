//
//  STLHomeFloatBannerView.h
// XStarlinkProject
//
//  Created by odd on 2021/3/12.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVAdvsEventsModel.h"


@interface OSSVHomeFloatAdvView : UIView

@property (nonatomic, strong) OSSVAdvsEventsModel         *advModel;
@property (nonatomic, strong) YYAnimatedImageView      *floatBannerImageView;
@property (nonatomic, strong) UIButton                 *floatCloseButton;

@property (nonatomic, copy) void(^floatEventBlock)(OSSVAdvsEventsModel *advModel);
@property (nonatomic, copy) void(^floatCloseBlock)(void);

@end

