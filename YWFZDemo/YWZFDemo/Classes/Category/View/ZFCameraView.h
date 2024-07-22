//
//  ZFCameraView.h
//  ZZZZZ
//
//  Created by YW on 14/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BackHandler)(void);
typedef void(^FlashButtonHandler)(UIButton *sender);
typedef void(^AlbumButtonHandler)(void);
typedef void(^PhotoButtonHandler)(void);
typedef void(^ToggleButtonHandler)(void);
typedef void(^FocusHandler)(CGPoint point);

@interface ZFCameraView : UIView
@property (nonatomic, copy) BackHandler          backHandler;
@property (nonatomic, copy) FlashButtonHandler   flashButtonHandler;
@property (nonatomic, copy) AlbumButtonHandler   albumButtonHandler;
@property (nonatomic, copy) PhotoButtonHandler   photoButtonHandler;
@property (nonatomic, copy) ToggleButtonHandler  toggleButtonHandler;
@property (nonatomic, copy) FocusHandler         focusHandler;

- (void)updateTipLabel:(NSString *)tip;
@end
