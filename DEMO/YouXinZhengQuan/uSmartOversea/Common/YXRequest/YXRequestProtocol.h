//
//  YXRequestProtocol.h
//  uSmartOversea
//
//  Created by ellison on 2018/10/23.
//  Copyright © 2018 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YTKNetwork/YTKNetwork.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YXRequestProtocol <NSObject>

@required
- (nonnull NSString *)yx_requestUrl;
- (nonnull Class)yx_responseModelClass;

@optional
- (YTKRequestMethod)yx_requestMethod;
- (YTKRequestSerializerType)yx_requestSerializerType;
- (YTKResponseSerializerType)yx_responseSerializerType;
- (NSDictionary<NSString *,NSString *> *)yx_requestHeaderFieldValueDictionary;

- (NSTimeInterval)yx_requestTimeoutInterval;
- (NSString *)yx_baseUrl;

@end

NS_ASSUME_NONNULL_END
