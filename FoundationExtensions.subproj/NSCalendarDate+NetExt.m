//---------------------------------------------------------------------------------------
//  NSCalendarDate+NetExt.m created by erik
//  @(#)$Id: NSCalendarDate+NetExt.m,v 2.1 2003/04/08 17:06:03 znek Exp $
//
//  Copyright (c) 2002 by Axel Katerbau. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Axel Katerbau in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "utilities.h"
#import "NSCalendarDate+NetExt.h"


//---------------------------------------------------------------------------------------
    @implementation NSCalendarDate(EDNetExt)
//---------------------------------------------------------------------------------------

#import <sys/types.h>
#import <stdio.h>
#import <sys/stat.h>

+ (id)dateWithMessageTimeSpecification:(NSString *)timespec
    /*"
Attempts to parse a date according to the rules in RFC 2822. However, some mailers don't follow that format as specified, so dateFromRFC2822String tries to guess correctly in such cases. The receiver is a string containing an RFC 2822 date, such as 'Mon, 20 Nov 1995 19:12:08 -0500'. If it succeeds in parsing the date, dateFromRFC2822String returns a NSCalendarDate. nil otherwise.
     "*/
{
    const char *lossyCString;
    char *dateString;
    char *dayString;
    char *monthString;
    char *yearString;
    char *timeString;
    char *timezoneString;
    char *dateStringToken;
    char *lowerPtr;
    char *help;
    size_t length, month;
    char lastChar;
    const char **monthnamesPtr;
    int day, year, thh, tmm, tss;
    NSTimeZone *timeZone = nil;

    static const char *monthnames[] = {
        "jan", "feb", "mar", "apr", "may", "jun", "jul",
        "aug", "sep", "oct", "nov", "dec",
        "january", "february", "march", "april", "may", "june", "july",
        "august", "september", "october", "november", "december",
        NULL};
    static const char *daynames[] = {
        "mon", "tue", "wed", "thu", "fri", "sat", "sun",
        NULL};

    // get the string to work on
    if ( (lossyCString = [timespec cStringUsingEncoding:NSASCIIStringEncoding]) == NULL) // DFH = was lossyCString
        return nil;
    if ( (dateString = malloc(strlen(lossyCString) + 1)) == NULL)
        return nil;
    strcpy(dateString, lossyCString);

    // ### Remove day names at the beginning if present
    // get first token
    do
        {
            if( (dateStringToken = strtok(dateString, " -")) == NULL)
                {
                free(dateString);
                return nil;
                }
        } while (dateStringToken[0] == '\0'); // dont accept empty strings

    // get last char
    length = strlen(dateStringToken);
    lastChar = dateStringToken[length - 1];

    if ((lastChar == ',') || (lastChar == '.'))
        {
        // skip this token
        do
            {
                if( (dateStringToken = strtok(NULL, " -")) == NULL)
                    {
                    free(dateString);
                    return nil;
                    }
            } while (dateStringToken[0] == '\0'); // dont accept empty strings
        }
    else // test if it's a day name
        {
        const char **daynamesPtr;

        // make lower case string;
        for (lowerPtr = dateStringToken; *lowerPtr != '\0'; lowerPtr++)
            {
            *lowerPtr = tolower(*lowerPtr);
            }

        for (daynamesPtr = daynames; *daynamesPtr != NULL; daynamesPtr++)
            {
            if (strcmp(*daynamesPtr, dateStringToken) == 0) // found day name
                {
                // skip this token
                do
                    {
                        if( (dateStringToken = strtok(NULL, " -")) == NULL)
                            {
                            free(dateString);
                            return nil;
                            }
                    } while (dateStringToken[0] == '\0'); // dont accept empty strings
                }
            }
        }

    // ## day
    dayString = dateStringToken;

    // next token
    do
        {
            if( (dateStringToken = strtok(NULL, " -")) == NULL) // month required
                {
                free(dateString);
                return nil;
                }
        } while (dateStringToken[0] == '\0'); // dont accept empty strings

    monthString = dateStringToken;

    // next token
    do
        {
            if( (dateStringToken = strtok(NULL, " ")) == NULL)  // year required
                {
                free(dateString);
                return nil;
                }
        } while (dateStringToken[0] == '\0'); // dont accept empty strings

    yearString = dateStringToken;

    // ## time
    // next token
    do
        {
            if( (dateStringToken = strtok(NULL, " +")) == NULL)
                {
                free(dateString);
                return nil;
                }
        } while (dateStringToken[0] == '\0'); // dont accept empty strings

    timeString = dateStringToken;

    // next token
    for(;;)
        {
        timezoneString = strtok(NULL, " ");

        if (timezoneString == NULL)
            break;
        if (strlen(timezoneString) > 0)
            break;
        }

    // ## handle months

    // make lower case string;
    for (lowerPtr = monthString; *lowerPtr != '\0'; lowerPtr++)
        {
        *lowerPtr = tolower(*lowerPtr);
        }

    for (monthnamesPtr = monthnames; *monthnamesPtr != NULL; monthnamesPtr++)
        {
        if (strcmp(*monthnamesPtr, monthString) == 0) // found month name
            {
            break;
            }
        }

    // month name not found?
    if (*monthnamesPtr == NULL)
        {
        // swap day and month
        help = dayString;
        dayString = monthString;
        monthString = help;

        // make lower case string;
        for (lowerPtr = monthString; *lowerPtr != '\0'; lowerPtr++)
            {
            *lowerPtr = tolower(*lowerPtr);
            }

        // search again
        for (monthnamesPtr = monthnames; *monthnamesPtr != NULL; monthnamesPtr++)
            {
            if (strcmp(*monthnamesPtr, monthString) == 0) // found month name
                {
                break;
                }
            }

        // still not found?
        if (*monthnamesPtr == NULL)
            {
            free(dateString);
            return nil;
            }
        }

    // month found calculate month number
    month = ((monthnamesPtr - monthnames) + 1);
    if (month > 12)
        {
        month -= 12;
        }

    // ### handle day
    day = atoi(dayString);

    if ( (day == 0) || (day == INT_MAX) || (day == INT_MIN) )
        {
        free(dateString);
        return nil;
        }

    // ## handle year

    // test if year and time are swapped
    if (strchr(yearString, ':') != NULL) // they are swapped
        {
        help = yearString;
        yearString = timeString;
        timeString = help;
        }

    // test if timezone and year are swapped
    if (! isdigit(yearString[0]))
        {
        help = yearString;
        yearString = timezoneString;
        timezoneString = help;
        }

    year = atoi(yearString);
    if (strlen(yearString) == 2) // handle 2 digit years gracefully
        {
        if (year > 69)
            year += 1900;
        else
            year += 2000;
        }

    if ( (year == 0) || (year == INT_MAX) || (year == INT_MIN) ) // sanity check
        {
        free(dateString);
        return nil;
        }

    // ## handle time

    thh = tmm = tss = 0;
    // hour
    if( (dateStringToken = strtok(timeString, ":")) != NULL)
        {
        thh = atoi(dateStringToken);

        if( (dateStringToken = strtok(NULL, ":")) != NULL)
            {
            tmm = atoi(dateStringToken);

            if( (dateStringToken = strtok(NULL, ":")) != NULL)
                {
                tss = atoi(dateStringToken);
                }
            }
        else
            {
            tmm = 0;
            }
        }

    // handle timezone
    if (timezoneString != NULL)
        {
        NSString *tz;

        tz = [[NSString alloc] initWithCString:timezoneString];
        timeZone = [NSTimeZone timeZoneWithAbbreviation:tz];

        [tz release];
        }

    if (timeZone == nil)
        {
        int timezoneOffset;
        int timezoneSign;

        if (timezoneString == NULL)
            {
            timezoneOffset = 0;
            }
        else
            {
            timezoneOffset = atoi(timezoneString);
            if (timezoneOffset < 0)
                {
                timezoneSign = -1;
                timezoneOffset *= -1;
                }
            else
                {
                timezoneSign = 1;
                }

            timezoneOffset = timezoneSign * ( (timezoneOffset/100)*3600 + (timezoneOffset % 100) * 60);
            }

        timeZone = [NSTimeZone timeZoneForSecondsFromGMT:timezoneOffset];

        if (timeZone == nil)
            {
            free(dateString);
            return nil;
            }
        }

    free(dateString);

    // calculate date
    return [NSCalendarDate dateWithYear:year month:month day:day hour:thh minute:tmm second:tss timeZone:timeZone];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
