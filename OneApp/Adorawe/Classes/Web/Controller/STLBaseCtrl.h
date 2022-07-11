//
//  STLBaseCtrl.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STLBaseCtrl : UIViewController

@property (nonatomic, assign) BOOL firstEnter;
@property (nonatomic,strong) NSMutableArray <OSSVBasesRequests *>*operations;

///为了统计
@property (nonatomic, copy) NSString    *currentButtonKey;
@property (nonatomic, copy) NSString    *currentPageCode;


///为了统计
@property (nonatomic, copy) NSString    *lastButtonKey;
@property (nonatomic, copy) NSString    *lastSku_code;

///传递字段
@property (nonatomic, strong) NSMutableDictionary *transmitMutDic;

@property (nonatomic, assign) BOOL          isModalPresent;


-(void)stopRequest;

-(void)goBackAction;

- (void)stlInitView;

- (void)stlAutoLayoutView;
@end
