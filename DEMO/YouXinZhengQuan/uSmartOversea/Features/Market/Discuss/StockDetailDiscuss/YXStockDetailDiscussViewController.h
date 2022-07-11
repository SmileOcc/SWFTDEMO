//
//  YXStockDetailDiscussViewController.h
//  YouXinZhengQuan
//
//  Created by 付迪宇 on 2021/5/7.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailDiscussViewController : YXViewController

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) void (^didCallScroll)(UIScrollView *scrollerView);

@end

NS_ASSUME_NONNULL_END
