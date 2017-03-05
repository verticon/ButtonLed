# Button Led
### nRF51 Demo - An iOS application interacting with a Button and an LED on the Nordic PCA10028 Development Kit

The Nordic application (see .../Nordic/ble_app_button_led) provides a service with two characteristics: one for accessing Button 4, the other for accessing LED 2.  

The iOS application presents a button; it responds to touches by toggling the state of the LED. The application also enables notifications for the Button characteristic; it responds to notifications (button presses) by toggling the LED. The UI button and the hardware button produce the same result. The application makes use of the [MoBetterBluetooth](https://github.com/verticon/MoBetterBluetooth.git) framework  

Notes:

* The ButtonLed application's xcode project includes subprojects which are in the submodules of the application's GitHub repository. Therefore, clone the application's repository using the --recursive option so as to obtain the submodules. Downloading the ZIP archive will not work; it does not capture the submodules.

* Copy Nordic/ble_app_button_led to (Nordic SDK Location)/examples/ble_peripheral then build and flash as normal (I tried using symbolic links but they [do not work](http://unix.stackexchange.com/questions/158126/cd-and-ls-behave-differently-when-inside-a-softlink-to-a-dir)). I am using [SDK 10.0.0](https://developer.nordicsemi.com/nRF5_SDK/nRF51_SDK_v10.x.x/) and [S110 SD v8](http://www.nordicsemi.com/eng/Products/ANT/nRF51422)
