//
//  OSSVPayPalsVC.h
// XStarlinkProject
//
//  Created by 10010 on 20/11/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"

typedef void(^PPViewCallBackBlock)(STLOrderPayStatus);
typedef void(^PPFastCallBackBlock)(NSDictionary *);

@interface OSSVPayPalsVC : STLBaseCtrl

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) PPViewCallBackBlock block;
@property (nonatomic, copy) PPFastCallBackBlock ppFastBlock;

@end
