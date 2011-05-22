/*
 * Copyright 2011 Jason Rush and John Flanagan. All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "GroupViewController.h"
#import "EntryViewController.h"
#import "MobileKeePassAppDelegate.h"

@implementation GroupViewController

-(void)viewWillAppear:(BOOL)animated {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    
    //Reload the cell incase the title was changed by the entry view
    if (selectedIndexPath != nil) {
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    [super viewWillAppear:animated];
}

- (void)dealloc {
    [group release];
    [super dealloc];
}

- (KdbGroup*)group {
    return group;
}

- (void)setGroup:(KdbGroup*)newGroup {
    group = [newGroup retain];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (group == nil) {
        return 0;
    }
    
    return [group.groups count] + [group.entries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    MobileKeePassAppDelegate *appDelegate = (MobileKeePassAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // Configure the cell.
    int numChildren = [group.groups count];
    if (indexPath.row < numChildren) {
        KdbGroup *g = [group.groups objectAtIndex:indexPath.row];
        cell.textLabel.text = g.name;
        cell.imageView.image = [appDelegate loadImage:g.image];
    } else {
        KdbEntry *e = [group.entries objectAtIndex:(indexPath.row - numChildren)];
        cell.textLabel.text = e.title;
        cell.imageView.image = [appDelegate loadImage:e.image];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int numChildren = [group.groups count];
    if (indexPath.row < numChildren) {
        KdbGroup *g = [group.groups objectAtIndex:indexPath.row];
        
        GroupViewController *groupViewController = [[GroupViewController alloc] initWithStyle:UITableViewStylePlain];
        groupViewController.group = g;
        groupViewController.title = g.name;
        [self.navigationController pushViewController:groupViewController animated:YES];
        [groupViewController release];
    } else {
        KdbEntry *e = [group.entries objectAtIndex:(indexPath.row - numChildren)];
        
        EntryViewController *entryViewController = [[EntryViewController alloc] initWithStyle:UITableViewStyleGrouped];
        entryViewController.entry = e;
        entryViewController.title = e.title;
        [self.navigationController pushViewController:entryViewController animated:YES];
        [entryViewController release];
    }
}

@end
