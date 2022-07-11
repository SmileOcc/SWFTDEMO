//
//  STLLoginFooterView.h
// XStarlinkProject
//
//  Created by odd on 2020/7/31.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    TreatyLinkAction_ProvacyPolicy,
    TreatyLinkAction_TermsUse,
} STLTreatyLinkAction;

typedef void(^GoogleplusCompletionHandler)(void);
typedef void(^FacebookCompletionHandler)(void);
typedef void(^AppleCompletionHandler)(void);
typedef void(^RegisterPrivacyPolicyActionBlock)(STLTreatyLinkAction actionType);

@interface STLLoginFooterView : UIView

@property (nonatomic, copy) GoogleplusCompletionHandler       googleplusCompletionHandler;
@property (nonatomic, copy) FacebookCompletionHandler         facebookCompletionHandler;
@property (nonatomic, copy) AppleCompletionHandler         appleCompletionHandler;

@property (nonatomic, copy) RegisterPrivacyPolicyActionBlock        privacyPolicyActionBlock;

@property (nonatomic, copy) NSString *textTitleTipText;

@end

