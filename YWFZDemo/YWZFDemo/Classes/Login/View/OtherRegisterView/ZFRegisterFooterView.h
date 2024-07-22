//
//  ZFRegisterFooterView.h
//  ZZZZZ
//
//  Created by YW on 29/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TreatyLinkAction_ProvacyPolicy,
    TreatyLinkAction_TermsUse,
} ZFTreatyLinkAction;

typedef void(^RegisterPrivacyPolicyActionBlock)(ZFTreatyLinkAction actionType);
typedef void(^SignupButtonCompletionHandler)(BOOL isAgree, BOOL isSubscribe);

@interface ZFRegisterFooterView : UITableViewHeaderFooterView

@property (nonatomic, copy) RegisterPrivacyPolicyActionBlock          privacyPolicyActionBlock;
@property (nonatomic, copy) SignupButtonCompletionHandler             registerButtonCompletionHandler;


- (void)showTipAnimation;

@end

