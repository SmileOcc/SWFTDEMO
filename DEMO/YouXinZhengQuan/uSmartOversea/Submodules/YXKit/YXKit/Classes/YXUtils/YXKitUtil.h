//
//  YXKitUtil.h
//  Alamofire
//
//  Created by 胡华翔 on 2019/09/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXKitUtil : NSObject

/// 生成http请求所需要的xToken
/// @param xTransId xTransId
/// @param xTime xTime
/// @param xDt xDt
/// @param xDevId xDevId
/// @param xUid xUid
/// @param xLang xLang
/// @param xType xType
/// @param xVer xVer
+ (NSString * _Nonnull)xTokenGenerateWithXTransId:(NSString * _Nonnull)xTransId xTime:(NSString * _Nonnull)xTime xDt:(NSString * _Nonnull)xDt xDevId:(NSString * _Nonnull)xDevId xUid:(NSString * _Nonnull)xUid xLang:(NSString * _Nonnull)xLang xType:(NSString * _Nonnull)xType xVer:(NSString * _Nonnull)xVer;

@end

NS_ASSUME_NONNULL_END
