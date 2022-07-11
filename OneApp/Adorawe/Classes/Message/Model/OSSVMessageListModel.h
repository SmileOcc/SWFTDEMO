//
//  OSSVMessageListModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVMessageModel.h"
#import <Foundation/Foundation.h>

@interface OSSVMessageListModel : NSObject

// 未读信息
@property (nonatomic, copy) NSString *total_count;
@property (nonatomic, strong) NSArray<OSSVMessageModel*> *bubbles;

@end
