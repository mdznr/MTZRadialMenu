# MTZRadialMenu

A radial menu control for iOS, like the one used in iOS 8 Messages.app

----

![Example](Example.gif)

----

This control is activated by long-pressing a button. A circle expands outwards from the button revealing different action items.

To create a radial menu, initalize one with a particular background visual effect (`UIVisualEffect`), configure the frame, delegate, and main button images, then add it to the view hierarchy.

```objc
self.cameraRadialMenu = [[MTZRadialMenu alloc] initWithBackgroundVisualEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
self.cameraRadialMenu.frame = left;
self.cameraRadialMenu.delegate = self;
[self.cameraRadialMenu setImage:[UIImage imageNamed:@"Camera"] forState:UIControlStateNormal];
[self.cameraRadialMenu setImage:[UIImage imageNamed:@"CameraHighlighted"] forState:UIControlStateSelected];
[self.view addSubview:self.cameraRadialMenu];
```

Menu items (`MTZRadialMenuItem`) are objects with information on the item's visual representation (some graphic) and the corresponding handler(s) associated with the different events. Create a menu item in one of three ways:

- with a common standard item (`MTZRadialMenuStandardItem`)
- with an icon (`UIImage` where `renderingMode` is treated as `UIImageRenderingModeAlwaysTemplate`)
- with a pair of images to use for the normal and highlighted states.

A menu item is also responsible for handling the two different events:

- highlight (the user dragged their finger over the item)
- selection (the user lifted their finger while the item was highlighted)

For convenience, it is possible to configure a menu item with just a selection handler since many items (e.g. "Cancel") will only require such. Handling both states is common for actions like "Record" which activate when highlighting the action.

Handlers are blocks (`MTZRadialMenuItemHighlightedHandler` or `MTZRadialMenuItemSelectedHandler`) that are called when the item has been highlighted (or unhighlighted) or selected. Appropriate action is then taken from there.

Menu items are then added to the instance of the radial menu and assigned to certain locations (see `setItem:forLocation:`).


### Usage Warnings

With `MTZRadialMenu`, you can create contextual radial menus presenting a few different actions. There are five locations for actions (center, top, right, bottom, and left). However, in most circumstances, only a couple of these locations should be used since the menu is likely on the edge of the display. The bottom location should rarely be used as this location is likely covered up by the user's finger when activating and using the menu. Be sure to use this in ways similar to Apple's uses to avoid confusion created by inconsistent use and behaviour of controls.

### License

MIT blah blah blah. Use this and have fun. I'd love to hear about how you're using this in your application. [Email me](matt@mdznr.com).