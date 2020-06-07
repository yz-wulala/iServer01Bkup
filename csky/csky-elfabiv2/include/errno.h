/*
 * Copyright (C): 2012 Hangzhou C-SKY Microsystem Co.,LTD.
 * Author: Zhang Zhao  (zhao_zhang@c-sky.com)
 * Contrbutior: Chunqiang Li
 * Date: 2012-5-4
 */

#ifndef _ERRNO_H_
#define _ERRNO_H_

#include <features.h>

#include <serf/linux_errno.h>
#ifdef __cplusplus
extern "C" {
#endif

# undef EDOM
# undef EILSEQ
# undef ERANGE

extern int errno;

#define EDOM   33       /* Math arg out of domain of func */
#define ERANGE 34       /* Math result not representable */
#define EILSEQ 138      /* Illegal byte sequence.  */

#ifdef __cplusplus
}
#endif
#endif
