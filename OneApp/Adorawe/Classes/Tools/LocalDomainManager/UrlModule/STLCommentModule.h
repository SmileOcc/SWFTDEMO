//
//  STLCommentModule.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//  评论中心的接口域名

#import <Foundation/Foundation.h>
#import "STLConfigureDomainProtocol.h"

//社区的，暂时没用
@interface STLCommentModule : NSObject
<
    STLConfigureDomainProtocol
>

+ (NSString *)reviewPictureDomainHost;
@end
