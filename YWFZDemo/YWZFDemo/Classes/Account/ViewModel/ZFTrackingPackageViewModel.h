//
//  ZFTrackingPackageViewModel.h
//  ZZZZZ
//
//  Created by YW on 4/9/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ZFTrackingPackageModel;

@interface ZFTrackingPackageViewModel : NSObject<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) ZFTrackingPackageModel   *model;

@end
