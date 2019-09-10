//
//  RHSocketMacros.h
//  Example
//
//  Created by zhuruhong on 2019/9/8.
//  Copyright © 2019年 zhuruhong. All rights reserved.
//

#ifndef RHSocketMacros_h
#define RHSocketMacros_h

#ifdef DEBUG
#define RHSocketDebug
#endif

#ifdef RHSocketDebug
//#define RHSocketLog(format, ...) NSLog((@"**************************************\n[File: %s]\n[Function: %s]\n[Line: %d] " format), __FILE__, __FUNCTION__, __LINE__, ## __VA_ARGS__)
#define RHSocketLog(format, ...) NSLog((@"[Function: %s]\n " format), __FUNCTION__, ## __VA_ARGS__)
//#define RHSocketLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define RHSocketLog(format, ...)
#endif


#define RHSocketBlockRun(block, ...) block ? block(__VA_ARGS__) : nil

#define APP_VERSION      [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#endif /* RHSocketMacros_h */
