//
//  STLAlertMessageView.h
// XStarlinkProject
//
//  Created by odd on 2020/9/14.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>


/*
 *-------[----xxxx----- x]
 
 *-------[----mesage-----]
 *-------[---------------]
 *-------[----button-----]
 *-------[----button-----]
 *-------[---------------]
 */

typedef void(^STLAlertTipCallBlock)(NSInteger buttonIndex, NSString *title);


@interface STLAlertMessageView : UIView


@property (nonatomic, strong) NSString    *alerTitle;
@property (nonatomic, strong) id          alerMessage;
@property (nonatomic, strong) UIImage     *closeBtnImage;
@property (nonatomic, strong) NSArray     *otherBtnTitles;
@property (nonatomic, strong) NSArray     *otherBtnAttributes;


@property (nonatomic, strong) UIView      *container;
@property (nonatomic, strong) UIButton    *closeBtn;
@property (nonatomic, strong) UILabel     *title;
@property (nonatomic, strong) UILabel     *cotentTip;
@property (nonatomic, strong) UIView      *buttomBtnView;

/** AlertView消失回调 */
@property (nonatomic, copy) void (^closeBlock)(void);
/** AlertView消失回调 */
@property (nonatomic, copy) void (^alertCallBlock)(NSInteger buttonIndex, NSString *btnTitle);


+ (instancetype)alertWithCloseBtnImage:(UIImage *)closeBtnImage
                             alerTitle:(NSString *)alerTitle
                           alerMessage:(id)alerMessage
                        otherBtnTitles:(NSArray *)otherBtnTitles
                    otherBtnAttributes:(NSArray <NSDictionary<NSAttributedStringKey, id> *> *)otherBtnAttributes
                        alertCallBlock:(STLAlertTipCallBlock)alertCallBlock;

+ (void)showMessage:(NSString *)msg btnTitles:(NSArray *)otherBtnTitles;
@end

