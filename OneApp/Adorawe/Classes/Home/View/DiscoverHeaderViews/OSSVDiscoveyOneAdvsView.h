//
//  DiscoveryOneBannerView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/12.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSSVAdvsEventsModel;

@protocol DiscoveryOneBannerViewDelegate <NSObject>

- (void)tapOneBannerViewActionWithModel:(OSSVAdvsEventsModel *)model;

@end

@interface OSSVDiscoveyOneAdvsView : UIView

@property (nonatomic, weak) id <DiscoveryOneBannerViewDelegate> delegate;
@property (nonatomic, strong) OSSVAdvsEventsModel                         *model;
@property (nonatomic, strong) UIButton                          *imageButton;


@end
