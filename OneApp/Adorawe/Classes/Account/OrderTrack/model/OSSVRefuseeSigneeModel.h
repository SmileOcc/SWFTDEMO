//
//  OSSVRefuseeSigneeModel.h
// XStarlinkProject
//
//  Created by Kevin on 2020/12/2.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVRefuseeSigneeModel : NSObject
@property (nonatomic, copy) NSString *status;   //物流状态
@property (nonatomic, copy) NSString *desc;     //信息描述
@property (nonatomic, copy) NSString *date;     //时间

@end

NS_ASSUME_NONNULL_END
