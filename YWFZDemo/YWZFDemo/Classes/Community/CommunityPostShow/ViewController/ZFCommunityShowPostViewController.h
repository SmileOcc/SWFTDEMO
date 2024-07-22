//
//  ZFCommunityShowPostViewController.h
//  ZZZZZ
//
//  Created by YW on 16/11/26.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "PYAblum.h"
#import "ZFCommunityHotTopicModel.h"

@interface ZFCommunityShowPostViewController : ZFBaseViewController

@property (nonatomic, strong) NSMutableArray <PYAssetModel *> *selectAssetModelArray;
/// 选择的热门话题
@property (nonatomic, strong) ZFCommunityHotTopicModel    *selectHotTopicModel;
@property (nonatomic, assign) NSInteger comeFromeType;//0:默认, 1:H5页面人脸识别发帖

@end
