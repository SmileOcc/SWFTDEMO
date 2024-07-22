//
//  ZFCommunityOutfitBorderCateModel.h
//  ZZZZZ
//
//  Created by YW on 2019/3/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 穿搭选择的边框分类
 */

@interface ZFCommunityOutfitBorderCateModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *is_show;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *cate_id;

@end

NS_ASSUME_NONNULL_END
