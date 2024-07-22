//
//  ZFUserSexImageView.h
//  ZZZZZ
//
//  Created by 602600 on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFUserSexImageView : UIView

- (void)setSelectViewImageName:(NSString *)imageName text:(NSString *)text;

- (void)resetUI;

- (void)selectUI;

@end

NS_ASSUME_NONNULL_END
