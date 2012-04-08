//
// PollingSongChangeNotifier.m
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

#import "PollingSongChangeNotifier.h"
#import "iTunes.h"


@interface PollingSongChangeNotifier ()

@property (retain, nonatomic) id <SongChangedDelegate> delegate;
@property (retain, nonatomic) iTunesApplication *iTunes;
@property (copy, nonatomic) NSString *currentSong;

@end


@implementation PollingSongChangeNotifier

@synthesize delegate;
@synthesize iTunes;
@synthesize currentSong;


- (id)initWithDelegate:(id <SongChangedDelegate>)theDelegate {
	if ((self = [super init])) {
		self.delegate = theDelegate;
		self.iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
		
		// Schedule the first song check
		[self performSelectorOnMainThread:@selector(checkSong) withObject:nil waitUntilDone:NO];
	}
	return self;
}


- (void)checkSong {
    if ([iTunes isRunning]) {
		NSString *reportedSong = iTunes.currentStreamTitle;
		
        // Check if the song title has changed, being careful with nil==nil comparisons
		if (!(reportedSong == currentSong || [reportedSong isEqualToString:currentSong])) {
			self.currentSong = reportedSong;
			
			[delegate songChanged:currentSong];
		}
	}

	// Self recurse again in 5 seconds to check if the song has changed
	[self performSelector:@selector(checkSong) withObject:nil afterDelay:5.0];
}


- (void)dealloc {
	[PollingSongChangeNotifier cancelPreviousPerformRequestsWithTarget:self selector:@selector(checkSong) object:nil];
	self.delegate = nil;
	self.iTunes = nil;
	self.currentSong = nil;
	[super dealloc];
}


@end
