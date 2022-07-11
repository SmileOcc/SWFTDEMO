//
//  YXTabItemView.h
//  ScrollViewDemo
//
//  Created by ellison on 2018/9/30.
//  Copyright © 2018 ellison. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXTabItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXTabItemView : UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) YXTabItem *item;

- (void)reloadItem:(YXTabItem*)item;

@property (nonatomic, assign) BOOL hideRedDot;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

NS_ASSUME_NONNULL_END
