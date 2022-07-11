//
//  OSSVAccountsItemsView.h
// XStarlinkProject
//
//  Created by odd on 2020/8/3.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSBadgeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVAccountsItemsView : UIControl

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel     *titleLabel;
@property (nonatomic, strong) UILabel     *numberLabel;
@property (nonatomic, strong) UIView      *imageRedDotView;
@property (nonatomic, strong) UIView      *numberRedDotView;
@property (nonatomic, strong) UIView      *badgeBgView;
@property (nonatomic, strong) UILabel     *badgeLabel;

- (instancetype)initWithFrame:(CGRect)frame image:(NSString *)image title:(NSString *)title;
- (void)image:(NSString *)image title:(NSString *)title;
/// count >= 0 显示数字
- (void)confirmCounts:(NSString *)counts titleNumber:(NSInteger)count showRed:(BOOL )showRed;

@end

NS_ASSUME_NONNULL_END
