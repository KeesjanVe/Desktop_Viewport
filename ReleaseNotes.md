Version 2.0.0.2
Changes:
- Removed command line parameters '-R' and '-B' due to incorrect results and a 'black' VCL screen.
- Default viewport Width = 140 pixels and Height = 250 pixels
- Compensate for a main monitor on the right hand side

Version 2.0.0.1
Changes:
- Removed command line check for negative values for Top, Left, Right and Bottom.
  The check did not allow the command line use for displaying the viewport on non-primary monitors on the left or top.

Version 2.0.0.0
Changes:
- Added command line parameters (-T x -L x -R x -B x -W x -H x)

Version 1.0.0.0
Changes:
- border-less form
- form coordinates are shown and can be set
The coordinates are relative to the client portion (viewport) of the form.
E.g. when setting the top to '0', the 'viewport' will start at the top of the desktop.
Borders are 2 pixels thick.
- left click (and keeping pressed) on the form initiates moving the form
- the borders allow sizing of the form (hoover around the border and the mouse cursor will change into an double sided arrow)
- minimal form size (250 pixels in height and 145 pixels in width) 
- added 'close' button at the left bottom of the form