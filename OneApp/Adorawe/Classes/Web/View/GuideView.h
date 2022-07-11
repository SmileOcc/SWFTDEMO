//
//  GuideView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/6.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GuideView : NSObject

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, copy) void (^signUpBlock)();
@property (nonatomic, copy) void (^shoppingCallBack)();

+ (instancetype)sharedInstance;
- (void)show;

@end


@interface GuideViewCell : UICollectionViewCell

+ (GuideViewCell *)guideViewCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;
@property (nonatomic, strong) YYAnimatedImageView *imageView;

@end
