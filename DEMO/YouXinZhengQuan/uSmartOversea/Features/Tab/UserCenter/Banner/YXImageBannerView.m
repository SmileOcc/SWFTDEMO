//
//  YXImageBannerView.m
//  uSmartOversea
//
//  Created by JC_Mac on 2018/11/6.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXImageBannerView.h"

@implementation YXImageBannerView

+ (instancetype)cycleScrollViewWithFrame:(CGRect)frame delegate:(id<YXCycleScrollViewDelegate>)delegate placeholderImage:(UIImage *)placeholderImage{
    
    YXImageBannerView *cycleScrollView = [[self alloc] initWithFrame:frame];
    cycleScrollView.delegate = delegate;
    cycleScrollView.placeholderImage = placeholderImage;
    cycleScrollView.titleLabelBackgroundColor = [UIColor clearColor];
    
    cycleScrollView.titleLabelTextColor = UIColorMakeWithHex(@"#EEEEEE");
    cycleScrollView.titleLabelTextFont = [UIFont systemFontOfSize:16];
    cycleScrollView.titleLabelHeight = 22;
    cycleScrollView.titleLabelTextAlignment = NSTextAlignmentLeft;
    cycleScrollView.autoScrollTimeInterval = 5;
    cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
  
    UIColor *color = [UIColor qmui_colorWithHexString:@"#C4C5CE"];
    UIImage *image = [UIImage qmui_imageWithColor:color size:CGSizeMake(5, 5) cornerRadius:2.5];
    cycleScrollView.pageDotImage = image;

    UIImage *curImage = [UIImage qmui_imageWithColor:UIColorMakeWithHex(@"#414FFF") size:CGSizeMake(5, 5) cornerRadius:2.5];
    cycleScrollView.currentPageDotImage = curImage;
   
    return cycleScrollView;
}


- (void)setBannerNewsModelArr:(NSMutableArray *)bannerNewsModelArr{
    
    _bannerNewsModelArr = bannerNewsModelArr;
    
//    NSMutableArray *imagesURLStrings = [[NSMutableArray alloc] init];
//    NSMutableArray *titles = [[NSMutableArray alloc] init];
//    NSMutableArray *labels = [[NSMutableArray alloc] init];
//    for (YXBannerNewsModel *model in bannerNewsModelArr) {
//        [imagesURLStrings addObject:model.imageUrl];
//        [titles addObject:model.title.isNotEmpty?model.title:@""];
//        [labels addObject:model.lable.isNotEmpty?model.lable:@""];
//    }
//
//    self.imageURLStringsGroup = imagesURLStrings;
//    if (imagesURLStrings.count == 1) {
//        self.infiniteLoop = NO;
//    }else {
//        self.infiniteLoop = YES;
//    }
//    self.titlesGroup = titles;
//    self.labelsGroup = labels;
}

@end
