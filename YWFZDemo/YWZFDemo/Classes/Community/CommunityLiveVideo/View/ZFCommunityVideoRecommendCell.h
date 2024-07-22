//
//  ZFCommunityVideoRecommendCell.h
//  ZZZZZ
//
//  Created by YW on 16/11/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/UIImageView+YYWebImage.h>
#import <YYImage/YYImage.h>

@interface ZFCommunityVideoRecommendCell : UITableViewCell

+ (ZFCommunityVideoRecommendCell *)recommendCellWithTableView:(UITableView *)tableView IndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) void (^jumpBlock)(void);//跳转VC Block

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) YYAnimatedImageView *iconImg;

@end
