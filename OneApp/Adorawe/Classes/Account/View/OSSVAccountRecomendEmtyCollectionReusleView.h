//
//  OSSVAccountRecomendEmtyCollectionReusleView.h
// XStarlinkProject
//
//  Created by odd on 2020/8/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVAccountRecomendEmtyCollectionReusleView : UICollectionReusableView

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, copy) void (^emptyBlock)(void);

+ (OSSVAccountRecomendEmtyCollectionReusleView*)recommendEmptyHeaderWithCollectionView:(UICollectionView *)collectionView Kind:(NSString*)kind IndexPath:(NSIndexPath *)indexPath;

- (void)loadMessage:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
