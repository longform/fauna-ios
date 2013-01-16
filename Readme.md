## Fauna SDK for iOS

Fauna SDK for iOS + Examples

### Requirements

* git
* Xcode 4.5.2
* iOS 4.3

### API Coverage

The iOS SDK provides client classes to consume most of the features available in the API under [Client Key or User Token](https://fauna.org/API).

* [User Signup, Tokens and Passwords](https://fauna.org/API#resources-users)
* [Timelines](https://fauna.org/API#timelines)
* [Instances](https://fauna.org/API#resources-instances)
* [Commands](https://fauna.org/API#access_model-commands)

### Content

The code is organized in two projects under a single XCode workspace:

* Fauna: Fauna API Client.
* FaunaChat: A simple Example Chat-like application that uses Fauna Platform and the Fauna Chat SDK.

### Running the Example Project

1. Having [git](http://git-scm.com/) and Xcode installed:

    git clone git@github.com:fauna/fauna-ios.git
    ( cd fauna-ios ; open Fauna-iOS.xcworkspace )

3. Select FaunaChat scheme in Xcode.
2. Run the *FaunaChat* project.


### Using Fauna SDK in your Xcode Project

1. Clone the SDK using `git clone`.
2. Close all the Xcode projects related to the Fauna SDK (workspace, Fauna, FaunaChat, etc).
2. Open your Xcode project and using Finder, go to the directory fauna-ios/Fauna and Drag and Drop the file `Fauna.xcodeproj` into your Xcode project, right under the root of your project.
    Your Xcode project structure should now look like this:

    ```
      yourFaunaProject
        -> Fauna.xcodeproj
          -> Fauna
            -> Fauna.h
        -> yourFaunaProject
          -> yourFaunaProjectAppDelegate.h
        -> Frameworks
        -> Products
    ```
    You should see a tree under Fauna.xcodeproj. If you don't see it then it's probably because Fauna.xcodeproj was already open in another Xcode instance. Go back to step 2.

3. Select your Project in the tree, select a Target(mostly with the same name as your project), navigate to the `Build Phases` tab and expand `Target Dependencies`. Click on `+` and Select `Fauna`.

4. You are ready to use Fauna via `#import <Fauna/Fauna.h>`

### Initializing the API Client

The best place to initialize the Fauna API Client is in your AppDelegate, example:

```
Fauna.client = [[FaunaClient alloc] initWithClientKeyString:@"<your-client-key>"];
```

Check `FaunaExampleAppDelegate.m` in the FaunaChat project to see a more detailed snippet.

## LICENSE

Copyright 2013 [Fauna, Inc.](https://fauna.org/)

Licensed under the Mozilla Public License, Version 2.0 (the "License"); you may
not use this software except in compliance with the License. You may obtain a
copy of the License at

[http://mozilla.org/MPL/2.0/](http://mozilla.org/MPL/2.0/)

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.