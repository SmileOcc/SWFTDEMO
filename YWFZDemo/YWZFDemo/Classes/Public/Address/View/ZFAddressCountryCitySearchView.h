//
//  ZFAddressCountryCitySearchView.h
//  ZZZZZ
//
//  Created by YW on 2019/1/9.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFAddressBaseModel.h"

typedef void(^AddressCountryCitySearchBlock)(ZFAddressBaseModel *model);
typedef void(^AddressCountryCitySearchScrollBlcok)(void);

//测试国家城市搜索
@interface ZFAddressCountryCitySearchView : UIView
@property (nonatomic, strong) NSMutableArray<ZFAddressBaseModel *>    *dataArray;
@property (nonatomic, copy) NSString                                  *searchKey;


/**
 选择回调
 */
@property (nonatomic, copy) AddressCountryCitySearchBlock             addressCountryCitySearchBlock;

/**
 滚动回调
 */
@property (nonatomic, copy) AddressCountryCitySearchScrollBlcok       addressCountryCitySearchScrollBlcok;

@end

