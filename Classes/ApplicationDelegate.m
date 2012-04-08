//
// ApplicationDelegate.m
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

#import "ApplicationDelegate.h"
#import "Song.h"


#define COLUMN_ARTIST	@"Artist"
#define COLUMN_TRACK	@"Track"
#define COLUMN_RATING	@"Rating"


@interface ApplicationDelegate ()

@property (retain, nonatomic) PollingSongChangeNotifier *notifier;
@property (retain, nonatomic) NSMutableArray *songs;
@property (assign, nonatomic) BOOL adjustEditedRowIndex;

@property (retain, nonatomic) Song *currentSong;
@property (retain, nonatomic) NSStatusItem *statusItem;
@property (retain, nonatomic) NSMenuItem *trackMenuItem;
@property (retain, nonatomic) NSMenuItem *ratingBadMenuItem;
@property (retain, nonatomic) NSMenuItem *ratingNoneMenuItem;
@property (retain, nonatomic) NSMenuItem *ratingGoodMenuItem;
@property (retain, nonatomic) NSMenuItem *ratingVeryGoodMenuItem;

- (void)createStatusMenu;
- (void)updateStatusMenuWithSong:(Song *)song;

@end


@implementation ApplicationDelegate

@synthesize window;
@synthesize tableView;

@synthesize notifier;
@synthesize songs;
@synthesize adjustEditedRowIndex;

@synthesize currentSong;
@synthesize statusItem;
@synthesize trackMenuItem;
@synthesize ratingBadMenuItem;
@synthesize ratingNoneMenuItem;
@synthesize ratingGoodMenuItem;
@synthesize ratingVeryGoodMenuItem;


#pragma mark -
#pragma mark NSApplicationDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[GrowlApplicationBridge setGrowlDelegate:self];
	
	notifier = [[PollingSongChangeNotifier alloc] initWithDelegate:self];
	songs = [[NSMutableArray alloc] init];

	[self createStatusMenu];
    [self updateStatusMenuWithSong:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
	NSString *filename = [@"~/Documents/Songs.txt" stringByExpandingTildeInPath];
	NSMutableString *persistentSongs = [NSMutableString stringWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:NULL];
	if (!persistentSongs) {
		persistentSongs = [NSMutableString string];
	}
	
	NSString *newline = @"\n";
	for (int i = songs.count - 1; i >= 0; i--) {
		Song *song = [songs objectAtIndex:i];
		
		if (song.rating == RatingNone)
			continue;
		
		[persistentSongs appendString:song.artist];
		[persistentSongs appendString:newline];
		[persistentSongs appendString:song.track];
		[persistentSongs appendString:newline];
		[persistentSongs appendString:[Song presentationStringFromRating:song.rating]];
		[persistentSongs appendString:newline];
		[persistentSongs appendString:newline];
	}
	
	[persistentSongs writeToFile:filename atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}


#pragma mark -
#pragma mark Status Bar


- (void)createStatusMenu {
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
	
    self.statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];
    statusItem.highlightMode = YES;
	
	NSString* statusBarIconFilename = [[NSBundle mainBundle] pathForResource:@"StatusBarIcon" ofType:@"png"];
	NSImage* statusBarIcon = [[NSImage alloc] initWithContentsOfFile:statusBarIconFilename];
	statusItem.image = statusBarIcon;
	[statusBarIcon release];
	
	NSMenu *menu = [[NSMenu alloc] initWithTitle:@"RateThatSong"];
	menu.autoenablesItems = NO;

	trackMenuItem = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
	[trackMenuItem setEnabled:NO];
	
	ratingBadMenuItem = [[NSMenuItem alloc] initWithTitle:@"-" action:@selector(changeRatingAction:) keyEquivalent:@""];
	ratingBadMenuItem.tag = RatingBad;
	
	ratingNoneMenuItem = [[NSMenuItem alloc] initWithTitle:@" " action:@selector(changeRatingAction:) keyEquivalent:@""];
	ratingNoneMenuItem.tag = RatingNone;
	
	ratingGoodMenuItem = [[NSMenuItem alloc] initWithTitle:@"+" action:@selector(changeRatingAction:) keyEquivalent:@""];
	ratingGoodMenuItem.tag = RatingGood;
	
	ratingVeryGoodMenuItem = [[NSMenuItem alloc] initWithTitle:@"++" action:@selector(changeRatingAction:) keyEquivalent:@""];
	ratingVeryGoodMenuItem.tag = RatingVeryGood;

	NSMenuItem *openApplicationMenuItem = [[NSMenuItem alloc] initWithTitle:@"Open RateThatSong..." action:@selector(bringApplicationToFrontAction) keyEquivalent:@""];
	
	[menu addItem:trackMenuItem];	
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:ratingBadMenuItem];
	[menu addItem:ratingNoneMenuItem];
	[menu addItem:ratingGoodMenuItem];
	[menu addItem:ratingVeryGoodMenuItem];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:openApplicationMenuItem];
	
	statusItem.menu = menu;
	[openApplicationMenuItem release];
	[menu release];
}


