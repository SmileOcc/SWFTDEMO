//
//  STLTrackingInforCtrl.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLBaseCtrl.h"

@interface STLTrackingInforCtrl : STLBaseCtrl

@property (nonatomic, strong) NSString *orderNumber;

///因为在订单详情页就已经拿到数据了，直接传过来就可以了
@property (nonatomic, strong) NSArray *dataArray;

///因为后台返回的数据都是中文，所以用shippingMethod
@property (nonatomic, copy) NSString *shippingMethod;
    
@end
