//
//  OSSVMessageVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/23.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVMessageListModel.h"

typedef void(^MsgRefreshBlock)(OSSVMessageListModel *);

@interface OSSVMessageVC : STLBaseCtrl

@property (nonatomic, copy) MsgRefreshBlock messageRefresh;

@end
