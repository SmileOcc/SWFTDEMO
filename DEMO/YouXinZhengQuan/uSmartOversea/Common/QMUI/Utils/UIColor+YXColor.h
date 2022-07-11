//
//  YXColor.h
//  uSmartOversea
//
//  Created by chenmingmao on 2022/3/16.
//  Copyright © 2022 RenRenDai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ChangeTraitCollectionBlock)(UITraitCollection *);

@interface UIColor (YXColor)

+ (UIColor *)themeColorWithNormalHex:(NSString *)normalHexString andDarkColor: (NSString *)darkHexString;

+ (UIColor *)themeColorWithNormal:(UIColor *)normalcolor andDarkColor: (UIColor *)darkColor;

@end




@interface UIView (YXUIManager)


@end


NS_ASSUME_NONNULL_END
