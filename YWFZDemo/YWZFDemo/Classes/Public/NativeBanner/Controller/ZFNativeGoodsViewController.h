//
//  ZFNativeGoodsViewController.h
//  ZZZZZ
//
//  Created by YW on 23/12/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"

@class YNPageCollectionView;

@interface ZFNativeGoodsViewController : ZFBaseViewController
@property (nonatomic, copy) NSString                        *plateID;       // 导航id
@property (nonatomic, copy) NSString                        *specialId;     // 专题id
@property (nonatomic, copy) NSString                        *specialTitle;  // 专题名称

- (YNPageCollectionView *)querySubScrollView;

@end
