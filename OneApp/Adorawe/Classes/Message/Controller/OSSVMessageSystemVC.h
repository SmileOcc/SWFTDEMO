//
//  OSSVMessageSystemVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/22.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVMessageModel.h"
typedef void(^systemMsgUnreadCountRefreshBlock)(void);

@interface OSSVMessageSystemVC : STLBaseCtrl

@property (nonatomic, strong) systemMsgUnreadCountRefreshBlock block;
@property (nonatomic, strong) OSSVMessageModel           *typeModel;

- (void)refreshRequest:(BOOL)refresh;
@end
