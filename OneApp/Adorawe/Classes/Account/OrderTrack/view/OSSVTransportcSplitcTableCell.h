//
//  OSSVTransportcSplitcTableCell.h
// XStarlinkProject
//
//  Created by Kevin on 2020/11/23.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVTrackeListeMode.h"
NS_ASSUME_NONNULL_BEGIN

@protocol STLTransportSplitTableViewCellDelegate <NSObject>

@optional
- (void)jumpIntoTrackingListWithorderNumber:(NSString *)trackId;

@end

@interface OSSVTransportcSplitcTableCell : UITableViewCell
@property (nonatomic, strong) OSSVTrackeListeMode *trackListModel;
@property (nonatomic, weak) id<STLTransportSplitTableViewCellDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
