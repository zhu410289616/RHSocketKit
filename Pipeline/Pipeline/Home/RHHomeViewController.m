//
//  RHHomeViewController.m
//  Pipeline
//
//  Created by zhuruhong on 2019/9/9.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import "RHHomeViewController.h"
#import "RHClientViewController.h"

@implementation RHHomeViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [self initDataSource];
    }
    return self;
}

//- (void)setupNavigationItems {
//    [super setupNavigationItems];
//    self.title = @"Home";
//    self.navigationItem.rightBarButtonItem = [UIBarButtonItem qmui_itemWithImage:UIImageMake(@"icon_nav_about") target:self action:@selector(handleAboutItemEvent)];
//    AddAccessibilityLabel(self.navigationItem.rightBarButtonItem, @"当前IP");
//}

- (void)handleAboutItemEvent {
    
}

- (void)initDataSource {
    self.dataSource = @[@"Delimiter Codec",
                        @"Variable Length Codec",
                        @"Protobuf Codec",
                        @"Http Codec",
                        @"Custom Codec",
                        @"Unknown Codec"
                        ];
}

- (void)didSelectCellWithTitle:(NSString *)title {
    RHClientViewController *viewController = [[RHClientViewController alloc] init];
    viewController.title = title;
    
    if ([title isEqualToString:@"Delimiter Codec"]) {
        viewController.codecType = RHTestCodecTypeDelimiter;
    } else if ([title isEqualToString:@"Variable Length Codec"]) {
        viewController.codecType = RHTestCodecTypeVariableLength;
    } else if ([title isEqualToString:@"Protobuf Codec"]) {
        viewController.codecType = RHTestCodecTypeProtobuf;
    } else if ([title isEqualToString:@"Http Codec"]) {
        viewController.codecType = RHTestCodecTypeHttp;
    } else if ([title isEqualToString:@"Custom Codec"]) {
        viewController.codecType = RHTestCodecTypeCustom;
    } else if ([title isEqualToString:@"Unknown Codec"]) {
        viewController.codecType = RHTestCodecTypeUnknown;
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"normal";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
//    cell.textLabel.font = UIFontMake(15);
//    cell.detailTextLabel.font = UIFontMake(13);
//    [cell updateCellAppearanceWithIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = [self.dataSource objectAtIndex:indexPath.row];
    [self didSelectCellWithTitle:title];
}

@end
