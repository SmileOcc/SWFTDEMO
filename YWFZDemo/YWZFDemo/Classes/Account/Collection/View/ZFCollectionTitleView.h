//
//  ZFCollectionTitleView.h
//  ZZZZZ
//
//  Created by YW on 2019/6/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCollectionTitleView : UIView

@property (nonatomic, copy) void (^indexBlock)(NSInteger index);

@property(nonatomic, assign) CGSize intrinsicContentSize;

- (void)showReadDot:(BOOL)show;
@end

NS_ASSUME_NONNULL_END
