//
//  OSSVCartTableMayLikeHeaderView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/11.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSVCartTableMayLikeHeaderView : UITableViewHeaderFooterView

+ (OSSVCartTableMayLikeHeaderView *)cartHeaderViewWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) UIView                *bgView;
@property (nonatomic, strong) YYAnimatedImageView   *goodsImgView;
@property (nonatomic, strong) UILabel               *titleLabel;
@property (nonatomic, strong) UIView                *lineView;

- (void)updateImage:(NSString *)imgUrl title:(NSString *)title;

@end
