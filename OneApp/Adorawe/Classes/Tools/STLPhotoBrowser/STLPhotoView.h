//
//  STLPhotoView.h
// XStarlinkProject
//
//  Created by odd on 2021/6/30.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STLPhotoViewDelegate;
#define MaxSCale 3.0  //最大缩放比例
#define MinScale 1.0  //最小缩放比例



@interface STLPhotoView : UIScrollView

///当前显示的图片
@property (nonatomic, strong) YYAnimatedImageView *imageView;
@property (nonatomic, copy) NSString              *imgUrl;
@property (nonatomic, strong) UIImage             *currentImage;

@property (nonatomic, weak)   id<STLPhotoViewDelegate> stlDelegate;

@end

@protocol STLPhotoViewDelegate <NSObject>

@optional
- (void)singleClickWithPhoto:(STLPhotoView *)photo;

@end

