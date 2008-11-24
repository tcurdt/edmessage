//---------------------------------------------------------------------------------------
//  utilities.h created by erik on Mon 20-Jan-1997
//  @(#)$Id: utilities.h,v 2.1 2002/08/18 19:17:54 erik Exp $
//
//  Copyright (c) 1997 by Erik Doernenburg. All rights reserved.
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


//---------------------------------------------------------------------------------------
//	Constants
//---------------------------------------------------------------------------------------

#define LF ((char)'\x0A')
#define CR ((char)'\x0D')
#define TAB ((char)'\x09')
#define SPACE ((char)'\x20')
#define EQUALS ((char)'\x3D')
#define QMARK ((char)'\x3F')
#define UNDERSCORE ((char)'\x5F')
#define COLON ((char)':')

#define DOUBLEQUOTE @"\""


//---------------------------------------------------------------------------------------
//	Macros
//---------------------------------------------------------------------------------------

static __inline__ unsigned int umin(unsigned int a, unsigned int b)
{
    return (a < b) ? a : b;
}


static __inline__ BOOL iscrlf(char c)
{
    return (c == CR) || (c == LF);
}

static __inline__ BOOL iswhitespace(char c)
{
    return (c == SPACE) || (c == TAB);
}


static __inline__ const char *skipnewline(const char *ptr, const char *limit)
{
    if(*ptr == CR)
        ptr += 1;
    if((ptr < limit) && (*ptr == LF))
        ptr += 1;
    return ptr;
}


static __inline__ const char *skiptonewline(const char *ptr, const char *limit)
{
    while(iscrlf(*ptr) == NO)
        {
        ptr += 1;
        if(ptr == limit)
            return NULL;
        }
    return ptr;
}


static __inline__ const char *skipspace(const char *ptr, const char *limit)
{
    while(iswhitespace(*ptr) == YES)
        {
        ptr += 1;
        if(ptr == limit)
            return NULL;
        }
    return ptr;
}
