//
//  ZFDBManger.h
//  ZZZZZ
//
//  Created by YW on 2018/5/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

/**
 数据库操作管理
 */
@interface ZFDBManger : NSObject

@property (nonatomic, strong) FMDatabase *db;

@property (nonatomic, strong) FMDatabaseQueue *dataBaseQueue;

+ (instancetype)shareInstance;
// 判断数据表是否存在
- (BOOL)isTableExist:(NSString *)tableName;
// 释放单例
- (void)deallocManager;

@end
