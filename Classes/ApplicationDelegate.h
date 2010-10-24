//
// ApplicationDelegate.h
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

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>
#import "PollingSongChangeNotifier.h"
#import "SongChangedDelegate.h"


@interface ApplicationDelegate : NSObject <NSApplicationDelegate, SongChangedDelegate, NSTableViewDataSource, GrowlApplicationBridgeDelegate> {

}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTableView *tableView;

@end
