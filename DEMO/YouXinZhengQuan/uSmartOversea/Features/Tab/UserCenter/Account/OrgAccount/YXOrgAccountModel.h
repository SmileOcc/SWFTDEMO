//
//  YXOrgAccountModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/20.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXOrgAccountModel : NSObject

@property (nonatomic, strong) NSString *areaCode;
@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, assign) BOOL isMain;

@property (nonatomic, strong) NSString *orgId;
@property (nonatomic, strong) NSString *traderEmail;
@property (nonatomic, strong) NSString *traderPhone;

@property (nonatomic, assign) BOOL traderStatus;

@end

NS_ASSUME_NONNULL_END
