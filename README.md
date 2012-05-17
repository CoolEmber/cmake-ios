cmake-ios
=========

A platform file and toolchain files for cmake for iOS target.

**Acknowledgment**: This is based on the work [ios-cmake][link-google-code] on Google Code.

Warning
-------

This is work in progress and not tested properly.

I'm working with CMake 2.8.8 for Mac OS X with Xcode 4.3.2. There's no gurantee that this will work with older version of CMake nor on other previous version of Xcode, though I think it should work with Xcode 4.x.

Install
-------

* Copy `Platform/iOS.cmake` to Platform folder of CMake. It would be `<CMake App Folder>/Contents/share/cmake-2.8/Modules/Platform`.
* Copy `Toolchain/iOS-*.cmake` to project directory or somewhere convenient if you like.

Use
---

* `cmake -DCMAKE_TOOLCHAIN_FILE=<Toolchain Dir>/iOS-Device.cmake <Your Project Source Dir>` to setup for iOS device target.
* Use `iOS-Simulator.cmake` to target simulator.

[link-google-code]: http://code.google.com/p/ios-cmake/

