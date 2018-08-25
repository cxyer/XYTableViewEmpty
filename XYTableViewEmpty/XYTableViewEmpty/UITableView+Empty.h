//
//  UITableView+Empty.h
//  XYTableViewEmpty
//
//  Created by 蔡晓阳 on 2018/8/25.
//  Copyright © 2018 cxy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Empty)

@property (nonatomic, strong) UIView *emptyView;
- (void)addEmptyViewWithImage:(UIImage *)image withTip:(NSString *)tip;

@end
