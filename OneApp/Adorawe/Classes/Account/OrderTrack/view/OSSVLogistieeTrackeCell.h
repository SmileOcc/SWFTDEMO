//
//  OSSVLogistieeTrackeCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/5.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVLogisticscTrackcModel.h"
#import "OSSVTrackingcMessagecModel.h"

typedef NS_ENUM(NSInteger) {
    DotLineStatus_Top,
    DotLineStatus_Normal,
    DotLineStatus_Bottom,
    DotLineStatus_OnlyOne
}DotLineStatus;

@interface OSSVLogistieeTrackeCell : UITableViewCell

@property (nonatomic, strong) OSSVTrackingcMessagecModel *model;

-(void)setDotLineStatus:(DotLineStatus)status;

@end
