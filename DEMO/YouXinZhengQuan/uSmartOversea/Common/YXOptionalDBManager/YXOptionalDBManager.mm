//
//  YXOptionalDBManager.m
//  uSmartOversea
//
//  Created by ellison on 2018/11/29.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import "YXOptionalDBManager.h"
#import "YXOptionalSecu+WCTTableCoding.h"

@interface YXOptionalDBManager ()
{
    WCTDatabase *_database;
}

@end

#define TABLE_WCDB_NAME @"OptionalSecu"

@implementation YXOptionalDBManager

+ (instancetype)shareInstance {
    static YXOptionalDBManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YXOptionalDBManager alloc] init];
    });
    
    return instance;
}

+ (NSString *)wcdbFilePath{
    NSString *docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dbFilePath = [docDir stringByAppendingPathComponent:@"optional.db"];
    return dbFilePath;
}

- (BOOL)creatDatabase {
    
    _database = [[WCTDatabase alloc] initWithPath:[YXOptionalDBManager wcdbFilePath]];
    
    if ([_database canOpen]) {
        if ([_database isOpened]) {
            if ([_database isTableExists:TABLE_WCDB_NAME]) {
                return NO;
                
            }else {
                return [_database createTableAndIndexesOfName:TABLE_WCDB_NAME withClass:YXOptionalSecu.class];
            }
        }
    }
    return NO;
}

- (BOOL)insertOrReplaceData:(id<YXSecuProtocol>)secuObject {
    if (secuObject == nil) {
        return NO;
    }
    
    if (![secuObject conformsToProtocol:@protocol(YXSecuProtocol)]) {
        return NO;
    }
    
    if (_database == nil) {
        [self creatDatabase];
    }
    YXOptionalSecu *secu = [[YXOptionalSecu alloc] initWithSecu:secuObject];
    return [_database insertOrReplaceObject:secu into:TABLE_WCDB_NAME];
}


- (BOOL)insertOrReplaceDatas:(NSArray<YXOptionalSecu *> *)secus {
    if (_database == nil) {
        [self creatDatabase];
    }
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [secus enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:obj];
    }];
    return [_database insertOrReplaceObjects:array into:TABLE_WCDB_NAME];
}

- (BOOL)deleteDataWithSecu:(id<YXSecuIDProtocol>)secu  {
    if (_database == nil) {
        [self creatDatabase];
    }
    return [_database deleteObjectsFromTable:TABLE_WCDB_NAME where:YXOptionalSecu.market == secu.market && YXOptionalSecu.symbol == secu.symbol];
}

- (BOOL)deleteDataWithSecus:(NSArray<id<YXSecuIDProtocol>> *)secus  {
    if (_database == nil) {
        [self creatDatabase];
    }
    NSMutableArray *markets = [[NSMutableArray alloc] init];
    NSMutableArray *codes = [[NSMutableArray alloc] init];
    [secus enumerateObjectsUsingBlock:^(id<YXSecuIDProtocol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [markets addObject:obj.market];
        [codes addObject:obj.symbol];
    }];
    return [_database deleteObjectsFromTable:TABLE_WCDB_NAME where:YXOptionalSecu.market.in(markets) && YXOptionalSecu.symbol.in(codes)];
}

-(BOOL)deleteAllData {
    if (_database == nil) {
        [self creatDatabase];
    }
    return [_database deleteAllObjectsFromTable:TABLE_WCDB_NAME];
}

- (BOOL)updateAllSecuName {
    if (_database == nil) {
           [self creatDatabase];
       }
    return [_database updateAllRowsInTable:TABLE_WCDB_NAME onProperty:YXOptionalSecu.name withValue: @"--"];
}

#pragma mark - 查
- (NSArray<YXOptionalSecu *> *)allOptionalSecu {
    if (_database == nil) {
        [self creatDatabase];
    }
    return [_database getAllObjectsOfClass:[YXOptionalSecu class] fromTable:TABLE_WCDB_NAME];
}

- (NSArray<YXOptionalSecu *> *)getDataWithSecus:(NSArray<id<YXSecuIDProtocol>> *)secus{
    if (_database == nil) {
        [self creatDatabase];
    }
    NSMutableArray *markets = [[NSMutableArray alloc] init];
    NSMutableArray *codes = [[NSMutableArray alloc] init];
    [secus enumerateObjectsUsingBlock:^(id<YXSecuIDProtocol> _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [markets addObject:obj.market];
        [codes addObject:obj.symbol];
    }];
    return [_database getObjectsOfClass:[YXOptionalSecu class] fromTable:TABLE_WCDB_NAME where:YXOptionalSecu.market.in(markets) && YXOptionalSecu.symbol.in(codes)];
}

- (BOOL)updateData:(YXOptionalSecu *)secu {
    if (_database == nil) {
        [self creatDatabase];
    }
    
    return [_database updateRowsInTable:TABLE_WCDB_NAME onProperties:{YXOptionalSecu.priceBase, YXOptionalSecu.now, YXOptionalSecu.change, YXOptionalSecu.roc} withObject:secu where:YXOptionalSecu.market == secu.market && YXOptionalSecu.symbol == secu.symbol];
}


@end
