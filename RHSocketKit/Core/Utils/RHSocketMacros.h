//
//  RHSocketMacros.h
//  Example
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#ifndef RHSocketMacros_h
#define RHSocketMacros_h

#define RHSocketBlockRun(block, ...) block ? block(__VA_ARGS__) : nil

#define APP_VERSION      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#endif /* RHSocketMacros_h */
