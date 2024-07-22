//
//  ZFCollectionPostListModel.m
//  ZZZZZ
//
//  Created by YW on 2019/6/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCollectionPostListModel.h"

@implementation ZFCollectionPostListModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"list" : [ZFCollectionPostItemModel class]
             };
}

@end



@implementation ZFCollectionPostItemModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{
             @"reviewPic" : [ZFCollectionPostReviewPicModel class]
             };
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"idx"   :@"id",
             };
}
@end



@implementation ZFCollectionPostReviewPicModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"idx"   :@"id",
             };
}
@end
