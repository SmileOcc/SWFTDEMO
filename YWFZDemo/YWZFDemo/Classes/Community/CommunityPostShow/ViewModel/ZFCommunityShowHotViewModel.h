//
//  ZFCommunityShowHotViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/9/11.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityShowHotViewModel : BaseViewModel<UITableViewDataSource, UITableViewDelegate>


- (void)requestPageData:(BOOL)firstPage
             completion:(void (^)(NSDictionary *pageInfo))completion;

@end
