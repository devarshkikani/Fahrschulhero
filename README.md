# Introduction 
This project is to take the Figma UI/Kit and convert to Flutter mobile application for Andriod and IOS.

# Getting Started
##Project Overview and Processes
- Sprints start on Monday and end on Sunday
- Sprints are numbers according to the week number of the year
- Weekly Sprint meetings are on scheduled from Sunday 6PM PST - Monday 6:30AM IST [Link](https://teams.microsoft.com/l/meetup-join/19%3a7e134164017f47b482890885c181d5a1%40thread.tacv2/1650672581122?context=%7b%22Tid%22%3a%226aa774c9-f436-4191-b76a-00cf5ca8f680%22%2c%22Oid%22%3a%2280dc821c-51bb-461d-a068-79864eb0c5b5%22%7d)

##Software dependencies
- [Figma UI Kit](https://www.figma.com/file/uAjnWEWmFXOIeVuyZ3bc7S/DRIVE?node-id=0%3A1)
- For all API and Server level dependencies contact - Tomasz Gorka tomasz.gorka@paperclipventures.com

#Success Criteria
-	After project completion there should be a fully functional Android and IOS application ready to be available on the app stores. 
-	The application should have almost identical look and feel from the Figma UI Kit.  
-	API integration with backend systems will capture and serve needed data fields and render images as required.   
-	We are able to validate and test Features Below

# Build and Test
## Authentication
 - used [Amplify Authentication Components](https://ui.docs.amplify.aws/?platform=flutter)
 - use AWS COGNITO USER_POOLS
## Booking
## Membership
 - used `CognitoUserInterface.username` as `Membership.owner` to get the active membership
## Payment
## Agency
## VehicleGroup
## Vehicle
## Booking reservation
## SWAP
 - reserve new booking
 - adjust cancel of current booking if necessary
## Dealer Portal (Web App)

#Latest releases

#API references

# Development

## Requirements
    1. Docker
    2. [VS Code](https://github.com/Microsoft/vscode)
    3. VS Code dev container extension
    4. Git

## Contribute
- Clone project from git repository
- Open in VS Code as dev container
- Develop (terminal commands will open in docker environment)

# Build and Test
TODO: Describe and show how to build your code and run the tests in docker environment.

## Install dependencies
TODO: Describe how to install dependencies.

## Compile
### iOS
TODO: Describe and show how to compile your code for iOS.

### Android
TODO: Describe and show how to compile your code for Android.

### Web
TODO: Describe and show how to compile your code for Web.

## Run tests
TODO: Describe and show how to run tests.

## Run coverage
TODO: Describe and show how to run code coverage.

## Run linter
TODO: Describe and show how to run linter.

# API
TODO: Describe your API and show how to use it (with links to another md files if needed).

## Docker
- location: *./.devcontainer/*

Docker environment is used for the development purpose. It is used to build the code and run the tests.
The used *Dockerfile* can be updated by custom needs.

*devcontainer.json* file is used to configure the environment and the used VS Code extensions.

Information about usage:
- [Develop Flutter in dev container](https://dev.to/matsp/develop-flutter-in-a-vs-code-devcontainer-350g)
- [Flutter docker container](https://github.com/matsp/docker-flutter)
- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)
- [Visual Studio Code](https://github.com/Microsoft/vscode)

## Server connection
Server connection is done through a GraphQL API over http and websockets.

On the server side there is AWS Amplify used.
The interaction can be established through [Amplify Flutter library](https://docs.amplify.aws/lib/q/platform/flutter/).

## Models (/lib/models)
- location: *./lib/models/*

Data model for the project (e.g. Agency, Membership, Booking, etc.).

The model will be used with connection to AWS Amplify server API (GraphQL) using [DataStore](https://docs.amplify.aws/lib/datastore/getting-started/q/platform/flutter/).

**IMPORTANT:** *Do not update or override the model it will be generated automatically.*

____________________________________________________________________________________
Daniel's notes:
adb -s emulator-5556 reverse tcp:44356 tcp:44356
adb -s YKCNW19C23008635 reverse tcp:44356 tcp:44356
adb reverse tcp:44356 tcp:44356

adb devices
adb reverse --list
fluter build apk
flutter build apk -t lib/main_production.dart --release
____________________________________________________________________________________


