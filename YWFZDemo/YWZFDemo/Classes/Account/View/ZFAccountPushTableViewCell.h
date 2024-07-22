//
//  ZFAccountPushTableViewCell.h
//  ZZZZZ
//
//  Created by YW on 2018/8/16.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZFAccountPushTableViewCellDelegate <NSObject>

-(void)zfAccountPushTableViewCellDidClickSwitch:(UISwitch *)sender;

@end

@interface ZFAccountPushTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL switchEnable;
@property (nonatomic, weak) id<ZFAccountPushTableViewCellDelegate>delegate;

@end
