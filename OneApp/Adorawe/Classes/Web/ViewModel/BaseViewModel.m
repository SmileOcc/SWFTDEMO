//
//  BaseViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVBasesRequests.h"
#import "OSSVAdvsEventsManager.h"

@interface BaseViewModel ()
@property (nonatomic, strong, readwrite) NSMutableArray<OSSVBasesRequests *> *queueList;
@end

@implementation BaseViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.emptyViewShowType = EmptyViewShowTypeHide;
    }
    return self;
}

- (void)baseViewChangePV:(id)params first:(BOOL)isFirst {
    
}
/**
 *  该方法为页面请求数据，继承BaseViewModel的类要根据自己的需要重写该方法
 *
 *  @param parmaters             网络请求参数
 *  @param completionExcuteBlock 请求完成后所要执行的操作，如：重新页面等
 */
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj)) completion failure:(void (^)(id obj))failure{
    if (completion) {
        completion(nil);
    }
}
/**
 *  数据解析方法，后期要提取通用，如果特殊再重写该方法
 *
 *  @param json    网络请求返回的数据-以JSON格式为主
 *  @param request 发送请求的API
 *
 *  @return 返回所需要的类型可以是字典，model，数组。。。。
 */
- (id)dataAnalysisFromJson:(id)json  request:(OSSVBasesRequests *)request{
    return nil;
}
/**
 *  提示信息
 *
 *  @param info 提示信息
 */
- (void)alertMessage:(NSString *)info {

    if ([info isKindOfClass:[NSNull class]]) {
        info = @"error";
    }
    [HUDManager showHUDWithMessage:info];
}

- (EmptyCustomViewManager *)emptyViewManager {
    
    if (!_emptyViewManager) {
        _emptyViewManager = [[EmptyCustomViewManager alloc] init];
        @weakify(self)
        _emptyViewManager.emptyRefreshOperationBlock = ^{
            @strongify(self);
            // 这里是固定没有网络 touch event
            [self emptyOperationTouch];
        };
    }
    return _emptyViewManager;
}

/**
 *  网络请求刷新
 *
 *  @param sender
 */
- (void)emptyOperationTouch {
    if(self.emptyOperationBlock){
        self.emptyOperationBlock();
    }
}

- (void)emptyJumpOperationTouch  {
    if (self.emptyJumpOperationBlock) {
        self.emptyJumpOperationBlock();
    }
}

- (void)freesource {
    if (_queueList) {
        for (int i = 0; i < _queueList.count; i++) {
            OSSVBasesRequests *request = _queueList[i];
            [request stop];
        }
        [_queueList removeAllObjects];
    }
}

#pragma mark - setter and getter

-(NSMutableArray<OSSVBasesRequests *> *)queueList
{
    if (!_queueList) {
        _queueList = [[NSMutableArray alloc] init];
    }
    return _queueList;
}

@end
