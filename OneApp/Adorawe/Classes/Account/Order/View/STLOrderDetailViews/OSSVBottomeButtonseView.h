//
//  OSSVBottomeButtonseView.h
// XStarlinkProject
//
//  Created by Kevin on 2021/1/27.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol STLBottomButtonViewDelegate <NSObject>

@optional
- (void)clickCancel:(id)sender;
- (void)clickPayNow:(id)sender;
- (void)clickBuyAgain:(id)sender;
- (void)clickReview:(id)sender;


@end


@interface OSSVBottomeButtonseView : UIView
@property (nonatomic, weak)  id<STLBottomButtonViewDelegate>delegate;
@property (nonatomic, strong) UIView     *topLineView;
@property (nonatomic,strong) UIButton    *cancelBtn; //取消按钮
@property (nonatomic,strong) UIButton    *payNowBtn;  //支付按钮
@property (nonatomic,strong) UIButton    *buyAgainBtn; //再次购买
@property (nonatomic,strong) UIButton    *reviewBtn; //评论

@end



NS_ASSUME_NONNULL_END
