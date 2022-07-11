//
//  OSSVHomeRecommendToYouCCell.h
// OSSVHomeRecommendToYouCCell
//
//  Created by 10010 on 20/7/13.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSSVCollectCCellProtocol.h"
#import "CollectionCellModelProtocol.h"

@interface OSSVHomeRecommendToYouCCell : UICollectionViewCell
<
    OSSVCollectCCellProtocol
>
@end

@interface STLJustForYouCellModel : NSObject
<
    CollectionCellModelProtocol
>
@end
