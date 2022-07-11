//
//  STLTabbarViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLTabbarModel.h"
#import "STLTabbarApi.h"

@interface STLTabbarViewModel : NSObject

- (void)loadOnlineIconCompletion:(void (^)(id obj))completion
                         failure:(void (^)(id obj))failure ;

@end
