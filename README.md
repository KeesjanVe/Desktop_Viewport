# Desktop_Viewport
Create a view-port (form) that can be shared with MS Teams

Install VCL (https://www.videolan.org/) Start this (DesktopViewport.exe) application, position and size the form to your needs. 
Hit the 'Create view-port' button, the form will become transparent and a new (VCL) window will open. The transparent form can not 
be sized or moved any more!

The underlying part of the transparent form will be shown in the new VCL form/window that can be shared with e.g. MS Teams. 
Select 'Window sharing' in Teams and not 'Desktop sharing' and share the new VCL window. If insisting on sharing the desktop,
maximize the VCL window and share the desktop covered with the VCL window. When dragging other forms/windows underneath the 'view-port' 
only the part covered by the view-port is shared/visible for the attendees.

Command line parameters:
For defining the view-port location and size command line parameters can be used.
The following command line parameters are available:
Top: 	-T x
Left: 	-L x
Right:	-R x
Bottom:	-B x
Width:	-W x
Height:	-H x

Width and Height have priority over Right and bottom.
Default width = 146 pixels, Width/Right-Left can not be smaller than 146 pixels
Default Height = 261 pixels, Height/Bottom-Top can not be smaller than 261 pixels
The parameters and their calculation may not be entirely foolproof!

Example: DesktopViewport.exe -T 0 -L 0 -W 1024 -H 768

No licence what so ever! Application and Delphi 5 source code included (yes I am old, old, old school!).
