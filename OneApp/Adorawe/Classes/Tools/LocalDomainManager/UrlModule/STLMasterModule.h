//
//  STLMasterModule.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLConfigureDomainProtocol.h"

@interface STLMasterModule : NSObject
<
    STLConfigureDomainProtocol
>

//@property (nonatomic, copy) NSString    *onlineAddress;

+(instancetype)sharedInstance;
@end
