//
//  OSSVCategoryRefineHeadCollectiReusableView.h
// XStarlinkProject
//
//  Created by odd on 2020/9/29.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVCategoryRefineHeadCollectiReusableView : UICollectionReusableView

+ (OSSVCategoryRefineHeadCollectiReusableView *)headWithCollectionView:(UICollectionView *)collectionView Kind:(NSString *)kind IndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countsLabel;
@property (nonatomic, strong) UIView  *countsView;

@property (nonatomic, strong) UIButton *evenButton;
@property (nonatomic, strong) UIImageView *arrowImageView;

@property (nonatomic, assign) BOOL     isUp;


@property (nonatomic, copy) void (^tapBlock)(void);

- (void)updateArrowDirection:(BOOL)isUp;

- (void)updateCountsString:(NSString *)countsString;

- (void)hideArrow:(BOOL)isHide;

@end

NS_ASSUME_NONNULL_END
