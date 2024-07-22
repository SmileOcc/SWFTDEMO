//
//  ZFCommunityAlbumPhotoView.h
//  ZZZZZ
//
//  Created by YW on 2019/10/15.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PYAssetModel.h"
@class ZFCommunityAlbumPhotoItemView;

@interface ZFCommunityAlbumPhotoView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel      *numsLabel;

- (void)updateAssets:(NSArray <PYAssetModel *>*)assets index:(NSInteger)index;

- (void)showView:(BOOL)isShow rect:(CGRect )forRect;
@end


@interface ZFCommunityAlbumPhotoItemView : UIView

@property (nonatomic, strong) UIImageView *imageView;


@end
