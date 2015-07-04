//
//  RHSocketConfig.h
//  RHSocketDemo
//
//  Created by zhuruhong on 15/6/18.
//  Copyright (c) 2015年 zhuruhong. All rights reserved.
//

#ifndef RHSocketDemo_RHSocketConfig_h
#define RHSocketDemo_RHSocketConfig_h

#ifdef DEBUG
#define RHSocketDebug
#endif

#ifdef RHSocketDebug
#define RHSocketLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define RHSocketLog(format, ...)
#endif

#endif
