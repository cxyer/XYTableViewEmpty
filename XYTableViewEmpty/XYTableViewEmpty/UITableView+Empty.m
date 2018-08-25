//
//  UITableView+Empty.m
//  XYTableViewEmpty
//
//  Created by 蔡晓阳 on 2018/8/25.
//  Copyright © 2018 cxy. All rights reserved.
//

#import "UITableView+Empty.h"
#import <objc/runtime.h>

static NSString *emptyViewKey = @"emptyViewKey";

@interface EmptyView: UIView

- (void)addEmptyViewWithImage:(UIImage *)image withTip:(NSString *)tip;

@end

@implementation UITableView (Empty)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[UITableView new] swizzleSel:@selector(reloadData) withSel:@selector(xy_reloadData)];
    });
}

- (void)swizzleSel:(SEL)originalSel withSel:(SEL)newSel {
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSel);
    Method swizzledMethod = class_getInstanceMethod(class, newSel);
    if(class_addMethod(class, originalSel, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(class, newSel, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}


//用户自定义布局
- (UIView *)emptyView {
    return objc_getAssociatedObject(self, &emptyViewKey);
}

- (void)setEmptyView:(UIView *)emptyView {
    objc_setAssociatedObject(self, &emptyViewKey, emptyView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//默认布局
- (void)addEmptyViewWithImage:(UIImage *)image withTip:(NSString *)tip {
    EmptyView *emptyView = [[EmptyView alloc] init];
    emptyView.frame = self.frame;
    [emptyView addEmptyViewWithImage:image withTip:tip];
    self.emptyView = emptyView;
}

- (void)xy_reloadData {
    [self xy_reloadData];
    
    if (self.emptyView) {
        [self check];
    }
}

- (void)check {
    id<UITableViewDataSource> dataSource = self.dataSource;
    NSInteger sections = [dataSource numberOfSectionsInTableView:self];
    for (NSInteger i = 0; i < sections; i++) {
        if ([dataSource tableView:self numberOfRowsInSection:i]) {
            [self.emptyView removeFromSuperview];
            return;
        }
    }
    [self.superview addSubview:self.emptyView];
}

@end

@interface EmptyView()

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation EmptyView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self=[super initWithFrame:frame]) {
        [self addSubview:self.imgView];
        [self addSubview:self.tipLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat imgWidth = 150;
    CGFloat imgHeight = 150;
    
    self.imgView.frame = CGRectMake((width-imgWidth)/2, (height-imgHeight)/2, imgWidth, imgHeight);
    
    self.tipLabel.frame = CGRectMake(0, CGRectGetMaxY(self.imgView.frame)+10, width, 25);
    
}

- (void)addEmptyViewWithImage:(UIImage *)image withTip:(NSString *)tip {
    self.imgView.image = image;
    self.tipLabel.text = tip;
}


- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] init];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _imgView;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}


@end



