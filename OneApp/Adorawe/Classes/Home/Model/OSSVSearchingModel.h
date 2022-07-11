//
//  OSSVSearchingModel.h
// OSSVSearchingModel
//
//  Created by 10010 on 20/7/3.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVSearchingModel : NSObject

@property (nonatomic, strong) NSArray *goodList;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) NSInteger pageCount;
@property (nonatomic, assign) NSInteger page;

//MARK: -bytem search 回调参数
@property (nonatomic,copy) NSString *btm_apikey;
@property (nonatomic,copy) NSString *btm_index;
@property (nonatomic,copy) NSString *btm_sid;

///实际使用的搜索引擎
@property (nonatomic,copy) NSString *search_engine;

@end
