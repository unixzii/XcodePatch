//
//  hook_utils.c
//  XcodePatch
//
//  Created by Cyandev on 2022/3/29.
//

#include "hook_utils.h"

void xcp_hook_method(Class cls, SEL sel, id (^interceptorBuilder)(IMP origIMP)) {
    Method meth = class_getInstanceMethod(cls, sel);
    IMP origIMP = method_getImplementation(meth);
    id interceptor = interceptorBuilder(origIMP);
    method_setImplementation(meth, imp_implementationWithBlock(interceptor));
}
