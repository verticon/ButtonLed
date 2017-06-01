# Button Led
### nRF51 Demo - An iOS application interacting with a Button and an LED on the Nordic PCA10028 Development Kit

The Nordic [application](https://github.com/verticon/Nordic/tree/master/nRF51_SDK_10.0.0_dc26b5e/projects/peripherals/button_led) provides a service with two characteristics: one for accessing Button 4, the other for accessing LED 2.  

The iOS application presents a button; it responds to touches by toggling the state of the LED. The application also enables notifications for the Button characteristic; it responds to notifications (button presses) by toggling the LED. The UI button and the hardware button produce the same result. The application makes use of the [MoBetterBluetooth](https://github.com/verticon/MoBetterBluetooth.git) framework  

Notes:

* The ButtonLed application's xcode project includes subprojects which are in the submodules of the application's GitHub repository. Therefore, clone the application's repository using the --recursive option so as to obtain the submodules. Downloading the ZIP archive will not work; it does not capture the submodules.
