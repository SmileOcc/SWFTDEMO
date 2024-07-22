//
//  ZFCommunityLiveLlistHeaderView.h
//  ZZZZZ
//
//  Created by YW on 2019/4/2.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFCommunityLiveLlistHeaderView : UICollectionReusableView

@property (nonatomic, copy) NSString   *title;
@property (nonatomic, copy) NSString   *imageUrl;

- (void)updateLeftImage:(UIImage *)leftImage rightImage:(UIImage *)rightImage;


+ (ZFCommunityLiveLlistHeaderView *)headWithCollectionView:(UICollectionView *)collectionView Kind:(NSString *)kind IndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
