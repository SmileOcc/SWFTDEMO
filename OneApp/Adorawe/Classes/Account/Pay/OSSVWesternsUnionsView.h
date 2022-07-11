//
//  OSSVWesternsUnionsView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/26.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <WebKit/WebKit.h>

typedef void(^WUViewCallBackBlock)();

@interface OSSVWesternsUnionsView : UIView

/*点击取消Block*/
@property (nonatomic, copy) WUViewCallBackBlock block;

/*西联支付汇款信息链接*/
@property (nonatomic, copy) NSString            *url;

@end
