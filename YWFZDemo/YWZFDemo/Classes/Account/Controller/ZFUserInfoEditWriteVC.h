//
//  ZFUserInfoEditWriteVC.h
//  ZZZZZ
//
//  Created by YW on 2020/1/9.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFUserInfoTypeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFUserInfoEditWriteVC : UIViewController

@property (nonatomic, copy) void (^inputTextBlock)(NSString *text);


@property (nonatomic, strong) ZFUserInfoTypeModel *typeModel;

@end

NS_ASSUME_NONNULL_END
