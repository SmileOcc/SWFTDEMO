//
//  ZFAddressSearchResultView.h
//  ZZZZZ
//
//  Created by YW on 2017/9/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZFAddressCountryModel;

typedef void(^AddressCountryResultSelectCompletionHandler)(ZFAddressCountryModel *model);

@interface ZFAddressCountrySearchResultView : UIView
@property (nonatomic, strong) NSMutableArray<ZFAddressCountryModel *>        *dataArray;

@property (nonatomic, copy) AddressCountryResultSelectCompletionHandler     addressCountryResultSelectCompletionHandler;

- (void)cancelSelect;
@end
