//
//  STLProductImagePlaceholder.h
// XStarlinkProject
//
//  Created by Kevin on 2021/6/14.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLProductImagePlaceholder : UIView
@property (nonatomic, strong) UIView *grayView;
@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, strong) YYAnimatedImageView *placeImageView; //此视图是用于分类中的View All 的衣架展示。

// 类目主模块
- (instancetype)initWithFrame:(CGRect)frame isCategory:(BOOL)isCategory;
@end

