//
//  AddressCountryModel.h
//  Dezzal
//
//  Created by 7FD75 on 16/8/12.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddressCountryModel : NSObject

@property (nonatomic, copy) NSString *region_code;

@property (nonatomic, copy) NSString *region_id;

@property (nonatomic, copy) NSString *region_name;
//国家区号
@property (nonatomic, copy) NSString *code;
//运营商列表
@property (nonatomic, copy) NSString *supplier_number_list;
//手机号码最大值
@property (nonatomic, copy) NSString *number;

@property (nonatomic, assign) BOOL is_state;

@property (nonatomic, assign) BOOL configured_number; //1 是后台设置的 判断就直接 =  0未设置的就是 <=

@end
