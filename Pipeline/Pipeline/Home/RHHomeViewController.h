//
//  RHHomeViewController.h
//  Pipeline
//
//  Created by zhuruhong on 2019/9/9.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import <QMUIKit/QMUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RHHomeViewController : QMUICommonTableViewController

@property(nonatomic, strong) NSArray<NSString *> *dataSource;

@end

NS_ASSUME_NONNULL_END
