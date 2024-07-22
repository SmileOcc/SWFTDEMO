//
//  ZFSelectSizeSizeFooter.h
//  ZZZZZ
//
//  Created by YW on 2017/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

static CGFloat  kSizeSelectSizeSpace =  8;
static CGFloat  kSizeSelectLeftSpace = 16;
static CGFloat  kSizeSelectTempSpace = 15;

@interface ZFSelectSizeSizeFooter : UICollectionReusableView

@property (nonatomic, copy) NSString        *tipsInfo;

+ (CGFloat)tipsCanCalculateWidth;
+ (CGFloat)tipsTopBottomSpace;
- (void)updateLayout;
@end
