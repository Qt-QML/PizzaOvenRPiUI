# PizzaOvenRPiUI
A UI that uses the Raspberry Pi and qt to control the pizza oven

### Preliminary things to do
You may need to deviate a little when set up the environment.  This mostly involves installing some extra things prior to following the instructions in the above link.
- sudo apt-get install lib32z1
- sudo apt-get install lib32ncurses5
- sudo apt-get install binutils-multiarch binutils-multiarch-dev multiarch-support 
- sudo apt-get install lib32stdc++6
- sudo apt-get install lib32z1-dev
- sudo apt-get install build-essential

### Creating the cross-build environment
In order to cross-build for the Pi, you need to install a cross toolchain, among other things.  Follow [the instructions here](https://wiki.qt.io/RaspberryPi2EGLFS) for creating the cross environment and doing the initial build.

### Compiling additional modules
Compile the following modules using the [instructions from the link](https://wiki.qt.io/RaspberryPi2EGLFS):
-	qtimageformats
-	qtsvg
-	qtscript
-	qtxmlpatterns
-	qtdeclarative
-	qtsensors
-	qt3d
-	qtgraphicaleffects
-	qtlocation
-	qtmultimedia
-	qtquick1
-	qtquickcontrols
-	qtquickcontrols2
-	qtwebsockets

