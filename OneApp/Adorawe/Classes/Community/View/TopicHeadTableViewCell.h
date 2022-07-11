//
//  TopicHeadTableViewCell.h
//  Zaful
//
//  Created by DBP on 16/11/23.
//  Copyright © 2016年 Y001. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopicDetailHeadLabelModel.h"

@interface TopicHeadTableViewCell : UITableViewCell
+ (TopicHeadTableViewCell *)topicHeadTableViewCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, strong) TopicDetailHeadLabelModel *topicDetailHeadModel;
@property (nonatomic, copy) void (^joinInMyStyleBlock)(NSString *topicLabel);//My Style Block
@property (nonatomic, copy) void (^refreshHeadViewBlock)();//My Style Block
@end
