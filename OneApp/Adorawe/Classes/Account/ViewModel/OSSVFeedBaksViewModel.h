//
//  OSSVFeedBaksViewModel.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "BaseViewModel.h"

UIKIT_EXTERN NSString *const FeedBackKeyOfType;
UIKIT_EXTERN NSString *const FeedBackKeyOfEmail;
UIKIT_EXTERN NSString *const FeedBackKeyOfContent;
UIKIT_EXTERN NSString *const FeedBackKeyOfimages;

typedef void (^ShowPickerBlock)(NSString *info, NSInteger index);

@interface OSSVFeedBaksViewModel : BaseViewModel<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, copy) ShowPickerBlock showPickerBlock;

- (void)pickerViewDidSelected:(UIPickerView *)pickerView;
- (void)requestFeedBackReason;
@end
