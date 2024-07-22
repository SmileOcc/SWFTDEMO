//
//  YWLoginTypeSubscribeView.h
//  ZZZZZ
//
//  Created by Tsang_Fa on 2018/6/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWLoginModel.h"

typedef void(^SubscribeCellHandler)(YWLoginModel *model);
typedef void(^LoginPrivacyPolicyActionBlock)(void);

@interface YWLoginTypeSubscribeView : UIView

@property (nonatomic, strong) YWLoginModel     *model;

@property (nonatomic, copy) SubscribeCellHandler                      exchangeButtonHandler;
@property (nonatomic, copy) SubscribeCellHandler                      subscribeCellHandler;
@property (nonatomic, copy) LoginPrivacyPolicyActionBlock             loginPrivacyPolicyActionBlock;

- (void)handlerExChangeButtonTitle:(NSInteger)type;

- (void)shakeKitWithAnimation;

@end
