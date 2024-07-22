//
//  ZFAddressCityTableView.h
//  ZZZZZ
//
//  Created by YW on 2018/9/8.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFAddressCityModel.h"

@interface ZFAddressCityTableView : UITableView

@property (nonatomic, copy) void (^selectCityBlock)(ZFAddressHintCityModel *cityModel);
@property (nonatomic, strong) NSMutableArray   *cityDatas;
@property (nonatomic, copy) NSString           *key;
@end
