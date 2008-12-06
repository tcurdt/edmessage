//---------------------------------------------------------------------------------------
//  osdep.h created by erik on Wed 28-Jan-1998
//  @(#)$Id: osdep.h,v 2.4 2008-04-21 05:42:07 znek Exp $
//
//  Copyright (c) 1998-1999,2008 by Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Erik Doernenburg in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

// This file contains stuff that isn't necessarily portable between operating systems.

//---------------------------------------------------------------------------------------
// Mac OS X
//---------------------------------------------------------------------------------------

#if defined(__APPLE__)

#define ED_ERRNO errno

#import <stddef.h>
#import <unistd.h>
#import <netinet/in.h>
#import <netinet/tcp.h>
#import <sys/socket.h>
#import <sys/ioctl.h>
#import <sys/types.h>
#import <sys/dir.h>
#import <sys/errno.h>
#import <sys/stat.h>
#import <sys/uio.h>
#import <sys/file.h>
#import <sys/fcntl.h>
#import <nameser.h>
#import <resolv.h>


//---------------------------------------------------------------------------------------
// Unknown system
//---------------------------------------------------------------------------------------

#else

#error Unknown system!

#endif
