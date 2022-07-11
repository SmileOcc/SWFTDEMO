//
//  OSSVOrdereCodeConfirmView.h
// XStarlinkProject
//
//  Created by odd on 2020/10/20.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OSSVOrdereCodeConfirmView : UIView

@property (nonatomic, copy) void(^confirmRequestBlock)();


- (instancetype)initWithFrame:(CGRect)frame titleMsg:(NSString *)titleMsg phoneMsg:(NSString *)phoneMsg;
- (void)show;
- (void)dismiss;
@end

NS_ASSUME_NONNULL_END
