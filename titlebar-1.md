Type Property
automatic
The default window style.
macOS 11.0+
visionOS 1.0+
static var automatic: DefaultWindowStyle { get }
Available when Self is DefaultWindowStyle.
See Also
Getting built-in window styles
static var hiddenTitleBar: HiddenTitleBarWindowStyle
A window style which hides both the window’s title and the backing of the titlebar area, allowing more of the window’s content to show.
static var plain: PlainWindowStyle
The plain window style.
static var titleBar: TitleBarWindowStyle
A window style which displays the title bar section of the window.
static var volumetric: VolumetricWindowStyle
A window style that creates a 3D volumetric window.


Type Property
hiddenTitleBar
A window style which hides both the window’s title and the backing of the titlebar area, allowing more of the window’s content to show.
macOS 11.0+
static var hiddenTitleBar: HiddenTitleBarWindowStyle { get }
Available when Self is HiddenTitleBarWindowStyle.
See Also
Getting built-in window styles
static var automatic: DefaultWindowStyle
The default window style.
static var plain: PlainWindowStyle
The plain window style.
static var titleBar: TitleBarWindowStyle
A window style which displays the title bar section of the window.
static var volumetric: VolumetricWindowStyle
A window style that creates a 3D volumetric window.


Type Property
plain
The plain window style.
macOS 15.0+
visionOS 1.0+
static var plain: PlainWindowStyle { get }
Available when Self is PlainWindowStyle.
Discussion
Unlike automatic, a plain window does not receive a glass background in visionOS or window chrome in macOS. Use this style if you want more control over how these elements are used in your window.

See Also
Getting built-in window styles
static var automatic: DefaultWindowStyle
The default window style.
static var hiddenTitleBar: HiddenTitleBarWindowStyle
A window style which hides both the window’s title and the backing of the titlebar area, allowing more of the window’s content to show.
static var titleBar: TitleBarWindowStyle
A window style which displays the title bar section of the window.
static var volumetric: VolumetricWindowStyle
A window style that creates a 3D volumetric window.


Type Property
titleBar
A window style which displays the title bar section of the window.
macOS 11.0+
static var titleBar: TitleBarWindowStyle { get }
Available when Self is TitleBarWindowStyle.
See Also
Getting built-in window styles
static var automatic: DefaultWindowStyle
The default window style.
static var hiddenTitleBar: HiddenTitleBarWindowStyle
A window style which hides both the window’s title and the backing of the titlebar area, allowing more of the window’s content to show.
static var plain: PlainWindowStyle
The plain window style.
static var volumetric: VolumetricWindowStyle
A window style that creates a 3D volumetric window.


Structure
DefaultWindowStyle
The default window style.
macOS 11.0+
visionOS 1.0+
struct DefaultWindowStyle
Overview
You can also use automatic to construct this style.

Topics
Creating the window style
init()
Relationships
Conforms To
WindowStyle
See Also
Supporting types
struct HiddenTitleBarWindowStyle
A window style which hides both the window’s title and the backing of the titlebar area, allowing more of the window’s content to show.
struct PlainWindowStyle
The plain window style.
struct TitleBarWindowStyle
A window style which displays the title bar section of the window.
struct VolumetricWindowStyle
A window style that creates a 3D volumetric window.


Structure
DefaultWindowStyle
The default window style.
macOS 11.0+
visionOS 1.0+
struct DefaultWindowStyle
Overview
You can also use automatic to construct this style.

Topics
Creating the window style
init()
Relationships
Conforms To
WindowStyle
See Also
Supporting types
struct HiddenTitleBarWindowStyle
A window style which hides both the window’s title and the backing of the titlebar area, allowing more of the window’s content to show.
struct PlainWindowStyle
The plain window style.
struct TitleBarWindowStyle
A window style which displays the title bar section of the window.
struct VolumetricWindowStyle
A window style that creates a 3D volumetric window.


Structure
HiddenTitleBarWindowStyle
A window style which hides both the window’s title and the backing of the titlebar area, allowing more of the window’s content to show.
macOS 11.0+
struct HiddenTitleBarWindowStyle
Overview
You can also use hiddenTitleBar to construct this style.

Topics
Creating the window style
init()
Creates a hidden title bar window style.
Relationships
Conforms To
WindowStyle
See Also
Supporting types
struct DefaultWindowStyle
The default window style.
struct PlainWindowStyle
The plain window style.
struct TitleBarWindowStyle
A window style which displays the title bar section of the window.
struct VolumetricWindowStyle
A window style that creates a 3D volumetric window.


Structure
PlainWindowStyle
The plain window style.
macOS 15.0+
visionOS 1.0+
struct PlainWindowStyle
Overview
You can also use plain to construct this style.

Topics
Creating the window style
init()
Relationships
Conforms To
WindowStyle
See Also
Supporting types
struct DefaultWindowStyle
The default window style.
struct HiddenTitleBarWindowStyle
A window style which hides both the window’s title and the backing of the titlebar area, allowing more of the window’s content to show.
struct TitleBarWindowStyle
A window style which displays the title bar section of the window.
struct VolumetricWindowStyle
A window style that creates a 3D volumetric window.


Structure
TitleBarWindowStyle
A window style which displays the title bar section of the window.
macOS 11.0+
struct TitleBarWindowStyle
Overview
You can also use titleBar to construct this style.

Topics
Creating the window style
init()
Creates a title bar window style.
Relationships
Conforms To
WindowStyle
See Also
Supporting types
struct DefaultWindowStyle
The default window style.
struct HiddenTitleBarWindowStyle
A window style which hides both the window’s title and the backing of the titlebar area, allowing more of the window’s content to show.
struct PlainWindowStyle
The plain window style.
struct VolumetricWindowStyle
A window style that creates a 3D volumetric window.
Current page is TitleBarWindowStyle
