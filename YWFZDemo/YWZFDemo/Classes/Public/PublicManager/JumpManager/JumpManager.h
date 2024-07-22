//
//  JumpManager.h
//  ZZZZZ
//
//  Created by DBP on 16/10/25.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JumpModel.h"

@interface JumpManager : NSObject
+ (void)doJumpActionTarget:(id)target withJumpModel:(JumpModel *)jumpModel;
@end
