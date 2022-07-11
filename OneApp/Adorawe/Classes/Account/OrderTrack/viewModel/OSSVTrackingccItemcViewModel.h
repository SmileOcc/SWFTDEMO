//
//  OSSVTrackingccItemcViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/14.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

@class OSSVTrackingcInformationcModel;

@interface OSSVTrackingccItemcViewModel : BaseViewModel<UITableViewDelegate,UITableViewDataSource>

//@property (nonatomic, strong) OSSVTrackingcInformationcModel *OSSVTrackingcInformationcModel;

- (void)setTrackingRoutesArray:(NSArray *)array;
@end
