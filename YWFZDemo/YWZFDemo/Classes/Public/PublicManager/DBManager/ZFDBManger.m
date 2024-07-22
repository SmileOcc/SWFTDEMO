//
//  ZFDBManger.m
//  ZZZZZ
//
//  Created by YW on 2018/5/8.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFDBManger.h"
#import "Constants.h"

static ZFDBManger *dbManager = nil;
static dispatch_once_t onceToken;
@implementation ZFDBManger

+ (instancetype)shareInstance {
    dispatch_once(&onceToken, ^{
        dbManager = [[ZFDBManger alloc] init];
        NSString *dbPath    = [self dbPathWithDBName:kDataBaseName];
        YWLog(@"数据库存储路径：%@", dbPath);
        dbManager.db  = [FMDatabase databaseWithPath:dbPath];
        dbManager.dataBaseQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    });
    return dbManager;
}

- (BOOL)isTableExist:(NSString *)tableName {
    FMResultSet *rs = [self.db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
    while ([rs next]) {
        NSInteger count = [rs intForColumn:@"count"];
        YWLog(@"isTableExist %ld", (long)count);
        if (0 == count) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

- (void)deallocManager {
    [dbManager.db close];
    [dbManager.dataBaseQueue close];
    dbManager = nil;
    onceToken = 0L;
}

+ (NSString *)dbPathWithDBName:(NSString *)dbName {
    NSString *userDocment = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:userDocment] == NO) {
        [fileManager createDirectoryAtPath:userDocment withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [userDocment stringByAppendingPathComponent:dbName];
}

@end
