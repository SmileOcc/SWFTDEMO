//
//  OSSVMessageNotifyVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/24.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVMessageNotifyViewModel.h"
#import "OSSVMessageModel.h"

typedef void(^notifyMsgUnreadCountRefreshBlock)(void);

typedef NS_ENUM(NSInteger, STLMessageType) {
    STLMessageTypeNotify = 1,          //通知
    STLMessageTypeLogistics  = 2      // 物流
};

@interface OSSVMessageNotifyVC : STLBaseCtrl

@property (nonatomic, strong) OSSVMessageNotifyViewModel *viewModel;
@property (nonatomic, strong) OSSVMessageModel           *typeModel;
@property(nonatomic,assign)STLMessageType type;
@property (nonatomic, strong) notifyMsgUnreadCountRefreshBlock block;

- (void)refreshRequest:(BOOL)refresh;
@end
