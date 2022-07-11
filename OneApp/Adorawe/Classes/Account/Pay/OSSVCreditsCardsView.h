//
//  OSSVCreditsCardsView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <WebKit/WebKit.h>

typedef void(^PPViewCallBackBlock)(STLOrderPayStatus);

@interface OSSVCreditsCardsView : UIView

@property (nonatomic, copy) PPViewCallBackBlock block;

- (void)setUrl:(NSString *)url body:(NSDictionary *)body;

@end
