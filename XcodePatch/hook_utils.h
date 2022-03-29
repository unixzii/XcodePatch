//
//  hook_utils.h
//  XcodePatch
//
//  Created by Cyandev on 2022/3/29.
//

#ifndef hook_utils_h
#define hook_utils_h

#import <objc/runtime.h>

extern void xcp_hook_method(Class cls, SEL sel, id (^interceptorBuilder)(IMP origIMP));

#endif /* hook_utils_h */
