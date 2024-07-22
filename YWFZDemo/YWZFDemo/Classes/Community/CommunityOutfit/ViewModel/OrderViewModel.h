//
//  OrderViewModel.h
//  Zaful
//
//  Created by TsangFa on 16/11/29.
//  Copyright © 2016年 Y001. All rights reserved.
//

#import "BaseViewModel.h"

@interface ZFCommunityPostShowOrderViewModel : BaseViewModel<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,weak) UIViewController *controller;

- (void)requestOrderNetwork:(id)parmaters
                 completion:(void (^)(NSDictionary *pageDic))completion;

@end
