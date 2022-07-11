//
//  YXHotTopicModel.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXHotTopicModel.h"

@implementation YXHotTopicStockModel

@end

@implementation YXHotTopicTagModel

@end

@implementation YXHotTopicCommentModel

@end

@implementation YXHotTopicVoteSubModel

@end

@implementation YXHotTopicVoteModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"vote_item": [YXHotTopicVoteSubModel class]};
}

@end

@implementation YXHotTopicModel

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"comment": [YXHotTopicCommentModel class],
             @"stock_list": [YXHotTopicStockModel class],
    };
}

@end

@implementation YXHotTopicDiffModel

- (id<NSObject>)diffIdentifier {
    return self;
}

- (BOOL)isEqualToDiffableObject:(id<IGListDiffable>)object {
    return [self isEqual:object];
}

- (instancetype)initWithList:(NSArray <YXHotTopicModel *>*)list {
    
    if (self = [super init]) {
        self.list = list;
    }
    
    return self;
}

@end

