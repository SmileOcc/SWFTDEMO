//
//  STLNewTrackingListViewController.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLBaseCtrl.h"

NS_ASSUME_NONNULL_BEGIN

@interface STLNewTrackingListViewController : STLBaseCtrl
@property (nonatomic, copy)   NSString *trackVal; // 物流ID 或者 订单编号
@property (nonatomic, copy)   NSString *trackType;// 0:物流ID，  1：订单编号
@end

NS_ASSUME_NONNULL_END
