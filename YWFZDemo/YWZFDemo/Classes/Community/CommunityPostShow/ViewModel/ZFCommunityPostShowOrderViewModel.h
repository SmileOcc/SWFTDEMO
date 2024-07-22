//
//  ZFCommunityPostShowOrderViewModel.h
//  ZZZZZ
//
//  Created by YW on 16/11/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityPostShowOrderViewModel : BaseViewModel<UITableViewDataSource, UITableViewDelegate>


- (void)requestOrderNetwork:(id)parmaters
                 completion:(void (^)(NSDictionary *pageDic))completion;

@end
