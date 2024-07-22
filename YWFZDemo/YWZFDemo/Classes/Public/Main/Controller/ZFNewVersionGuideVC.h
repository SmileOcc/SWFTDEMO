//
//  ZFNewVersionGuideVC.h
//  BossBuy
//
//  Created by BB on 15/7/20.
//  Copyright (c) 2015年 fasionspring. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^DidFinishBlock)(void);

@interface ZFNewVersionGuideVC : UIViewController

@property (nonatomic, copy)   DidFinishBlock      didFinishBlock;

@end
