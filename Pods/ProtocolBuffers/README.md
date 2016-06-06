Protocol Buffers for Objective-C
================================

[![Build Status](https://travis-ci.org/alexeyxo/protobuf-objc.svg?branch=master)](https://travis-ci.org/alexeyxo/protobuf-objc) [![Version](http://img.shields.io/cocoapods/v/ProtocolBuffers.svg)](http://cocoapods.org/?q=ProtocolBuffers) [![Platform](http://img.shields.io/cocoapods/p/ProtocolBuffers.svg)](http://cocoapods.org/?q=ProtocolBuffers)

An implementation of Protocol Buffers in Objective C.

Protocol Buffers are a way of encoding structured data in an efficient yet extensible format. This project is based on an implementation of Protocol Buffers from Google. See the [Google protobuf project](https://developers.google.com/protocol-buffers/docs/overview) for more information.

This fork contains only ARC version of library.

How To Install Protobuf
-----------------------

### Building the Objective-C Protobuf compiler

1. Check if you have Homebrew
`brew -v`
2. If you don't already have Homebrew, then install it
`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`
3. Install the main Protobuf compiler and required tools
`brew install automake`
`brew install libtool`
`brew install protobuf`
4. (optional) Create a symlink to your Protobuf compiler.
`ln -s /usr/local/Cellar/protobuf/2.6.1/bin/protoc /usr/local/bin`
5. Clone this repository.
`git clone https://github.com/alexeyxo/protobuf-objc.git`
6. Build it!
`./scripts/build.sh`

### Adding to your project as a sub project

...

7. Add `/src/runtime/ProtocolBuffers.xcodeproj` in your project.

### Adding to your project as a CocoaPod

...

7. `cd <your .xcodeproj directory>`

8. `echo -e "platform :ios , 6.0 \nlink_with '<YourAppTarget>', '<YourAppTarget_Test>' \npod 'ProtocolBuffers'" > Podfile`

9. `pod install`

Compile ".proto" files.
-----------------------

`protoc --plugin=/usr/local/bin/protoc-gen-objc person.proto --objc_out="./"`


Compilation Options
-------------------

The protobuf-objc compiler recognizes several obj-c specific compilation options.  These
are added to the beginning of your .proto file:

        package dataexchange;

        import "objectivec-descriptor.proto";
        option (google.protobuf.objectivec_file_options).package = "DataExchange";
        option (google.protobuf.objectivec_file_options).class_prefix = "DE";
        option (google.protobuf.objectivec_file_options).relax_camel_case = true;
        .
        .
        .

### Options

### `package`

Sets the Objective-C package where classes generated from this .proto
will be placed.  This is typically used since Objective-C libraries output
all their headers into a single directory.  i.e.  Foundation/*
AddressBook/*   UIKit/*   etc. etc.


### `class_prefix`

The string to be prefixed in front of all classes in order to make them
'cocoa-y'.  i.e. 'NS/AB/CF/PB' for the
NextStep/AddressBook/CoreFoundation/ProtocolBuffer libraries respectively.
This will commonly be the capitalized letters from the above defined
package directory.


### `relax_camel_case`

Values: true/false.

Relaxes the strict camel case that is the default.

When this option is set, only the first letter after an underscore is
forced to uppercase.  I added this feature so that the generated obj-c code
could more closely match our own in-house camel casing style.

Example:

        enum Gender {
          GUnknown  = 0;
          GFemale   = 1;
          GMale     = 2;
          GOther    = 3;
        }

        enum PlatformType {
          PTUnknown   = 0;
          PTiOS       = 1;
          PTAndroid   = 2;
          PTWeb       = 3;
        }

Normal output:

        typedef NS_ENUM(SInt32, HMGender) {
          HMGenderGunknown = 0,
          HMGenderGfemale = 1,
          HMGenderGmale = 2,
          HMGenderGother = 3,
        };

        typedef NS_ENUM(SInt32, HMPlatformType) {
          HMPlatformTypePtunknown = 0,
          HMPlatformTypePtiOs = 1,
          HMPlatformTypePtandroid = 2,
          HMPlatformTypePtweb = 3,
        };

Relaxed camel case:

        typedef NS_ENUM(SInt32, HMGender) {
          HMGenderGUnknown = 0,
          HMGenderGFemale = 1,
          HMGenderGMale = 2,
          HMGenderGOther = 3,
        };

        typedef NS_ENUM(SInt32, HMPlatformType) {
          HMPlatformTypePTUnknown = 0,
          HMPlatformTypePTiOS = 1,
          HMPlatformTypePTAndroid = 2,
          HMPlatformTypePTWeb = 3,
        };


Protobuf Examples
-----------------

### Web

Server-side requires Ruby(2.0+) and Sinatra gem.

To start `ruby sinatra.rb` in /Example/Web

if you need to recompile ruby proto models please install ruby_protobuf gem and make 'rprotoc person.proto'

### iOS Example

/Example/iOS/Proto.xcodeproj

Project contains protobuf example and small json comparison.

### Credits

Maintainer - Alexey Khokhlov

Booyah Inc. - Jon Parise

Google Protocol Buffers, Objective C - Cyrus Najmabadi - Sergey Martynov

Google Protocol Buffers - Kenton Varda, Sanjay Ghemawat, Jeff Dean, and others
