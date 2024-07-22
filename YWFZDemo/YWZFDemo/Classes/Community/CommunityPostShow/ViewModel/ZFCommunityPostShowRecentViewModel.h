//
//  ZFCommunityPostShowRecentViewModel.h
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityPostShowRecentViewModel : BaseViewModel<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,weak) UIViewController *controller;

- (void)requestRecentNetwork:(id)parmaters completion:(void (^)(NSDictionary *pageInfo))completion;

@end
