//
//  OSSVCartsOperateManager.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCartsOperateManager.h"
#import "CartOperationViewModel.h"
#import "CartModel.h"
#import "CommendModel.h"

#import "STLCartModel.h"
#import "Adorawe-Swift.h"
@implementation OperationTempModel

- (instancetype)initWithCartModel:(CartModel *)cartModel {
    self = [super init];
    if (self) {
        _goods_id = cartModel.goodsId;
        _goods_number = cartModel.goodsNumber;
        _wid = cartModel.wid;
        _flag = cartModel.stateType;
        _last_modify = cartModel.modify;
    }
    return self;
}

@end

@interface OSSVCartsOperateManager ()
@property (nonatomic,strong) BCORMHelper *helper;
@property (nonatomic,strong) CartOperationViewModel *viewModel;
@end

@implementation OSSVCartsOperateManager
+ (OSSVCartsOperateManager *)sharedManager {
    static OSSVCartsOperateManager *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
        sharedManagerInstance.helper = [[BCORMHelper alloc]initWithDatabaseName:kCartDataBaseName enties: @[[CartModel class],[CommendModel class]]];
        sharedManagerInstance.viewModel = [CartOperationViewModel new];
    });
    return sharedManagerInstance;
}

//- (void)cartSaveValidGoodsCount:(NSInteger)count {
//    
//
//    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
//    [us setObject:@(count) forKey:@"kcartValidGoodsCount"];
//    [us synchronize];
//
//}
//- (NSInteger)cartValidGoodsCount {
//    
//    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
//    NSString *count = [us objectForKey:@"kcartValidGoodsCount"];
//    return [count integerValue];
//}

- (void)cartSaveValidGoodsAllCount:(NSInteger)count {
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    [us setObject:@(count) forKey:@"kcartValidGoodsAllCount"];
    [us synchronize];
}
- (NSInteger)cartValidGoodsAllCount {
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSString *count = [us objectForKey:@"kcartValidGoodsAllCount"];
    return [count integerValue];
}

- (void)saveCart:(CartModel *)cartModel completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    [self.viewModel requestCartAddNetwork:cartModel completion:^(id obj) {
        if ([obj[kStatusCode] integerValue] == 20002) {
            if (completion) {
                completion(obj);
            }
        } else if([obj[kStatusCode] integerValue] == kStatusCode_205 && !STLIsEmptyString(cartModel.specialId)) {
            //0元活动
            [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:0 title:@"" message:obj[kMessagKey] buttonTitles:APP_TYPE == 3 ? @[STLLocalizedString_(@"ok", @"ok")] : @[STLLocalizedString_(@"ok", @"ok").uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                
            }];
            
            if (failure) {
                failure(nil);
            }
            
        } else if([obj[kStatusCode] integerValue] == kStatusCode_205){
            NSString *msg = @"";

//            NSString *msg = STLLocalizedString_(@"noInventory", nil);
            if (obj && [obj isKindOfClass:[NSDictionary class]]) {
                msg = obj[@"message"];
            }
//            [HUDManager showHUDWithMessage:[OSSVNSStringTool isEmptyString:msg] ? STLLocalizedString_(@"noInventory", nil) : msg];
            if (msg.length) {
                [HUDManager showHUDWithMessage:msg];

            }
            if (failure) {
                failure(nil);
            }
        }else {
            
            STLCartModel *stlCartModel = [STLCartModel yy_modelWithJSON:obj[kResult]];
            [stlCartModel handleGroupData];
            [stlCartModel handleCartGoodsCount];
            
            if (completion) {
                completion(stlCartModel);
                
                NSString *msg = @"";
                msg = obj[@"message"];
                if (msg.length) {
                    [HUDManager showHUDWithMessage:msg];

                }
            }
        }
       
    } failure:^(id obj) {
        if (failure) {
            failure(nil);
        }
    }];
}

- (BOOL)removeLocalCart:(CartModel *)cartModel {
    return [self.helper remove:cartModel];
}

- (BOOL)removeAllCart {
    return [self.helper executeUpdateSql:[NSString stringWithFormat:@"DELETE FROM %@ ",kCartTableName]];
}

