//
//  ZFCommunityPostShowBagViewModel.h
//  ZZZZZ
//
//  Created by YW on 16/11/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityPostShowBagViewModel : BaseViewModel<UITableViewDataSource, UITableViewDelegate>

- (void)requestBagNetwork:(id)parmaters
               completion:(void (^)(NSDictionary *pageDic))completion;

@end
