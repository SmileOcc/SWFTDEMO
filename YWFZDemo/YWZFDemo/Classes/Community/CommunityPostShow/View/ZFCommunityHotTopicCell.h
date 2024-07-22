//
//  ZFCommunityHotTopicCell.h
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZFCommunityHotTopicModel.h"

@interface ZFCommunityHotTopicCell : UITableViewCell

@property (nonatomic, strong) ZFCommunityHotTopicModel *hotTopicModel;

@property (nonatomic, strong) UIImageView    *topicImageView;
@property (nonatomic, strong) UILabel        *topicTitleLabel;
@property (nonatomic, strong) UILabel        *topicDateLabel;
@property (nonatomic, strong) UILabel        *topicDescLabel;
@property (nonatomic, strong) UIImageView    *markImageView;

+ (ZFCommunityHotTopicCell *)topicCellWithTableView:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath;
@end
