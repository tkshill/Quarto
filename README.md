![banner](https://github.com/tkshill/Quarto/blob/main/.github/banner-quarto.png)

![Help Wanted](https://img.shields.io/badge/%20-help--wanted-%23159818)
![MIT License](https://img.shields.io/github/license/tkshill/Quarto)
[![Netlify Status](https://api.netlify.com/api/v1/badges/6a79a059-b229-42cf-9ac3-4f565129f538/deploy-status)](https://app.netlify.com/sites/peaceful-heisenberg-96c15b/deploys)
![Contributors](https://img.shields.io/github/contributors/tkshill/Quarto)
![Open Issues](https://img.shields.io/github/issues-raw/tkshill/Quarto)
![Virtual Coffee](https://img.shields.io/badge/Virtual-Coffee-red)
![Hacktoberfest](https://img.shields.io/github/hacktoberfest/2021/tkshill/Quarto?color=orange)
---

# Welcome to Quarto!

## What is Quarto?

Hey, thanks for stopping by. This is an open-source, digital representation of the [Quarto](https://en.wikipedia.org/wiki/Quarto_(board_game)) board game written in the [Elm](https://elm-lang.org/) programming language.

## Why a random board game?

This project was mainly created to provide an example of a fully functional, **professional**, _accessible_ web app created entirely in Elm. It is also a space where people interested with working with Elm and/or are interested in open-source have a safe environment to practise with the help and guidance of the project maintainers. We happily accept anyone and everyone who wants to contribute, provided they abide by the code of content (link in the Table of Contents below).

Check out the live [Demo](https://elmquarto.netlify.app)!

# Table of Contents
- [Roadmap](https://github.com/tkshill/Quarto/blob/main/README.md#roadmap)
- [Run and Install](https://github.com/tkshill/Quarto/blob/main/README.md#run-and-install)
- [Contributing](https://github.com/tkshill/Quarto/blob/main/README.md#code-of-conduct)
- [Code of Conduct](https://github.com/tkshill/Quarto/blob/main/README.md#contributing)
- [What is Quarto (detailed)](https://github.com/tkshill/Quarto/blob/main/README.md#what-is-quarto)
- [F.A.Q.](https://github.com/tkshill/Quarto/blob/main/README.md#f.a.q.)
- [Tech Stack](https://github.com/tkshill/Quarto/blob/main/README.md#tech-stack-proposed)
- [Contact](https://github.com/tkshill/Quarto/blob/main/README.md#contact)
- [Authors](https://github.com/tkshill/Quarto/blob/main/README.md#authors)
- [Contributors](https://github.com/tkshill/Quarto/blob/main/README.md#contributors)
- [Acknowledgments](https://github.com/tkshill/Quarto/blob/main/README.md#acknowledgments)
- [License](https://github.com/tkshill/Quarto/blob/main/README.md#license)

# Roadmap

The plan is to create both a single player and multiplayer representation of the game. The front elm will be primarily designed using the [Elm](https://elm-lang.org) programming language. All the code will be freely available for use and reuse where possible.

This will likely be a long running project, with many software themes explored. Some of the concepts we hope to cover are:
- Functional Programming techniques
- Domain driven design and advanced domain modelling
- API design
- 3D graphics and design
- Animations in the browser
- Machine learning


## Phase 1 - October 1st, 2020 to October 31st, 2020 - (Complete)
- [x] Working implementation of the concept
- [x] human vs player model implemented
- [x] Randomized moves from the "computer player"
- [x] Basic responsiveness
- [x] Basic accessiblity markers

## Phase 2 - October 1st, 2021 - October 31st, 2021 (Active)
- [ ] Upgrade to elm-spa version 6
- [ ] Add a better landing page with instructions
- [ ] UX upgrade
- [ ] Adding Test Suite
- [ ] CI/CD pipeline
- [ ] Basic Keyboard functionality


## Phase 3 - November 1st, 2021 - December 31st, 2021 (Upcoming)
- [ ] 3D gameboard and game pieces (as part of the 5th Elm [Game Jam](https://itch.io/jam/elm-game-jam-5)
- [ ] backend server API design and implementation
- [ ] human vs human options
- [ ] keyboard-only functionality
- [ ] Version 1 release

## Phase 4 - April 1st, 2021 - July 31st (Upcoming)
- [ ] "Smarter computer" player
- [ ] ML implementation for computer player

# Run and Install

1. If you don't have it already, download and install [NODE.js](https://nodejs.org/en/download/)
2. If you don't have it already, install the appropriate [git](https://git-scm.com/downloads) for your OS.
3. Download and install [Elm](https://guide.elm-lang.org/install/elm.html)
4. Install [elm-spa](https://www.elm-spa.dev) via npm:
```
npm install -g elm-spa@latest
```
5. Create a local copy of this repo on your machine. Do not fork it unless you absolutely want to.
6. In a shell terminal/command line, navigate to the Quarto folder in the repository
7. Run the live development server with:
```
npm start
```
9. Navigate to the localhost port indicated by the server. (Default should be localhost:8000)
10. While not required, it is HIGHLY recommended that you install the appropriate [plugin](https://github.com/elm/editor-plugins) for your Code Editor/Integrated Develoment Environment if you wish to write Elm locally on your own machine.

A more in-depth guide can be found in the [CONTRIBUTING](https://github.com/tkshill/Quarto/blob/main/CONTRIBUTING.md)

# Tests

Coming Soon!

# Contributing

The incentive to start this project was out of a desire to learn more about good front-end desire and accessiblity, but also as part of the 2020 [Hacktoberfest]() initiative. This is an open source project that accepts anyone and everyone who is willing to help out. If you are unsure how to do your first contributions, please check out the [contributing](https://github.com/tkshill/Quarto/blob/main/CONTRIBUTING.md) file that lays out exactly how to get involved in open source.

# Code of Conduct

This is an inclusive space for education, learning and healthy communication. We ask that before you engage with the repository, please check out the [Code of Conduct](https://github.com/tkshill/Quarto/blob/main/CODE_OF_CONDUCT.md). This repo will serve as a learning experience not only in functional programming and UI design, but also in good community interactions. As much as possible, all contributors should feel safe, respected, and appreciated for their efforts.

# What is Quarto 

![Quarto Board and Pieces](https://github.com/tkshill/Quarto/blob/main/.github/486px-QuartoSpiel.JPG)

*CC BY-SA 3.0, https://commons.wikimedia.org/w/index.php?curid=114552*

From Wikipedia, the free encyclopedia - 
> Quarto is a board game for two players invented by Swiss mathematician Blaise Müller. It is published and copyrighted by Gigamic.
>
> The game is played on a 4×4 board. There are 16 unique pieces to play with, each of which is either:
>
> tall or short;
> red or blue (or a different pair of colors, e.g. light- or dark-stained wood);
> square or circular; and
> hollow-top or solid-top.
> Players take turns choosing a piece which the other player must then place on the board. A player wins by placing a piece on the board which forms a horizontal,
> vertical, or diagonal row of four pieces, all of which have a common attribute (all short, all circular, etc.).

You can think of it as tic tac toe for adults. It's honestly a brilliant game that strikes just the right balance of strategy but also fun and ease of pickup. 

**Affiliations**

This app has no affiliation with the official Quarto game, and will never *ever* become any sort've profit-seeking venture based on the Quarto IP. This is strictly for educational and entertainment purposes. If you wish to purchase the official game (we highly recommend it), you can do so [here](https://en.gigamic.com/game/quarto-classic) at the official Gigamic website.

# Hacktoberfest!

This project was part of the 2020 [Hacktoberfest](https://hacktoberfest.digitalocean.com) initiative, designed to get more developers, especially newbies, involved in open source projects and remote contributions.

A few key points on what this means:
- Some issues were given the `Hacktoberfest` label, meaning that we are making them available to be tackled during the month of October onwards
- For the month of October, anyone who wants to contribute can ask to pair on an issue, and the maintainers will schedule a 60-90 minute session where we walk you through getting set up, working through the issue, and submitting a PR. **This has been extended indefinitely. You should request to pair!**
- The label `good first issue` has been included on some issues. **Those issues will be assigned exclusively for new developers/people with limited github/git/OSS experience**
- Please ask questions about anything you are confused about. We've made some issue templates to help guide people on how to structure their questions and concerns, but feel free to express yourself, as long as it's in a kind and conscientious manner.

# Tech Stack (current)

- [Elm v 0.19.x](https://guide.elm-lang.org) as the front-end language of choice
- [Elm-spa](https://www.elm-spa.dev) as a single page app framework for use with the Elm language
- [Elm-UI](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/) for content and layout framework
- [Elm test](https://package.elm-lang.org/packages/elm-explorations/test/latest/) for unit testing

# F.A.Q.
## Why not a library/package like other OSS projects

This repository seeks to address the lack of beginner resources on project management and tooling in the programming community. There are many language tutorials and articles highlighting coding styles and techniques, but a dearth of full fledged applications that are parsable for new and junior developers, and fewer still that are geared toward learning how to build end to end applications. Every part of the development of this project will be kept public and avaialable and everyone and anyone are encouraged to be a part of its development. For the better part of a year ideally, this will exist as a living example of a elm based project, and follow as closely as possible modern, professional design and deployment techniques for web applications.

## Why Elm?

We like Elm. A lot. We're kind of obsessed.

But really, we genuinely like functional programming, and we love Elm, which we feel to be an accessible way to learn and develop robust software with functional programming. The maintainers are dedicated to making Elm accessible for anyone who wants to learn (a value echoed by the greater elm programming community at large) and we are will to pair with anyone who wishes to use this codebase as an introduction to use the language on a real project.

## How flexible are the project goals?

We really want to open up user input as to the direction of certain aspects of project design and functionality, but some parts of the scope are unchanging. At this point, we can say with a fair amount of certainty:
- Elm will be the primary development language for the front-end part of the application. The goal isn't to create a web game that happens to use elm. It's to create an Elm-based game. If you don't like Elm or don't want to contribute to an Elm project, we may explore other languages on the back end, and a little bit of javascript interop, but these will be few and far between
- Elm-UI will be the main styling framework utilized. Part of the goals for the maintainer are to use this project to get a greater understanding of Elm-UI, an opinionated layout and styling framework that takes a few key departures from traditional html and css. So this may not be the ideal project if you're looking to polish up your css styling
- The end goal is a fully functional PWA with 3D graphics. Even if all the functionality isn't implemented from the start, it's a when, not an if.
- No monetization of any part of this, ever.

We feel like this is the bare minimum that allows the maintainers to realize the project goals and also provides some stability for the people who wish to contribute. However, this still leaves a lot of things we are flexible on (and actively encourage contributions in)
- Design: The visuals of the project are completely up in the air. The only restricition is that whatever designs are chosen meet a high standard of accessibility.
- Business logic: We try to do good, functional design here but are interested to see the techniques people come up with for certain solutions.
- Build tools/pipeline: Currently, we're using netlify, and to be honest, it's far and above meeting our requirements, but there's still a lot more that could be done with things like github actions, and other CI/CD tooling and we're happy to get advice on that front.
- Tests, tests, tests: Unit, integration, end-to-end and user testing are all desperactely needed
- Documentation: We like docs. We need docs. We need up to date docs.

If any of that sounds interesting, don't hesistate to take a look at one of our [issues](https://github.com/tkshill/Quarto/issues) and dive in.

For more details on Project Goals, please check out the Quarto [Github Project](https://github.com/tkshill/Quarto/projects/2) where tasks, thoughts, bugs, and features are tracked.

For more long form, in depth content, check out the project [wiki](https://github.com/tkshill/Quarto/wiki) where you can find blog style posts and articles about technology and project management.

# Contact

The main way of submitting questions, comments, concerns, or kudos about this project is through the submission of issues. Alternatively, you can reach the author at [@tkshillinz](https://twitter.com/tkshillinz) on Twitter or tkshillinz@icloud.com

# Authors

This library was authored by [Kirk Shillingford](https://github.com/tkshill), who is a big nerd.

# Contributors

## Core Contributors

Our other core contributor is [Dominic Duffin](https://github.com/dominicduffin1).

## General Contributors

- [danielott](https://github.com/danieltott)
- [BekahHW](https://github.com/BekahHW)
- [tmillerj](https://github.com/tmillerj)
- [surajrpanchal](https://github.com/surajrpanchal)
- [mrsantons](https://github.com/mrsantons)
- [kkterai](https://github.com/kkterai)
- [gervanna](https://github.com/gervanna)
- [cambardell](https://github.com/cambardell)
- [brandonbrown4792](https://github.com/brandonbrown4792)
- [arpanchhetri](https://github.com/arpanchhetri)
- [CristhianMotoche](https://github.com/CristhianMotoche)
- [A-Scratchy](https://github.com/A-Scratchy)

# Acknowledgments

A huge thank you to the [Virtual Coffee](virtualcoffee.io) community who have encouraged, supported, and contributed to this project.

# License

This repository uses the [MIT license](https://github.com/tkshill/Quarto/blob/main/LICENSE)


