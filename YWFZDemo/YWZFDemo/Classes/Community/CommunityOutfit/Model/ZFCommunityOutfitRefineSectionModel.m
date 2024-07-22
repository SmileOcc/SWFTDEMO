//
//  ZFCommunityOutfitRefineSectionModel.m
//  ZZZZZ
//
//  Created by YW on 2018/10/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFCommunityOutfitRefineSectionModel.h"




//////////////////

@implementation ZFOutfitRefineCellModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"attrID"   : @"id" };
}

@end

//////////////////

@implementation ZFOutfitRefineDetailModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"childArray"   : @"child" };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"childArray"   : [ZFOutfitRefineCellModel class] };
    
}

@end



@implementation ZFCommunityOutfitRefineSectionModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{ @"refine_list"   : [ZFOutfitRefineDetailModel class] };
    
}

@end
