//
//  YWLoginTypeConfirmView.h
//  ZZZZZ
//
//  Created by Tsang_Fa on 2018/6/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YWLoginModel.h"

typedef void(^ConfirmCellHandler)(void);

@interface YWLoginTypeConfirmView : UIView

@property (nonatomic, copy) ConfirmCellHandler confirmCellHandler;

@property (nonatomic, strong) YWLoginModel     *model;

@end
