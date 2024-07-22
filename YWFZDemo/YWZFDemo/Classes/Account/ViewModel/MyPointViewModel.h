//
//  MyPointViewModel.h
//  ZZZZZ
//
//  Created by DBP on 17/2/14.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface MyPointViewModel : BaseViewModel<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, copy) NSString *pointCountText;
@property (nonatomic, copy) NSString *rewardsText;
@property (nonatomic, copy) NSString *expireTipsText;

- (void)requestPointsListData:(BOOL)firstPage
                   completion:(void (^)(NSDictionary *pageInfo, BOOL isSuccess))completion;

@end
