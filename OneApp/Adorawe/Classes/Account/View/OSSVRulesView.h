//
//  OSSVRulesView.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVMysSizesCell.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^scrollBlock)(NSString *value);
@interface OSSVRulesView : UIView

@property (nonatomic, assign) sizeCellType type;
@property (nonatomic, copy) scrollBlock scrollblock;

@property (nonatomic, assign) NSInteger sizeType;// cm or inch
@property (nonatomic, assign) double defaultValue;

@end

NS_ASSUME_NONNULL_END
