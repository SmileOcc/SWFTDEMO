//
//  ContactsViewModel.h
//  ZZZZZ
//
//  Created by YW on 17/1/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "BaseViewModel.h"

typedef void(^CountBlock)(NSArray *phoneArray);

@interface ContactsViewModel : BaseViewModel<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic,copy) CountBlock countBlock;

- (void)loadContactsDataCompletion:(void (^)(NSArray *keys))completion;

@end
