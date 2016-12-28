# Random Guys

## Overview

The purpose of the project is a test to be a Lydia iOS developer.

It's a basic app that manage:
    
    - Retreive one User from randomuser.me
    - List downloaded users
    - Show user's details
    - Delete a downloaded user

This app is using CoreData in order to save as many users the device can.

I'm using those following non-Apple provided frameworks: [Masonry](https://github.com/SnapKit/Masonry), [SDWebImage](https://github.com/rs/SDWebImage)

The project took me about 5 hours and a half.

## Setup

You should use ruby 2.3.1.

```
bundle install
bundle exec pod install
open RandomGuys.xcworkspace
```

## Random users fetch

Random users are fetched at each app launch and by hitting the `+` button.

## Optimizations that should come next

- Localization via Google Spreadsheet
- Certainly a better UI
