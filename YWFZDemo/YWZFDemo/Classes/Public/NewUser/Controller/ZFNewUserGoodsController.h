//
//  ZFNativeGoodsViewController.h
//  ZZZZZ
//
//  Created by YW on 23/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//  新人专享页面商品列表

#import "ZFBaseViewController.h"

@class YNPageCollectionView;

@interface ZFNewUserGoodsController : ZFBaseViewController

@property (nonatomic, strong) NSArray *dataArray;

- (YNPageCollectionView *)querySubScrollView;

@end
