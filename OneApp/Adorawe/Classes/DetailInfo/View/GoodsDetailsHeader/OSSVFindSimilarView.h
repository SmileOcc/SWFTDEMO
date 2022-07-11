//
//  OSSVFindSimilarView.h
// XStarlinkProject
//
//  Created by odd on 2021/1/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVFindSimilarView : UIView

@property (nonatomic, strong) UILabel     *tipLabel;
@property (nonatomic, strong) UIButton    *similarButton;

@property (nonatomic, copy) void(^similarBlock)(void);

@end

NS_ASSUME_NONNULL_END
