//
//  STLTrackingItemCtrl.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"
#import "OSSVTrackingcInformationcModel.h"

@interface STLTrackingItemCtrl : STLBaseCtrl

@property (nonatomic, strong) OSSVTrackingcInformationcModel *OSSVTrackingcInformationcModel;

@property (nonatomic, strong) NSArray *trackingsArray;
@end
