//
//  ZFCommunityContactsCell.h
//  ZZZZZ
//
//  Created by YW on 17/1/15.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PPPersonModel;

typedef void(^ContactsSelectBlock)(PPPersonModel *model);

@interface ZFCommunityContactsCell : UITableViewCell

@property (nonatomic,copy) ContactsSelectBlock contactsSelectBlock;

@property (nonatomic,strong) PPPersonModel *model;

+ (ZFCommunityContactsCell *)contactsCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;

@end
