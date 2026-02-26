name: arduino_programmer
description: A new Flutter project to program Arduino via BLE.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  # The motor for our Bluetooth functions
  flutter_blue_plus: ^1.31.1 
  # Helps with permissions on iPhone
  permission_handler: ^11.0.0 

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
