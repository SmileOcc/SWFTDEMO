//
//  ZFUserSexSelectViewController.h
//  ZZZZZ
//
//  Created by 602600 on 2019/11/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DidFinishBlock)(void);

@interface ZFUserSexSelectViewController : UIViewController

@property (nonatomic, copy)   DidFinishBlock      didFinishBlock;

@end

NS_ASSUME_NONNULL_END
