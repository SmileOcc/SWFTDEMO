//
//  ZFCommunityPostShowWishlistViewModel.h
//  ZZZZZ
//
//  Created by YW on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityPostShowWishlistViewModel : BaseViewModel<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,weak) UIViewController *controller;

- (void)requestPageData:(BOOL)firstPage
             completion:(void (^)(NSDictionary *pageInfo))completion;

@end
