//
//  ZFTrackingInfoViewController.h
//  ZZZZZ
//
//  Created by Tsang_Fa on 2017/9/4.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "WMPageController.h"

@class ZFTrackingPackageModel;

@interface ZFTrackingInfoViewController : WMPageController

@property (nonatomic, strong) NSArray<ZFTrackingPackageModel *> *packages;

@end
