//
//  OSSVLocationePopeView.h
// XStarlinkProject
//
//  Created by Kevin on 2021/2/20.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol STLLocationPopViewDelegate <NSObject>

@optional
- (void)jumpToSettings;
- (void)cancelAction;
@end

@interface OSSVLocationePopeView : UIView
@property (nonatomic, weak) id<STLLocationPopViewDelegate>delegate;

-(void)showView;
-(void)hiddenView;

@end

NS_ASSUME_NONNULL_END
