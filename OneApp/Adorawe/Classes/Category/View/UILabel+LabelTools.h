//
//  UILabel+LabelTools.h
// XStarlinkProject
//
//  Created by fan wang on 2021/7/31.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (LabelTools)
- (NSArray *)getLinesArrayOfStringInLabel:(CGFloat)width;
@end

NS_ASSUME_NONNULL_END
