//
//  ZFSizeSelectSizeTipsView.h
//  ZZZZZ
//
//  Created by YW on 2019/7/24.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFSizeTipsArrModel;

static CGFloat  kSizeSelectSizeSpace =  8;
static CGFloat  kSizeSelectLeftSpace = 16;
static CGFloat  kSizeSelectTempSpace = 15;

@interface ZFSizeSelectSizeTipsView : UICollectionReusableView

- (void)setSizeTipsArrModel:(ZFSizeTipsArrModel *)sizeTipsArrModel tipsInfo:(NSString *)tipsInfo;

+ (CGFloat)tipsCanCalculateWidth;

+ (CGFloat)tipsTopBottomSpace;

@end
