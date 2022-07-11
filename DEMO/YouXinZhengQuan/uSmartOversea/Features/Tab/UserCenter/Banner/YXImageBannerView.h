//
//  YXImageBannerView.h
//  uSmartOversea
//
//  Created by JC_Mac on 2018/11/6.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXCycleScrollView.h"


@interface YXImageBannerView : YXCycleScrollView

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame delegate:(id<YXCycleScrollViewDelegate>)delegate placeholderImage:(UIImage *)placeholderImage;

@property (nonatomic, strong) NSMutableArray *bannerNewsModelArr;

@end


