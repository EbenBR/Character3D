KinectCharacter3D
=================

A voxel-style 3D character that mirrors your body movements
in real time using a Microsoft Kinect v1 sensor. Built with
Processing and the Kinect4WinSDK library.


About
-----

This project was originally developed in 2016 as a personal,
recreational project for use at a family birthday party.

The code has seen virtually no updates since then and is no
longer actively maintained. No support, bug fixes, compatibility
updates, or other maintenance are promised.

The project is published as-is for anyone who may find it useful
or interesting to study, experiment with, or continue developing.


Requirements
------------

  - Windows 7, 8, 8.1, or 10 (64-bit)
  - Processing 4.5.5
    https://processing.org/download

    Note: This project was tested with Processing 4.5.5.
    Later versions may require changes and are not currently
    supported by this project.

  - Microsoft Kinect for Windows SDK v1.8
    https://www.microsoft.com/en-us/download/details.aspx?id=40278

  - Microsoft Visual C++ 2012 Redistributable (x64)

  - A compatible Microsoft Kinect v1 sensor connected via USB


Third-Party Software
--------------------

This project depends on third-party software, including the
Microsoft Kinect for Windows SDK and the Kinect4WinSDK library.

Third-party software, libraries, SDKs, drivers, runtimes, and
other materials are NOT covered by this project's MIT License.
They remain subject to their respective copyright, license,
and distribution terms.

The Microsoft Kinect for Windows SDK and other Microsoft software
are provided by Microsoft under Microsoft's applicable license
terms. This project does not grant any additional rights to
Microsoft software.

The Kinect4WinSDK library is distributed under the GNU Lesser
General Public License, version 2.1 (LGPL-2.1), as applicable to
that library. Its source and license information can be found at:

https://github.com/chungbwc/Kinect4WinSDK

Before redistributing this project together with any third-party
binaries or libraries, verify that their respective license terms
permit such redistribution and that all required notices and
license texts are included.


Kinect4WinSDK Installation
--------------------------

The Kinect4WinSDK library must be installed in the Processing
libraries folder.

The expected path is:

  Documents/Processing/libraries/Kinect4WinSDK/

That folder should contain the required library files, such as:

  library/Kinect4WinSDK.jar
  library/Kinect4WinSDK32.dll
  library/Kinect4WinSDK64.dll

These files may be subject to third-party license terms and are
not relicensed under this project's MIT License.


Installation
------------

  1. Install Processing 4.5.5.
  2. Install the Microsoft Kinect for Windows SDK v1.8 separately,
     subject to Microsoft's applicable license terms.
  3. Install the required Microsoft Visual C++ runtime separately,
     subject to its applicable license terms.
  4. Download or clone this repository.
  5. Install the Kinect4WinSDK library as described above.
  6. Open KinectSteve03.pde in the Processing IDE.
  7. Connect a compatible Kinect sensor via USB.
  8. Click Run.


Controls
--------

  1 - Toggle character rendering
  2 - Toggle skeleton overlay
  3 - Toggle Kinect RGB camera feed
  4 - Toggle Kinect depth map
  5 - Toggle Kinect user mask


Compatibility
-------------

This project has only been tested on Windows.

It depends on the Microsoft Kinect for Windows SDK and
Windows-specific native components. Linux and macOS are not
supported.

Compatibility with current versions of Windows, Processing,
Kinect drivers, or other dependencies is not guaranteed.


Privacy and Data
----------------

The application may process camera, depth, user-mask, and
skeletal data from people within the Kinect sensor's field of
view.

If you use this application to capture or process information
about other people, you are responsible for obtaining any
permissions, notices, or consents required by applicable privacy
and data-protection laws.

This project does not provide a hosted data-processing service
and does not make any representation about the privacy
requirements applicable to a particular use case.


Safety
------

This project is provided for experimental and recreational use.

Do not use it in safety-critical applications or in environments
where a software, hardware, sensor, or tracking failure could
cause injury or property damage.

When using the application around other people, provide adequate
physical space, avoid trip hazards such as cables, and use
appropriate supervision.

The application has not been designed, tested, or certified for
medical, industrial, safety-critical, or other high-risk uses.


Trademarks
----------

Microsoft, Kinect, Windows, and Xbox are trademarks of Microsoft
Corporation and/or its affiliates.

This project is an independent, unofficial project and is not
affiliated with, sponsored by, or endorsed by Microsoft.

The use of product names in this documentation is solely intended
to identify the software, hardware, and platforms required or
compatible with the project.


License for Original Code
-------------------------

Unless otherwise stated, the original source code authored for
this project is licensed under the MIT License.

Copyright (c) 2016

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.


Disclaimer
----------

This project is provided solely for informational, educational,
experimental, and recreational purposes.

The author makes no representation or warranty that the project
will work correctly, safely, or reliably in any particular
environment or with any particular hardware or software version.

The author is not responsible for problems arising from the use,
modification, redistribution, or further development of this
project, to the extent permitted by applicable law.

Users are responsible for determining whether the project and
its dependencies are suitable and legally permitted for their
intended use.


No Affiliation or Endorsement
-----------------------------

This project is an independent personal project.

It is not affiliated with, sponsored by, maintained by, or
endorsed by Microsoft, Mojang Studios, Processing, or the
authors/maintainers of third-party libraries used by the project.
