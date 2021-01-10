//
//  BookTableCell.h
//  YLRead
//
//  Created by 苏沫离 on 2017/7/27.
//  Copyright © 2017 苏沫离. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookModel.h"

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT CGFloat const kBookTableCellHeight;
@interface BookTableCell : UITableViewCell
@property (nonatomic ,strong) BookModel *book;
@end

NS_ASSUME_NONNULL_END
