//
//  ZFMergeRequestManager.m
//  ZZZZZ
//
//  Created by YW on 2019/3/5.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFMergeRequest.h"
#import "Constants.h"
#import "ZFMergeRequestManager.h"

@interface ZFMergeRequest ()

@property (nonatomic, strong) NSMutableArray <ZFRequestModel *> *mergeRequestList;

@property (nonatomic, strong) NSMutableArray <NSString *> *taskIdentifierList;

@property (nonatomic, strong) NSMutableDictionary *resultParams;

@property (nonatomic, assign) NSInteger totalReuqestCount;

@property (nonatomic, copy) complation resultBlock;

@end

@implementation ZFMergeRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.mergeRequestList = [[NSMutableArray alloc] init];
        self.taskIdentifierList = [[NSMutableArray alloc] init];
        self.resultParams = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addRequest:(ZFRequestModel *)requestModel
{
    if (requestModel) {
        [self.mergeRequestList addObject:requestModel];
    }
}

-(void)addRequestList:(NSArray<ZFRequestModel *> *)requestModelList
{
    if ([requestModelList count]) {
        [self.mergeRequestList addObjectsFromArray:requestModelList];
    }
}

- (void)startRequest {
    self.totalReuqestCount = self.mergeRequestList.count;
    
    for (int i = 0; i < [self.mergeRequestList count]; i++) {
        ZFRequestModel *requestModel = self.mergeRequestList[i];
        [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
            [self dealwithRequestResult:requestModel result:responseObject];
        } failure:^(NSError *error) {
            [self dealwithRequestResult:requestModel result:error];
        }];
    }
    if (self.totalReuqestCount > 0) {
        [[ZFMergeRequestManager sharedInstance] addBatchRequest:self];
    }
}

- (void)dealwithRequestResult:(ZFRequestModel *)requestModel result:(id)object {
    self.totalReuqestCount--;
    //拿到请求模型的内存地址作为返回参数的key
    [self.resultParams setObject:object forKey:[NSString stringWithFormat:@"%p", requestModel]];
    if (self.totalReuqestCount <= 0) {
        [self handleResultComplationBlock];
    }
}

- (void)handleResultComplationBlock
{
    if (_resultBlock) {
        if ([self.resultParams count] == [self.mergeRequestList count]) {
            //全部请求成功
            NSMutableDictionary *complationResult = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *complationErrorResult = [[NSMutableDictionary alloc] init];
            NSArray *allkeys = [self.resultParams allKeys];
            for (int i = 0; i < allkeys.count; i++) {
                //拿到请求模型的内存地址作为返回参数的key
                id result = self.resultParams[allkeys[i]];
                if (![result isKindOfClass:[NSError class]]) {
                    [complationResult setObject:result forKey:allkeys[i]];
                }else if ([result isKindOfClass:[NSError class]]) {
                    [complationErrorResult setObject:result forKey:allkeys[i]];
                }
            }
            NSError *error = nil;
            if ([[complationErrorResult allKeys] count]) {
                error = [NSError errorWithDomain:NSURLErrorDomain code:401 userInfo:@{@"errorMessage" : @"有失败的网络请求"}];
            }
            _resultBlock(complationResult, complationErrorResult, error);
            [self.resultParams removeAllObjects];
            [self.taskIdentifierList removeAllObjects];
            [self.mergeRequestList removeAllObjects];
            [[ZFMergeRequestManager sharedInstance] removeBatchRequest:self];
        }
    }else{
        YWLog(@"回调为空");
    }
}

- (void)requestResult:(complation)result
{
    _resultBlock = result;
}

@end
