//
//  OSSVMessageActivityVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVMessageModel.h"

typedef void(^activityMsgUnreadCountRefreshBlock)(void);

@interface OSSVMessageActivityVC : STLBaseCtrl

@property (nonatomic, strong) activityMsgUnreadCountRefreshBlock block;
@property (nonatomic, strong) OSSVMessageModel           *typeModel;

- (void)refreshRequest:(BOOL)refresh;
@end
