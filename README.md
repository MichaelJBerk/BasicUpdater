# BasicUpdater

Prompt users to download updates for you Mac app using GitHub Releases

Note: This package only opens a download link to the update - the user will still have to install the update themselves.  

**Supports macOS ≥ 10.15**

![](Sources/BasicUpdater/BasicUpdater.docc/BasicUpdateWindow.png)


## Features

- Prompt users to download new updates when they release
- Allow the user to skip specific versions, or turn on/off automatic updates 
- Define the semantics for what release constitutes a "new version", and which asset to use


## Why not use Sparkle?
Sparkle is a great way to provide automatically download and install app updates, but can sometimes be a bit unweildy for simpler projects. Since it installs the app update (instead of just downloading the update), it requires more setup (such as generating a signing key for updates). Additionally, it requires the user to create and appcast to publish updates to users, which can be difficult for certain workflows. In contrast, BasicUpdater requires less extra setup, and uses GitHub Release as a simple mechanism to provide new releases without the need to host and update an appcast. 

If you're dealing with a large-scale app, I would still reccommend Sparkle as the better choice - it offers a better experience by automatically installing the app, and has more customization options. BasicUpdater is better suited to smaller apps, projects that already use GitHub Releases, or (such as my case when building this project), providing beta updates outside of TestFlight. 

## Acknowledgements
I'd like to thank Junyu Kuang, the developer of Spring for Twitter/Mona for Mastodon, which (I believe) uses a similar mechanism for delivering beta updates.