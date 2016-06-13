SampleCodeStalker is a small application that fetches information about Apple's sample code from the web and presents it nicely. It started as a small weekend project and is written completely in Swift.

![](https://cloud.githubusercontent.com/assets/873717/15938659/688cca56-2e74-11e6-8160-e7b3100a2ca9.png)

I had (and possibly still have) many ideas about which features to add but work caught up with me and I have hardly the time to implement most of them.

Sadly it is not coded all too well because I didn't have time to refactor and generalize most of the implementation but it works for now and I thought it might be helpful for some with WWDC around the corner.

**Note:** If the app crashes on start it is because I have not written any migration code for Core Data yet. Just delete the `~/Documents/SampleCodeStalker/` directory and run the app again for now.

This project uses some code from the most excellent [Core Data book by Florian Kugler and Daniel Eggert](https://www.objc.io/books/core-data/). If you are working with Core Data anywhere, get it!

## Features

- [x] Nicely present sample code projects
- [x] Check for new and updated sample code

#### Features I would have loved to implement but don't have the time to do right now

- [ ] Have a nice icon...
- [ ] Separate display of projects for each platform with a segmented control
- [ ] Display details for each project and make them searchable
- [ ] Download Sample code to local directory and init a git repo for each
- [ ] Upon downloading a newer version, if the repo now has changes commit them

## Requirements

- Mac OS X 10.11+
- Xcode 7.2+

## Contributing

Pull requests and suggestions for new features are welcome.
