//
//  OSSVOrdereInforeModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVOrdereInforeModel : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *method;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *order_sn;
@property (nonatomic, copy) NSString *order_amount;
@property (nonatomic, copy) NSString *pay_code; 

@end
