//
//  YWLoginTopView.h
//  ZZZZZ
//
//  Created by YW on 25/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWLoginModel.h"

typedef void(^LoginCloseHandler)(void);
typedef void(^ToggleModeHandler)(YWLoginModel *model);

@interface YWLoginTopView : UIView

@property (nonatomic, copy) LoginCloseHandler   loginCloseHandler;
@property (nonatomic, copy) ToggleModeHandler   toggleModeHandler;

@property (nonatomic, strong) YWLoginModel   *model;

@end

