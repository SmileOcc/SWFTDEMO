//
//  YXFaceIdSignHelper.h
//  uSmartOversea
//
//  Created by 胡华翔 on 2019/1/2.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXFaceIdSignHelper : NSObject
- (NSString *)getFaceIDSignStr;

- (NSString *)getFaceIDSignVersionStr;
@end

NS_ASSUME_NONNULL_END
