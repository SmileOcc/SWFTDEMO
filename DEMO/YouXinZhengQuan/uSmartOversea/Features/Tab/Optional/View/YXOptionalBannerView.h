//
//  YXOptionalBannerView.h
//  uSmartOversea
//
//  Created by youxin on 2019/5/9.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickCloseBtnBlock)(void);
typedef void(^ClickBannerBlock)(NSInteger index);

NS_ASSUME_NONNULL_BEGIN

@interface YXOptionalBannerView : UIView

@property (nonatomic, copy) ClickCloseBtnBlock closeBlcok;
@property (nonatomic, copy) ClickBannerBlock  clickBannerBlock;

- (instancetype)initWithFrame:(CGRect)frame imageURLStringsGroup:(NSArray *)imageURLStrings;
- (void)updateWithImageURLs:(NSArray *)imageURLStrings;
@end

NS_ASSUME_NONNULL_END
