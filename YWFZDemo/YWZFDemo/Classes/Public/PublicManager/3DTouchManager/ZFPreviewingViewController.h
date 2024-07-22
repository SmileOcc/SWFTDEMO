//
//  ZFPreviewingViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/4/11.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZFPreviewingViewController : UIViewController
/** 上拉出来的菜单 */
@property (nonatomic, strong) NSArray <id<UIPreviewActionItem>> *actions;
@property (nonatomic, strong) UIImage *placeholderImg;
@property (nonatomic, strong) id previewingImageOrUrl;
@property (nonatomic, strong) UIImageView *imageView;
@end
