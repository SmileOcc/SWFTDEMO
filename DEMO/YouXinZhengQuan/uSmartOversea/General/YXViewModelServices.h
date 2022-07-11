//
//  YXViewModelServices.h
//  uSmartOversea
//
//  Created by RuiQuan Dai on 2018/7/2.
//Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXNavigationProtocol.h"

@protocol YXModulePathServices;
@protocol YXViewModelServices <NSObject,YXNavigationProtocol, YXModulePathServices>

@end
