//
//  STLVerificationCodeViewController.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/8/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLBaseCtrl.h"
typedef void(^VerificationCloseBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface STLVerificationCodeViewController : STLBaseCtrl
@property (copy,nonatomic) VerificationCloseBlock closeBlock;
@property (copy, nonatomic) NSString  *countryCode;
@property (copy, nonatomic) NSString  *phoneNum;

@end

NS_ASSUME_NONNULL_END
