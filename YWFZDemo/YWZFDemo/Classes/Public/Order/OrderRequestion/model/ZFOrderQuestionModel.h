//
//  ZFOrderQuestionModel.h
//  ZZZZZ
//
//  Created by YW on 2019/3/20.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFOrderQuestionModel : NSObject

@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *contentId;

@end

NS_ASSUME_NONNULL_END
