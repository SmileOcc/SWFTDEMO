//
//  YXStockDetailMyReimndersCell.h
//  uSmartOversea
//
//  Created by 姜轶群 on 2018/11/21.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//


#define kFolderCount   3
#define kSubTypeViewHeight  69

#import "uSmartOversea-Swift.h"
#import <UIKit/UIKit.h>
@class YXReminderListModel;
NS_ASSUME_NONNULL_BEGIN

@interface YXStockDetailMyReimndersCell : UITableViewCell


@property (nonatomic, strong) YXReminderListModel *remindModel; //list数据
@property (nonatomic, strong) RACCommand *editRemindCommand; //编辑
@property (nonatomic, strong) RACCommand *deleteRemindCommand;  //删除
@property (nonatomic, strong) RACCommand *foldRemindCommand;  //折叠展开


@end

NS_ASSUME_NONNULL_END