- (BOOL)updateLocalCart:(CartModel *)cartModel {
    cartModel.totalPrice = [NSString stringWithFormat:@"%f",cartModel.goodsNumber * [cartModel.goodsPrice floatValue]];
    cartModel.modify = [NSString stringWithFormat:@"%ld",time(NULL)];
    return [self.helper update:cartModel];
}

- (void)updateLocalCartList:(NSArray *)cartList {
    [cartList enumerateObjectsUsingBlock:^(CartModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.totalPrice = [NSString stringWithFormat:@"%f",obj.goodsNumber * [obj.goodsPrice floatValue]];
        BOOL result = [self.helper update:obj];
        if (!result) {
            STLLog(@"第%lu记录更新失败",(unsigned long)idx);
        }
    }];
}


- (void)cartSyncServiceDataGoods:(NSArray<CartModel*> *)goods showView:(UIView *)showView Completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure{
    
    [self.viewModel requestCartUploadNetwork:[(goods ? goods : @[]) yy_modelToJSONObject] showView:showView completion:^(NSDictionary *serviceResult) {
        
        STLCartModel *cartModel = [STLCartModel yy_modelWithJSON:serviceResult];
        [cartModel handleGroupData];
        
        [cartModel handleCartGoodsCount];
        
//        [self cartSaveValidGoodsCount:cartModel.allValidGoods.count];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_CartBadge object:nil];

        if (completion && cartModel) {
            completion(cartModel);
        } else {
            if (failure) {
                failure(nil);
            }
        }
        
    } failure:^(id obj) {
        if (failure) {
            failure(nil);
        }
    }];
}
//取消选中购物车数据
- (void)cartUncheckServiceDataGoods:(NSArray *)cartIds showView:(UIView *)showView Completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {
    
    [self.viewModel requestCartUncheckNetwork:[(cartIds ? cartIds : @[]) yy_modelToJSONObject] showView:showView completion:^(NSDictionary *serviceResult) {
        
//        STLCartModel *cartModel = [STLCartModel yy_modelWithJSON:serviceResult];
//        [cartModel handleGroupData];
//
//        [cartModel handleCartGoodsCount];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_CartBadge object:nil];

        if (completion) {
            completion(nil);
        } else {
            if (failure) {
                failure(nil);
            }
        }
        
    } failure:^(id obj) {
        if (failure) {
            failure(nil);
        }
    }];
}


- (NSArray *)commendList {
    //query
    BCSqlParameter *queryParam  = [[BCSqlParameter alloc] init];
    queryParam.entityClass = [CommendModel class];
    queryParam.orderBy = @"modify DESC";
    return [self.helper queryEntitiesByCondition:queryParam];
}

- (BOOL)saveCommend:(CommendModel *)commendModel {
    [self.helper deleteByCondition:BCDeleteParameterMake([CommendModel class],[NSString stringWithFormat:@"modify NOT IN (SELECT modify FROM %@ ORDER BY modify DESC LIMIT 0,9)",kCommendTableName], nil)];
    
    BCSqlParameter *queryParam  = [[BCSqlParameter  alloc] init];
    queryParam.entityClass = [CommendModel class];
    queryParam.selection = @"goodsGroupId = ?";
    queryParam.selectionArgs = @[commendModel.goodsGroupId];
    CartModel *entity  = [self.helper queryEntityByCondition:queryParam];
    if (entity != nil) {
        entity.modify = [NSString stringWithFormat:@"%ld",time(NULL)];
        return [self.helper update:entity];
    } else {
        commendModel.modify = [NSString stringWithFormat:@"%ld",time(NULL)];
        commendModel.rowid = [OSSVNSStringTool uniqueUUID];
        // 历史记录不超过100条
        NSArray *localLikeArrays = [[OSSVCartsOperateManager sharedManager] commendList];
        if (localLikeArrays.count > 99) {
            CommendModel *model = localLikeArrays.lastObject;
            [self.helper remove:model];
        }
        return [self.helper save:commendModel];
    }
}
@end
