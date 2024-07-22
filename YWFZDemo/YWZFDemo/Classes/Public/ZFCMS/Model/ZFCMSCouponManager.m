//
//  ZFCMSCouponManager.m
//  ZZZZZ
//
//  Created by YW on 2019/11/8.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSCouponManager.h"
#import "AccountManager.h"

@implementation ZFCMSCouponManager

+ (instancetype)manager
{
    static ZFCMSCouponManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ZFCMSCouponManager alloc] init];
    });
    
    return manager;
}

- (NSMutableArray<ZFCMSCouponModel*> *)localCouponList {
    if (!_localCouponList) {
        _localCouponList = [[NSMutableArray alloc] init];
    }
    return _localCouponList;
}

+ (void)saveCouponStateModel:(ZFCMSCouponModel *)couponModel {
    if (ZFIsEmptyString(couponModel.idx) || ![AccountManager sharedManager].isSignIn) {
        return;
    }
    
    __block BOOL isMatch = NO;
    __block ZFCMSCouponModel *matchCouponModel = nil;
    [[ZFCMSCouponManager manager].localCouponList enumerateObjectsUsingBlock:^(ZFCMSCouponModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.idx isEqualToString:couponModel.idx]) {
            if (obj.couponState == couponModel.couponState) {
                isMatch = YES;
            }
            matchCouponModel = obj;
            *stop = YES;
        }
    }];
    
    if (matchCouponModel && isMatch) {
        return;
    }
    
    if (matchCouponModel && !isMatch) {
        [[ZFCMSCouponManager manager].localCouponList removeObject:matchCouponModel];
    }
    
    [[ZFCMSCouponManager manager].localCouponList addObject:couponModel];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSData *modelData = [NSKeyedArchiver archivedDataWithRootObject:[ZFCMSCouponManager manager].localCouponList];
        [ZFCMSCouponManager clearLocalCmsCoupon:[AccountManager sharedManager].account.user_id];
        
        BOOL isSuccess = [modelData writeToFile:[ZFCMSCouponManager localPath:[AccountManager sharedManager].account.user_id] atomically:YES];
        YWLog(@"---- 本地Cms优惠券状态存储: %@",isSuccess ? @"成功" : @"失败");
    });
}


+ (void)clearLocalCmsCoupon:(NSString *)fileName {
    if(ZFIsEmptyString(fileName)) {
        fileName = @"CouponList";
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *cmsPath = [ZFCMSCouponManager localPath:fileName];
    [fileManager removeItemAtPath:cmsPath error:nil];
}

- (NSMutableArray<ZFCMSCouponModel *> *)getLocalCmsCouponList {
    
    if (![AccountManager sharedManager].isSignIn) {
        [self.localCouponList removeAllObjects];
        return self.localCouponList;
    }
    
    if (self.localCouponList.count > 0 && [AccountManager sharedManager].isSignIn) {
        ZFCMSCouponModel *firstCoupon = self.localCouponList.firstObject;
        if ([firstCoupon.currentUserId isEqualToString:ZFToString([AccountManager sharedManager].account.user_id)]) {
            
        }
        return self.localCouponList;
    }
    
    NSArray *localCouponList = [NSKeyedUnarchiver unarchiveObjectWithFile:[ZFCMSCouponManager localPath:ZFToString([AccountManager sharedManager].account.user_id)]];
    if (ZFJudgeNSArray(localCouponList)) {
        [self.localCouponList addObjectsFromArray:localCouponList];
    }
    
    return self.localCouponList;
}

- (ZFCMSCouponModel *)localCouponModelForID:(NSString *)couponId {
    if (ZFIsEmptyString(couponId)) {
        return nil;
    }
    
    __block ZFCMSCouponModel *couponModel = nil;
    [self.localCouponList enumerateObjectsUsingBlock:^(ZFCMSCouponModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.idx isEqualToString:couponId]) {
            couponModel = obj;
            *stop = YES;
        }
    }];
    
    return couponModel;
}

// 数据保存的文件夹路径
+ (NSString *)localCmsCouponModelPath {
    NSString *userDocument = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *directryPath = [userDocument stringByAppendingPathComponent:@"HomeCmsCouponLocal"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:directryPath] == NO) {
        [fileManager createDirectoryAtPath:directryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return directryPath;
}

// 创建文件路径
+ (NSString *)localPath:(NSString *)fileName {
    
    if(ZFIsEmptyString(fileName)) {
        fileName = @"CouponList";
    }
    NSString *path = [ZFCMSCouponManager localCmsCouponModelPath];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath] == NO) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
    //YWLog(@"换肤数据保存路径: %@", filePath);
    return filePath;
}
@end
