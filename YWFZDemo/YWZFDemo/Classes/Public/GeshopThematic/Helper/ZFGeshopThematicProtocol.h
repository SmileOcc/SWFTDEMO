//
//  ZFGeshopThematicProtocol.h
//  ZZZZZ
//
//  Created by YW on 2019/12/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#ifndef ZFGeshopThematicProtocol_h
#define ZFGeshopThematicProtocol_h

#import "ZFGeshopSectionModel.h"

@protocol ZFGeshopThematicProtocol <NSObject>

@optional

- (void)requestGeshopListData;

- (void)requestGeshopMorePageData;

- (void)handleSiftGoodsAction:(ZFGeshopSectionModel *)sectionModel
                     dataType:(NSInteger)dataType
                     openList:(BOOL)openListFlag;

- (void)clickListItemWithSectionModel:(ZFGeshopSectionModel *)sectionModel
                            indexPath:(NSIndexPath *)indexPath;

- (void)jumpDeeplinkAction:(NSString *)jump_link;


@end

#endif /* ZFGeshopThematicProtocol_h */
