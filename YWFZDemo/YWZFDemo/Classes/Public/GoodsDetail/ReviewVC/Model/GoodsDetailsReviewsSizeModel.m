//
//  GoodsDetailsReviewsSizeModel.m
//  ZZZZZ
//
//  Created by YW on 2019/4/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "GoodsDetailsReviewsSizeModel.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"

@implementation GoodsDetailsReviewsSizeModel

- (NSString *)reviewsOverallContent
{
    if (self.overall.integerValue == 0) {
        return ZFLocalizedString(@"OverallFit_TrueToSize", nil);
    } else if (self.overall.integerValue == 1) {
        return ZFLocalizedString(@"OverallFit_Large", nil);
    } else if (self.overall.integerValue == 2) {
        return ZFLocalizedString(@"OverallFit_Small", nil);
    } else {
        return @"";
    }
}

- (BOOL)isShowOverall
{
    if (ZFToString(self.overall).length) {
        return YES;
    }
    return NO;
}

- (BOOL)isShowReviewsSize
{
    if (ZFToString(self.height).length) {
        return YES;
    }
    if (ZFToString(self.bust).length) {
        return YES;
    }
    if (ZFToString(self.waist).length) {
        return YES;
    }
    if (ZFToString(self.hips).length) {
        return YES;
    }
    return NO;
}

@end
