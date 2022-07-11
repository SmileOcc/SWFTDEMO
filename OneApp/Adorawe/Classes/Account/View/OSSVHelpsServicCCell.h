//
//  OSSVHelpsServicCCell.h
// XStarlinkProject
//
//  Created by odd on 2021/8/9.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVMyleHeopItemsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVHelpsServicCCell : UICollectionViewCell
@property (nonatomic, strong) UIView         *bgView;
@property (nonatomic, strong) UIImageView    *imageView;
@property (nonatomic, strong) UIView         *titleView;
@property (nonatomic, strong) UILabel        *titleLabel;
@property (nonatomic, strong) UILabel        *tipLabel;

@property (nonatomic, strong) UIButton       *button;

@property (nonatomic, strong) OSSVMyleHeopItemsModel *model;

@property (nonatomic, copy) void (^tapBlock)(OSSVMyleHeopItemsModel *model);
@end

NS_ASSUME_NONNULL_END
