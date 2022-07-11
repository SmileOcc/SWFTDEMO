//
//  OSSVSupporteLangeModel.m
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVSupporteLangeModel.h"

@implementation OSSVSupporteLangeModel

-(NSString *)description{
    return [NSString stringWithFormat:@"code:%@ name:%@ isDefalut:%ld",_code,_name,(long)_is_default];
}

@end
