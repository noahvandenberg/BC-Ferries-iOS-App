# BC Ferries iOS app

A personal SwiftUI app for viewing BC ferry routes, sailing capacity and sailing details, with favorite routes and Live Activity/widget source. Built for the author's Opa.

## Source layout

- `BC Ferries/`: application entry point, models, views and services.
- `BC FerriesWidgetExtension/`: WidgetKit extension source.
- `Shared/`: shared activity attributes and capacity view.

`FerryAPIClient` requests the capacity endpoint at `https://www.bcferriesapi.ca/v2/capacity`. Live service availability is not verified by this repository cleanup.

## Build status

This repository contains Swift source and assets, but no tracked Xcode project, workspace or Swift package manifest. A fresh clone cannot yet be built with a documented Xcode scheme. Recover the original project configuration or create and configure the app and widget targets before building; target membership, signing and entitlements need to be checked in Xcode.

The ignore rules allow a future shared Xcode project to be committed while excluding per-user IDE state and derived build output. Keep this app as its own project; the other menu bar utilities in this account serve different purposes.
