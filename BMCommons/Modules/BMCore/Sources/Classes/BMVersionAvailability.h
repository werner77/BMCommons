//
//  BMVersionAvailability.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/31/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#ifndef BMCommons_BMVersionAvailability_h
#define BMCommons_BMVersionAvailability_h

#define BM_PUSH_IGNORE_DEPRECATION_WARNING _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Wdeprecated-declarations\"")
#define BM_PUSH_IGNORE_UNDECLARED_SELECTOR_WARNING _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Wundeclared-selector\"")
#define BM_PUSH_IGNORE_SELECTOR_LEAK_WARNING _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"")
#define BM_POP_IGNORE_WARNING _Pragma("clang diagnostic pop")

#define BM_IGNORE_SELECTOR_LEAK_WARNING(code) BM_PUSH_IGNORE_SELECTOR_LEAK_WARNING \
        code \
        BM_POP_IGNORE_WARNING

#define BM_IGNORE_DEPRECATION_WARNING(code) BM_PUSH_IGNORE_DEPRECATION_WARNING \
        code \
        BM_POP_IGNORE_WARNING

#define BM_IGNORE_UNDECLARED_SELECTOR_WARNING(code) BM_PUSH_IGNORE_UNDECLARED_SELECTOR_WARNING \
        code \
        BM_POP_IGNORE_WARNING

#endif
