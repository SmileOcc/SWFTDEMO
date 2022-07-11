//
//  OSSVPersonalIdView.h
// XStarlinkProject
//
//  Created by Kevin on 2020/12/5.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCartOrderInfoViewModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol OSSVPersonalIdViewDelegate <NSObject>

@optional
- (void)payMentWithIdCard:(UITextField *)textField;

@end

@interface OSSVPersonalIdView : UIView
@property (nonatomic, weak) id<OSSVPersonalIdViewDelegate>delegate;
-(void)showView;
-(void)hiddenView;
@property (nonatomic, strong) OSSVCartOrderInfoViewModel *infoModel;
@property (copy,nonatomic) NSString *errorText;
@end

NS_ASSUME_NONNULL_END
