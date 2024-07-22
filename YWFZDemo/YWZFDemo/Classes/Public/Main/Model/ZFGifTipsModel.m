//
//  ZFGifTipsModel.m
//  ZZZZZ
//
//  Created by YW on 2019/7/24.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGifTipsModel.h"
#import "AccountManager.h"
#import "YWCFunctionTool.h"

static NSString *ZFShowWishListGifTipsKey = @"showWishListGifTipsKey";

@implementation ZFGifTipsModel
@synthesize isShowWishListGifTips = _isShowWishListGifTips;

- (void)setIsShowWishListGifTips:(BOOL)isShowWishListGifTips
{
    _isShowWishListGifTips = isShowWishListGifTips;
    
    [[NSUserDefaults standardUserDefaults] setBool:_isShowWishListGifTips forKey:[self userShowWishListGifTipsKey]];
}

- (BOOL)isShowWishListGifTips
{
    _isShowWishListGifTips = [[NSUserDefaults standardUserDefaults] boolForKey:[self userShowWishListGifTipsKey]];
    return !_isShowWishListGifTips;
}

- (NSString *)userShowWishListGifTipsKey
{
    return [NSString stringWithFormat:@"%@", ZFShowWishListGifTipsKey];
}

@end