- (void)bringApplicationToFrontAction {
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
}


- (void)changeRatingAction:(id)sender {
	currentSong.rating = [sender tag];
	[self updateStatusMenuWithSong:currentSong];
	[tableView reloadData];
}


- (void)updateStatusMenuWithSong:(Song *)song {
    BOOL menuItemsEnabled;
    
    if (song) {

        trackMenuItem.title = [NSString stringWithFormat:@"%@ - %@", song.artist, song.track];
        
        Rating rating = song.rating;
        [ratingBadMenuItem setState:rating == RatingBad ? NSOnState : NSOffState];
        [ratingNoneMenuItem setState:rating == RatingNone ? NSOnState : NSOffState];
        [ratingGoodMenuItem setState:rating == RatingGood ? NSOnState : NSOffState];
        [ratingVeryGoodMenuItem setState:rating == RatingVeryGood ? NSOnState : NSOffState];
        
        menuItemsEnabled = YES;
        
    } else {
        
        trackMenuItem.title = @"Fetching Track...";
        
        menuItemsEnabled = NO;
        
    }
    
    [ratingBadMenuItem setEnabled:menuItemsEnabled];
    [ratingNoneMenuItem setEnabled:menuItemsEnabled];
    [ratingGoodMenuItem setEnabled:menuItemsEnabled];
    [ratingVeryGoodMenuItem setEnabled:menuItemsEnabled];
}


#pragma mark -
#pragma mark SongChangedDelegate


- (void)songChanged:(NSString *)song {
    
    if (!song) {
        self.currentSong = nil;
        [self updateStatusMenuWithSong:nil];
        return;
    }
    
	[GrowlApplicationBridge notifyWithTitle:@"Track Changed" description:song notificationName:@"Track Changed" iconData:nil priority:-1 isSticky:NO clickContext:@""];

	Song *newSong = [[Song alloc] init];
	
	NSRange hyphenRange = [song rangeOfString:@" - "];
	if (hyphenRange.location == NSNotFound) {
		newSong.artist = @"";
		newSong.track = song;
	} else {
		newSong.artist = [song substringToIndex:hyphenRange.location];
		newSong.track = [song substringFromIndex:(hyphenRange.location + hyphenRange.length)];
	}
	
	self.currentSong = newSong;
	[self updateStatusMenuWithSong:currentSong];

	// This check and adjustment accounts for potential editing whilst reloading
	//  and wouldn't be required if we were adding new items to the end of the list.
	if (tableView.editedRow != -1) {
		adjustEditedRowIndex = YES;
	}
	
	[songs insertObject:newSong atIndex:0];
	[tableView reloadData];
	
	[newSong release];
}


#pragma mark -
#pragma mark GrowlApplicationBridgeDelegate


- (void) growlNotificationWasClicked:(id)clickContext {
	[self bringApplicationToFrontAction];
}


#pragma mark -
#pragma mark NSTableViewDataSource


- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return songs.count;
}


- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	Song *song = [songs objectAtIndex:rowIndex];
	NSString *columnIdentifier = aTableColumn.identifier;
	
	if ([columnIdentifier isEqualToString:COLUMN_ARTIST]) {
		return song.artist;
	} else if ([columnIdentifier isEqualToString:COLUMN_TRACK]) {
		return song.track;
	} else if ([columnIdentifier isEqualToString:COLUMN_RATING]) {
		return [Song presentationStringFromRating:song.rating];
	}
	
	return nil;
}


- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	if (adjustEditedRowIndex) {
		rowIndex++;
		adjustEditedRowIndex = NO;
	}
	Song *song = [songs objectAtIndex:rowIndex];
	NSString *columnIdentifier = aTableColumn.identifier;
	
	if ([columnIdentifier isEqualToString:COLUMN_ARTIST]) {
		song.artist = anObject;
	} else if ([columnIdentifier isEqualToString:COLUMN_TRACK]) {
		song.track = anObject;
	} else if ([columnIdentifier isEqualToString:COLUMN_RATING]) {
		song.rating = [Song ratingFromPresentationString:anObject];
	}
	
	if (song == currentSong) {
		[self updateStatusMenuWithSong:currentSong];
	}
}


#pragma mark -
#pragma mark Memory Management


- (void)dealloc {
	self.notifier = nil;
	self.songs = nil;
	
	self.currentSong = nil;
	self.statusItem = nil;
	self.trackMenuItem = nil;
	self.ratingBadMenuItem = nil;
	self.ratingNoneMenuItem = nil;
	self.ratingGoodMenuItem = nil;
	self.ratingVeryGoodMenuItem = nil;
	
	[super dealloc];
}


@end
