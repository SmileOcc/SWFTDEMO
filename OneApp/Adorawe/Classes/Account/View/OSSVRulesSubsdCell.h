//
//  OSSVRulesSubsdCell.h
// XStarlinkProject
//
//  Created by Starlinke on 2021/6/3.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVRulesSubsdCell : UICollectionViewCell

- (void)hideLab;
- (void)showLabWithSure:(BOOL)isShow;
- (void)valueLabText:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
