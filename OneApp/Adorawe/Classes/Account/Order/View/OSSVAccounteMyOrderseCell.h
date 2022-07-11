//
//  OSSVAccounteMyOrderseCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJJTimeCountDownLabel.h"
#import "ZJJTimeCountDown.h"

@class OSSVAccounteMyeOrdersListeModel;
@class OSSVAccounteMyOrderseCell;

@protocol AccountMyOrdersCellDelegate<NSObject>

- (void)OSSVAccounteMyOrderseCell:(OSSVAccounteMyOrderseCell *)cell sender:(UIButton *)sender event:(OrderOperateType)operateType;

@end

@interface OSSVAccounteMyOrderseCell : UITableViewCell

@property (nonatomic, weak) id<AccountMyOrdersCellDelegate>       delegate;
@property (nonatomic, weak) OSSVAccounteMyeOrdersListeModel              *orderListModel;
@property (nonatomic, strong) NSIndexPath                         *indexPath;
@property (nonatomic, strong) ZJJTimeCountDownLabel               *countDownLabel;                  ///<倒计时
@property (nonatomic, weak) ZJJTimeCountDown                      *countDown;
@end
