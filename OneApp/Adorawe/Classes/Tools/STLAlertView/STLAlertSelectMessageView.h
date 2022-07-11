//
//  STLAlertSelectMessageView.h
// XStarlinkProject
//
//  Created by odd on 2020/9/22.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^STLAlertSelectMessageCallBlock)(NSInteger buttonIndex, NSString *title);


@interface STLAlertSelectMessageView : UIView

@property (nonatomic, strong) NSString    *alerTitle;
@property (nonatomic, strong) id          alerMessage;
@property (nonatomic, strong) UIColor     *msgColor;
@property (nonatomic, strong) UIImage     *closeBtnImage;
@property (nonatomic, strong) NSArray     *otherBtnTitles;
@property (nonatomic, strong) NSArray     *otherBtnAttributes;

@property (nonatomic, strong) UIView      *container;
@property (nonatomic, strong) UILabel     *title;
@property (nonatomic, strong) UILabel     *cotentTip;
@property (nonatomic, strong) UIView      *buttomBtnView;

/** AlertView消失回调 */
@property (nonatomic, copy) void (^closeBlock)(void);

@property (nonatomic, copy) void (^alertCallBlock)(NSInteger buttonIndex, NSString *btnTitle);

+ (void)showMessage:(id)msg btnTitles:(NSArray *)otherBtnTitles alertCallBlock:(STLAlertSelectMessageCallBlock)alertCallBlock;
@end
