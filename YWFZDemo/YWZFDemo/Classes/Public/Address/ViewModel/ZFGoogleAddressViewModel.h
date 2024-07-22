//
//  ZFGoogleAddressViewModel.h
//  ZZZZZ
//
//  Created by YW on 2018/7/10.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ZFGoogleDetailAddressModel;

@interface ZFGoogleAddressViewModel : NSObject < UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, copy) void (^selectedAddressModel)(ZFGoogleDetailAddressModel *addressModel);

/**
 * 清空数据源
 */
- (void)clearTableDataSource;

/**
 * 查询输入的国家信息列地址表
 */
- (void)getInputGoogleAddressData:(NSString *)inputText
                     country_code:(NSString *)country_code
                       completion:(void (^)(NSArray *addressDataArr))completion;

@end
