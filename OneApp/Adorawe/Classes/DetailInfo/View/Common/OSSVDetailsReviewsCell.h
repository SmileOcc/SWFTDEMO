//
//  OSSVDetailsReviewsCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVReviewsListModel.h"

@interface OSSVDetailsReviewsCell : UITableViewCell

@property (nonatomic, strong) OSSVReviewsListModel *model;
@property (nonatomic, weak) UIViewController *controller;

@end
