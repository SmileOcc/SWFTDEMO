//
//  SearchResultApi.h
//  Dezzal
//
//  Created by YW on 18/8/10.
//  Copyright © 2016年 7FD75. All rights reserved.
//

#import "SYBaseRequest.h"

@interface SearchResultApi : SYBaseRequest

- (instancetype)initSearchResultApiWithSearchString:(NSString *)searchString withPage:(NSInteger)page withSize:(NSInteger)size withOrderby:(NSString *)orderby featuring:(NSString *)featuring;

@end

