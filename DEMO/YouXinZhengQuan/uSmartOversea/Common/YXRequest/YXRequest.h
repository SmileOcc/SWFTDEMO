//
//  YXRequest.h
//  YouXinZhengQuan
//
//  Created by RuiQuan Dai on 2018/7/2.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>
#import "YXResponseModel.h"
#import "YXRequestProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^YXRequestCompletionBlock)(__kindof YXResponseModel * responseModel);

@class YXRequest;
@protocol YXRequestDelegate<NSObject>

- (void)yx_requestFailed:(YXRequest *)request;
- (void)yx_requestFinished:(YXRequest *)request responseModel:(__kindof YXResponseModel * _Nullable)responseModel;

@end

@interface YXRequest : YTKRequest <YTKRequestDelegate>


@property (nonatomic, strong, readonly) YXModel<YXRequestProtocol> *requestModel;
@property (nonatomic, weak) id<YXRequestDelegate> yx_delegate;


/**
 初始化请求对象

 @param requestModel 请求参数
 @return request对象
 */
- (instancetype)initWithRequestModel:(__kindof YXModel *)requestModel;


/**
 发起请求 带有hud效果
 */
- (void)startWithHud;


/**
 发起请求并且通过回调返回调用结果

 @param success HTTP成功的网络请求返回
 @param failure HTTP失败的网络请求返回
 */
- (void)startWithBlockWithSuccess:(YXRequestCompletionBlock)success failure:(YTKRequestCompletionBlock)failure;

/**
    requestHeaderField
 */
- (NSDictionary<NSString *,NSString *> * _Nullable)requestHeaderFieldValueDictionary;


@end

NS_ASSUME_NONNULL_END

