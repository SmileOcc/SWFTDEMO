//
//  OSSVCheckUpdatesModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/15.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVCheckUpdatesModel : NSObject

@property (nonatomic, assign) BOOL isNeedUpdate; // status  0： 不需要更新 1： 需要更新
@property (nonatomic, assign) NSDictionary *updateContent; // 更新内容

@end
