//
//  YXTableViewCell.h
//  YouXinZhengQuan
//
//  Created by RuiQuan Dai on 2018/7/2.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXModel.h"

@interface YXTableViewCell : UITableViewCell

@property (nonatomic, strong) id model;

- (void)initialUI;

- (void)refreshUI;


@end
