//---------------------------------------------------------------------------------------
//  Created by znek on Fri 31-Oct-1997
//  @(#)$Id: EDRange.m,v 2.1 2003-04-08 16:51:34 znek Exp $
//
//  Copyright (c) 1997,1999 by Erik Doernenburg. All rights reserved.
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

#import <Foundation/Foundation.h>
#import "EDRange.h"


//---------------------------------------------------------------------------------------
    @implementation EDRange
//---------------------------------------------------------------------------------------

/*" Range objects provide an object-oriented wrapper around NSSRanges; especially useful when you want to store them in collections. "*/

//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    [self setVersion:1];
}


//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

/*" Creates and returns a range object with starting at loc and ranging len indices. "*/

+ (id)rangeWithLocation:(NSUInteger)loc length:(NSUInteger)len
{
    return [[[self alloc] initWithLocation:loc length:len] autorelease];
}


/*" Creates and returns a range object with starting at startLoc and ending at endLoc. "*/

+ (id)rangeWithLocations:(NSUInteger)startLoc:(NSUInteger)endLoc
{
    return [[[self alloc] initWithLocations:startLoc:endLoc] autorelease];
}


/*" Creates and returns a range object for the NSRange aRangeValue. "*/
    
+ (id)rangeWithRangeValue:(NSRange)aRangeValue
{
    return [[[self alloc] initWithRangeValue:aRangeValue] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT
//---------------------------------------------------------------------------------------

/*" Initialises a newly allocated range with the NSRange aRangeValue. "*/

- (id)initWithRangeValue:(NSRange)aRangeValue
{
    [super init];
    range = aRangeValue;
    return self;
}


/*" Initialises a newly allocated range by setting its starting location to loc and its range to len. "*/

- (id)initWithLocation:(NSUInteger)loc length:(NSUInteger)len
{
    return [self initWithRangeValue:NSMakeRange(loc, len)];
}


/*" Initialises a newly allocated range by setting its starting location to startLoc and its end location to endLoc. "*/

- (id)initWithLocations:(NSUInteger)startLoc:(NSUInteger)endLoc
{
    return [self initWithRangeValue:NSMakeRange(startLoc, endLoc - startLoc + 1)];
}


//---------------------------------------------------------------------------------------
//	NSCODING
//---------------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeValuesOfObjCTypes:"II", &(range.location), &(range.length)];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned int version;

    [super init];
    version = [decoder versionForClassName:@"EDRange"];
    if(version > 0)
        {
        [decoder decodeValuesOfObjCTypes:"II", &(range.location), &(range.length)];
        }
    return self;
}


//---------------------------------------------------------------------------------------
//	NSCOPYING
//---------------------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
    if(NSShouldRetainWithZone(self, zone))
        return [self retain];
    return [[EDRange allocWithZone:zone] initWithRangeValue:range];
}


//---------------------------------------------------------------------------------------
//	DESCRIPTION & COMPARISONS
//---------------------------------------------------------------------------------------

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@ 0x%x: (%d..%d)>", NSStringFromClass(isa), (void *)self, range.location, range.location + range.length - 1];
}


- (NSUInteger)hash
{
    return range.location + NSSwapInt(range.length);
}


- (BOOL)isEqual:(id)otherObject
{
    if(otherObject == nil)
        return NO;
    else if((isa != ((EDRange *)otherObject)->isa) && ([otherObject isKindOfClass:[EDRange class]] == NO))
        return NO;
    return NSEqualRanges(range, ((EDRange *)otherObject)->range);
}


/*" Returns YES if otherRange is equivalent to the receiver, NO otherwise. When you know both objects are ranges, this method is a faster way to check equality than #{isEqual:}. "*/

- (BOOL)isEqualToRange:(EDRange *)otherRange
{
    return NSEqualRanges(range, otherRange->range);
}


/*" Returns !{NSOrderedAscending} if the start location of the receiver is greater than the one of %otherRange, !{NSOrderedSame} if both have the same start location and !{NSOrderedDescending} otherwise. "*/

- (NSComparisonResult)compareLocation:(EDRange *)otherRange
{
    if(range.location < otherRange->range.location)
        return NSOrderedAscending;
    else if(range.location > otherRange->range.location)
        return NSOrderedDescending;
    return NSOrderedSame;
}


//---------------------------------------------------------------------------------------
//	ATTRIBUTES
//---------------------------------------------------------------------------------------

/*" Returns the (start) location of the range. "*/

- (NSUInteger)location
{
    return range.location;
}


/*" Returns the length of the range. "*/

- (NSUInteger)length
{
    return range.length;
}


/*" Returns YES if %index is in the range, i.e. startLocation <= index <= endLocation. "*/

- (BOOL)isLocationInRange:(NSUInteger)index
{
    return NSLocationInRange(index, range);
}


/*" Returns the end location of the range, i.e. startLocation + length - 1. "*/

- (NSUInteger)endLocation
{
    return NSMaxRange(range) - 1;
}


/*" Returns the corresponding NSRange. "*/

- (NSRange)rangeValue
{
    return range;
}


//---------------------------------------------------------------------------------------
//	DERIVED RANGES
//---------------------------------------------------------------------------------------

/*" Returns a range object describing the intersection of the receiver and %otherRange, i.e. a range containing the indices that exist in both ranges, !{nil} if the intersection is empty. "*/

- (EDRange *)intersectionRange:(EDRange *)otherRange
{
    NSRange	result;

    result = NSIntersectionRange(range, otherRange->range);
    if(result.length == 0)
        return nil;

    return [[[[self class] allocWithZone:[self zone]] initWithRangeValue:result] autorelease];
}


/*" Returns a range object describing the union of the receiver and %otherRange, i.e. a range containing the indices in and between both ranges. "*/

- (EDRange *)unionRange:(EDRange *)otherRange
{
    NSRange	result;

    result = NSUnionRange(range, otherRange->range);
 
    return [[[[self class] allocWithZone:[self zone]] initWithRangeValue:result] autorelease];
}


/*" Returns YES if %otherRange is fully contained in the receiver, i.e. the union of both is equivalent to the receiver. "*/

- (BOOL)containsRange:(EDRange *)otherRange
{
    return ((range.location <= otherRange->range.location) && (NSMaxRange(range) >= NSMaxRange(otherRange->range)));
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------

