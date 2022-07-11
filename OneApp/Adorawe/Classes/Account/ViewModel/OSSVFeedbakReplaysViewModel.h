//
//  OSSVFeedbakReplaysViewModel.h
// XStarlinkProject
//
//  Created by odd on 2021/4/19.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "BaseViewModel.h"
#import "OSSVFeedBakReplaQuestiCell.h"
#import "OSSVFeedbackReplaAnsweCell.h"

#import "OSSVFeedbacksReplaysModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVFeedbakReplaysViewModel : BaseViewModel<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UIViewController *controller;

@end

NS_ASSUME_NONNULL_END
