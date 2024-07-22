//
//  CartOperationManager.m
//  Yoshop
//
//  Created by YW on 16/6/6.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "CartOperationManager.h"
#import "CommendModel.h"
#import "NSStringUtils.h"
#import "ZFPubilcKeyDefiner.h"

@interface CartOperationManager ()
@property (nonatomic,strong) BCORMHelper *helper;
@end

@implementation CartOperationManager
+ (CartOperationManager *)sharedManager {
    static CartOperationManager *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
        sharedManagerInstance.helper = [[BCORMHelper alloc]initWithDatabaseName:kDataBaseName enties: @[[CommendModel class]]];
    });
    return sharedManagerInstance;
}

- (NSArray *)commendList {
    //query
    BCSqlParameter *queryParam  = [[BCSqlParameter alloc] init];
    queryParam.entityClass = [CommendModel class];
    queryParam.orderBy = @"modify DESC";
    return [self.helper queryEntitiesByCondition:queryParam];
}

- (NSArray *)recentList {
    //query
    BCSqlParameter *queryParam  = [[BCSqlParameter alloc] init];
    queryParam.entityClass = [CommendModel class];
    queryParam.orderBy = @"modify DESC LIMIT 8";
    return [self.helper queryEntitiesByCondition:queryParam];
}

- (BOOL)saveCommend:(CommendModel *)commendModel {
    [self.helper deleteByCondition:BCDeleteParameterMake([CommendModel class],[NSString stringWithFormat:@"modify NOT IN (SELECT modify FROM %@ ORDER BY modify DESC LIMIT 20)",kCommendTableName], nil)];
    
    BCSqlParameter *queryParam  = [[BCSqlParameter  alloc] init];
    queryParam.entityClass = [CommendModel class];
    queryParam.selection = @"groupId = ?";
    queryParam.selectionArgs = @[commendModel.groupId];
    CommendModel *entity  = [self.helper queryEntityByCondition:queryParam];
    
    if (entity != nil) {
//        entity.modify = [NSString stringWithFormat:@"%ld",time(NULL)];
        [self.helper remove:entity];
        commendModel.modify = [NSString stringWithFormat:@"%ld",time(NULL)];
        commendModel.rowid = [NSStringUtils uniqueUUID];
        return [self.helper save:commendModel];
    } else {
        commendModel.modify = [NSString stringWithFormat:@"%ld",time(NULL)];
        commendModel.rowid = [NSStringUtils uniqueUUID];
        return [self.helper save:commendModel];
    }
}

- (void)updateCommend:(CommendModel *)commendModel
{
    BCSqlParameter *queryParam  = [[BCSqlParameter  alloc] init];
    queryParam.entityClass = [CommendModel class];
    queryParam.selection = @"groupId = ?";
    queryParam.selectionArgs = @[commendModel.groupId];
    CommendModel *entity  = [self.helper queryEntityByCondition:queryParam];
    
    if (entity) {
        [self.helper save:commendModel];
    }
}

@end
