//
//  OSSVHelpsCategorysCCell.h
// XStarlinkProject
//
//  Created by odd on 2021/1/15.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVHelpsCategorysCCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView    *imageView;
@property (nonatomic, strong) UILabel        *titleLabel;
@property (nonatomic, strong) UILabel        *tipLabel;
@property (nonatomic, strong) UIView         *bottomLineView;
@property (nonatomic, strong) UIView         *rightLineView;
@end

NS_ASSUME_NONNULL_END
