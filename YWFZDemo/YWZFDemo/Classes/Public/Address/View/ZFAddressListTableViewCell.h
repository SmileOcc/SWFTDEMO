//
//  ZFAddressListTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2017/8/29.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFAddressInfoModel;

typedef NS_ENUM(NSInteger, ZFAddressListCellEvent){
    ZFAddressListCellEventDefault,
    ZFAddressListCellEventEdit,
    ZFAddressListCellEventDelete,
    ZFAddressListCellEventSelect
};

typedef void(^AddressEditSelectCompletionHandler)(ZFAddressInfoModel *model,ZFAddressListCellEvent event);

@interface ZFAddressListTableViewCell : UITableViewCell

@property (nonatomic, strong) ZFAddressInfoModel        *model;

@property (nonatomic, assign) BOOL                      isEdit;
@property (nonatomic, assign) BOOL                      isOrder;

- (void)updateInfoModel:(ZFAddressInfoModel *)model edit:(BOOL)isEdit isOrder:(BOOL)isOrder;

@property (nonatomic, copy) AddressEditSelectCompletionHandler          addressEditSelectCompletionHandler;

@end
