//
//  RHClientViewController.h
//  Pipeline
//
//  Created by zhuruhong on 2019/9/10.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RHTestCodecType) {
    RHTestCodecTypeDelimiter = 0,
    RHTestCodecTypeVariableLength,
    RHTestCodecTypeProtobuf,
    RHTestCodecTypeHttp,
    RHTestCodecTypeCustom,
    RHTestCodecTypeUnknown
};

NS_ASSUME_NONNULL_BEGIN

@interface RHClientViewController : UIViewController

@property (nonatomic, assign) RHTestCodecType codecType;

@end

NS_ASSUME_NONNULL_END
