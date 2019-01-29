<p align="center"><img width="100" src="https://i.imgur.com/zwjfmrF.png" alt="lighttouch logo"><br>This Project is Currently in Stealth Mode.<br>please do not post a news story until v0.1 is released very shortly.<br>thank you.</p>

<p align="center">
  <a href="https://github.com/foundpatterns/lighttouch/issues"><img src="https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=" alt="Contributions Welcome"></a>
  <a href="https://discord.gg/b6MY7dG"><img src="https://img.shields.io/badge/chat-on%20discord-7289da.svg" alt="Chat"></a>
</p>

Lighttouch is a framework that makes complex application development simpler.  It does this through broad use of [component-oriented design](https://en.wikipedia.org/wiki/Component-based_software_engineering) intended to offer programmers a well-researched alternative to starting with a blank canvas - "put your code anywhere".

[Code organized](https://en.wikipedia.org/wiki/Structured_programming) this way is:
- easier to program
- unlimited in its reusability of implementations
- easier to extend with other developers' plugins
- possible to socially cross-pollenate diverse and complex applications
- possible to use as a base for [visual programming environments](https://en.wikipedia.org/wiki/Visual_programming_language) 

Without this, applications tend to:
- get walled into handling only a single use case
- grow, but at huge cost and pain while extending
- repetively [make messy mistakes](https://news.ycombinator.com/item?id=18443327), like [spaghetti code](http://wiki.c2.com/?SpaghettiCode) and [code duplication](http://wiki.c2.com/?DuplicatedCode)
- suffer too many layers of abstraction

Below you'll learn what is ECA-Rules, but to begin let's start with a simple diagram from the [Drupal Rules module](https://drupal.org/project/rules), a project which greatly influenced this one.

<img src="https://dev.acquia.com/sites/default/files/blog/rules_eca.png" alt="ECA-Rules diagram">

### Lighttouch Packages

Packages are Lighttouch's main unit of addon functionality. They leverage [event-driven](https://en.wikipedia.org/wiki/Event-driven_programming), [rule-based](https://en.wikipedia.org/wiki/Rule-based_system) programming.  This basically means that packages have actions, events, and rules.  Events are like [hooks](https://stackoverflow.com/questions/467557/what-is-meant-by-the-term-hook-in-programming) where additional logic can run.  Rules check a conditional statement of any complexity and trigger events.  When an event triggers, its actions run in weight order.  Actions are the individual mechanisms of additional functionality that have a distilled purpose and can run on any associated event.

80% of this functionality builds on top of [Luvent: A Simple Event Library for Lua](https://github.com/ejmr/Luvent).  You could probably get away with the summary below of Lighttouch's use of its API, but it's still worth checking out.  It has a great Readme.  The basic difference between what Luvent does and what Lighttouch does is that while writing a Lighttouch app, you put functionality into individual files, and Lighttouch sets everything up for you.

Events are very simple.  They get loaded into a global list by reading each package's `events.txt` file.  They can be disabled in a `disabled_events.txt` file.  (aside: Potential improvements include a simpler interface and ordering execution by weight.)

Rules are basically an `IF` statement with some metadata.  If the configured conditions, specified in the body of a rule as Lua code are `TRUE`, then the specified events will trigger and the objects specified in the input parameters will get passed to the attached actions.

Actions are individual, [lazy loaded functions](https://whatis.techtarget.com/definition/lazy-loading-dynamic-function-loading) that can run where they are needed.  You simply code what you want to do, and leave the parts about when it will run and in what order to the other logic connected through the yaml header.  Actions should not have conditions in them.

### Core Modules (including third-party)

Lighttouch also provides modules for content management, robust logging, syntax sugar, and more.  These core modules + loaders mentioned for packages + and init script make up [Lighttouch Base](https://github.com/foundpatterns/lighttouch-base), which has:
- Packaged ECA-Rules Loaders: described above
- Content Module: file-based, document-oriented databases (see Grav) with data models in YAML, similar to JSON Schema (content types), and validation
- Logging: automatically setup out of the box (set log level in `config.toml`, default is `INFO`)
- ...

### Packages

- Lighttouch Web Logging:  (for web automation) log every incoming request, outgoing response, outgoing request, and incoming response (server and client logging out of the box.. makes debugging web applications much easier) to log directory (log entries are content, btw)
- Lighttouch JSON Interface: REST API built on content module
- Lighttouch HTTP Interface: form-driven content entry mechanism, username:password protected (autogenerated at each initialization)
- Lighttouch Crypto Tools: setup a profile with cryptographic signing keys for yourself and friends to verify incoming responses and requests, and sign outgoing requests and responses + and more

### Installation

Lightouch has 3 dependencies:
* **[torchbear](https://github.com/foundpatterns/torchbear)** (an [application framework](https://stackoverflow.com/questions/4241919/what-is-meant-by-application-framework))
* **[git](https://git-scm.com)** (a [version control manager](https://en.wikipedia.org/wiki/Version_control))
* **[peru](https://github.com/buildinspace/peru)** (a [package manager](https://en.wikipedia.org/wiki/Package_manager))

Once these are installed, clone the repo with git, run `peru sync` to install its components, and run it with `torchbear`.  To update, use `git pull` and `peru reup`.

### Developing

To modify any functionality in Lighttouch, create a git repo outside of it for the component your are modifying, and add an override in `peru.yaml` so that it will use that source directory.  For example, to modify `lightouch-base`, clone it somewhere else, then run `peru override add lighttouch-base {{ path to lighttouch-base repo }}`.  Then, after making each change to the source, run `peru sync` to update your Lighttouch.
