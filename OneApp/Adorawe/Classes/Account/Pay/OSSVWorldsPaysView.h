//
//  OSSVWorldsPaysView.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/21.
//  Copyright © 2017年 XStarlinkProject. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface OSSVWorldsPaysView : UIView

@property (nonatomic, copy) void(^callBackBlock)(STLOrderPayStatus);

- (void)setUrl:(NSString *)url body:(NSDictionary *)body;

@end
