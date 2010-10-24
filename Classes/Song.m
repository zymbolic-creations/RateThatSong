//
// Song.m
// Copyright 2010 Mark Buer
//
// This file is part of RateThatSong.
//
// RateThatSong is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// RateThatSong is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with RateThatSong.  If not, see <http://www.gnu.org/licenses/>.
//

#import "Song.h"


@implementation Song

@synthesize artist;
@synthesize track;
@synthesize rating;


+ (NSString *)presentationStringFromRating:(Rating)aRating {
	switch (aRating) {
		case RatingBad:
			return @"-";
		case RatingGood:
			return @"+";
		case RatingVeryGood:
			return @"++";
	}
	return @"";
}


+ (Rating)ratingFromPresentationString:(NSString *)presentationString {
	if ([presentationString isEqualToString:@"-"]) {
		return RatingBad;
	} else if ([presentationString isEqualToString:@"+"]) {
		return RatingGood;
	} else if ([presentationString isEqualToString:@"++"]) {
		return RatingVeryGood;
	}
	return RatingNone;
}


- (id)init {
	if ((self = [super init])) {
		self.rating = RatingNone;
	}
	return self;
}


- (void)dealloc {
	self.artist = nil;
	self.track = nil;
	[super dealloc];
}


@end
