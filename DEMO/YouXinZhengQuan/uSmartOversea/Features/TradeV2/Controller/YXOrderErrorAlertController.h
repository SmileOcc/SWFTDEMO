//
//  YXOrderErrorAlertController.h
//  YouXinZhengQuan
//
//  Created by rrd on 2019/1/26.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <TYAlertController/TYAlertController.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXOrderErrorAlertController : TYAlertController

+(YXOrderErrorAlertController *)alertControllerWithTitle:(NSString *)title content:(NSString *)content subContent:(NSString *)subContent;

@end

NS_ASSUME_NONNULL_END
