//
//  YXUGCAttentionViewController.h
//  YouXinZhengQuan
//
//  Created by tao.sun on 2021/5/29.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

//#import "YXCommonUGCViewController.h"

#import "YXViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXUGCAttentionViewController : YXViewController

@property (nonatomic, strong) UICollectionView *collectionView;

/// 用于查询用户主页动态
@property (nonatomic, assign) BOOL isUserFeedListPage;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, assign) NSInteger homePageTabType;

@end

NS_ASSUME_NONNULL_END
