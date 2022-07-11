//
//  OSSVCheckOutAdressCellModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVAddresseBookeModel.h"
#import "OSSVBaseCellModelProtocol.h"

@interface OSSVCheckOutAdressCellModel : NSObject<OSSVBaseCellModelProtocol>

@property (nonatomic, strong) OSSVAddresseBookeModel *addressModel;

///名字 + 手机号码
@property (nonatomic, copy, readonly) NSString *personInfo;
@property (nonatomic,copy) NSString *phoneStr;
@property (nonatomic, copy, readonly) NSString *addressInfo;

@end
