//
//  OSSVCategoryssCCell.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/1.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCatagorysChildModel.h"

#import "YYLabel.h"
#import "YYText.h"
@interface OSSVCategoryssCCell : UICollectionViewCell

@property (nonatomic, strong) OSSVCatagorysChildModel         *categoryChildModel;
@property (nonatomic, strong) YYLabel                       *titlesLabel;
@property (nonatomic, strong) STLProductImagePlaceholder    *imageView;

@end
