//
//  STLALertTitleMessageView.h
// XStarlinkProject
//
//  Created by odd on 2020/12/8.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>


/*
 *-------[----xxxx(option)-------]
 
 *-------[----mesage-----]
 *-------[---------------]
 *-------[----button-----]
 *-------[---------------]
 */


/*
 *-------[----xxxx(option)-------]

 *-------[----mesage-----]
 *-------[---------------]
 *-------[---btn---btn---]
 *-------[---------------]
 */

typedef void(^STLALertTitleMessageCallBlock)(NSInteger buttonIndex, NSString *title);



@interface STLALertTitleMessageView : UIView


@property (nonatomic, strong) NSString    *alerTitle;
@property (nonatomic, strong) id          alerMessage;
@property (nonatomic, strong) NSArray     *otherBtnTitles;
@property (nonatomic, strong) NSArray     *otherBtnAttributes;


@property (nonatomic, strong) UIView      *container;
@property (nonatomic, strong) UILabel     *title;
@property (nonatomic, strong) UILabel     *cotentTip;
@property (nonatomic, strong) UIView      *buttomBtnView;


/** AlertView消失回调 */
@property (nonatomic, copy) void (^closeBlock)(void);
/** AlertView消失回调 */
@property (nonatomic, copy) void (^alertCallBlock)(NSInteger buttonIndex, NSString *btnTitle);

+ (void)showMessage:(NSString *)msg btnTitles:(NSArray *)otherBtnTitles;

+ (instancetype)alertWithAlerTitle:(NSString *)alerTitle
                           alerMessage:(id)alerMessage
                        otherBtnTitles:(NSArray *)otherBtnTitles
                    otherBtnAttributes:(NSArray <NSDictionary<NSAttributedStringKey, id> *> *)otherBtnAttributes
                    alertCallBlock:(STLALertTitleMessageCallBlock)alertCallBlock;
@end

