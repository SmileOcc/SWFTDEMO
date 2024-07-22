//
//  ZFPictureSearchToolView.h
//  ZZZZZ
//
//  Created by YW on 2018/9/14.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 以图搜图操作入口
 */
@interface ZFPictureSearchToolView : UIView

@property (nonatomic, copy) void (^takePhotosHandle)(void);
@property (nonatomic, copy) void (^getPhotosHandle)(void);
@property (nonatomic, copy) void (^selectedPhotoHandle)(UIImage *image);
- (void)changeContainView;

@end
