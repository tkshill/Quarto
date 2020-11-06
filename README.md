![banner](https://github.com/tkshill/Quarto/blob/main/.github/banner-quarto.png)

![Help Wanted](https://img.shields.io/badge/%20-help--wanted-%23159818)
![MIT License](https://img.shields.io/github/license/tkshill/Quarto)
[![Netlify Status](https://api.netlify.com/api/v1/badges/6a79a059-b229-42cf-9ac3-4f565129f538/deploy-status)](https://app.netlify.com/sites/peaceful-heisenberg-96c15b/deploys)
![Contributors](https://img.shields.io/github/contributors/tkshill/Quarto)
![Open Issues](https://img.shields.io/github/issues-raw/tkshill/Quarto)
![Virtual Coffee](https://img.shields.io/badge/Virtual-Coffee-red)
![Hacktoberfest](https://img.shields.io/github/hacktoberfest/2020/tkshill/Quarto?color=orange)
---

# Welcome to Quarto!

Hey, thanks for stopping by.

This is a small open source project to create - and provide example of - a fully functional, **professional**, _accessible_ web app based on the popular (and highly entertaining) board game [Quarto](https://en.wikipedia.org/wiki/Quarto_(board_game)). The front end is design *fully* in the [Elm programming language](https://elm-lang.org/).

Check out the live [Demo](https://elmquarto.netlify.app)!

# Table of Contents
- [Roadmap](https://github.com/tkshill/Quarto/blob/main/README.md#roadmap)
- [Run and Install](https://github.com/tkshill/Quarto/blob/main/README.md#run-and-install)
- [Contributing and Code of Conduct](https://github.com/tkshill/Quarto/blob/main/README.md#contributing-and-code-of-conduct)
- [What is Quarto](https://github.com/tkshill/Quarto/blob/main/README.md#what-is-quarto)
- [Hacktoberfest](https://github.com/tkshill/Quarto/blob/main/README.md#hacktoberfest)

- [F.A.Q.](https://github.com/tkshill/Quarto/blob/main/README.md#f.a.q.)
- [Tech Stack](https://github.com/tkshill/Quarto/blob/main/README.md#tech-stack-proposed)
- [Contact](https://github.com/tkshill/Quarto/blob/main/README.md#contact)
- [License](https://github.com/tkshill/Quarto/blob/main/README.md#license)

# Roadmap

The plan is to create both a single player and multiplayer [Progressive Web App](https://www.howtogeek.com/342121/what-are-progressive-web-apps/) representation of the game. The front elm will be primarily designed using the [Elm](https://elm-lang.org) programming language. All the code will be freely available for use and reuse where possible.

This will likely be a long running project, with many software themes explored. Some of the concepts we hope to cover are:
- Functional Programming techniques
- Domain driven design and advanced domain modelling
- Progressive Web Apps
- 3D graphics and design
- Animations in the browser
- Machine learning
- API design

## Phase 1 - October 1st, 2020 to October 31st, 2020 - (Complete)
- Working implementation of the concept
- human vs player model implemented
- Randomized moves from the "computer player"
- Basic responsiveness
- Basic accessiblity markers

## Phase 2 - November 1st, 2020 - December 31st, 2020 (Active)
- 3D gameboard and game pieces (as part of the 5th Elm [Game Jam](https://itch.io/jam/elm-game-jam-5)
- Minor UI adjustments
- Complete PWA functionality
- Full integration testing
- Version 1 release

## Phase 3 - January 1st, 2021 - March 31st, 2021 (Upcoming)
- backend server API design and implementation
- human vs human options

## Phase 4 - April 1st, 2021 - July 31st (Upcoming)
- "Smarter computer" player
- ML implementation for computer player


# Run and Install

1. If you don't have it already, download and install [NODE.js](https://nodejs.org/en/download/)
2. Download and install [Elm](https://guide.elm-lang.org/install/elm.html)
3. Install [elm-spa](https://www.elm-spa.dev) via npm:
```
npm install -g elm-spa@latest
```
4. Fork this repo
5. Create a local copy on your machine
6. In a shell terminal/command line, navigate to the Quarto folder in the repository
7. Run the live development server with:
```
npm start
```
8. Navigate to the localhost port indicated by the server. (Default should be localhost:8000)

A more in-depth guide can be found in the [CONTRIBUTING](https://github.com/tkshill/Quarto/blob/main/CONTRIBUTING.md)

# Contributing

The incentive to start this project was out of a desire to learn more about good front-end desire and accessiblity, but also as part of the 2020 [Hacktoberfest]() initiative. This is an open source project that accepts anyone and everyone who is willing to help out. If you are unsure how to do your first contributions, please check out the [contributing](https://github.com/tkshill/Quarto/blob/main/CONTRIBUTING.md) file that lays out exactly how to get involved in open source.

**Warning about contributions before October 1st**

This project is set to be ready for contributions by October 1st, 2020. Until that time, projects code, folders, available issues and many of the static files (including this README) may change. Contributors aren't necessarily discouraged from contributing during this setup stage, but we ask contributors create an [issue]() first, before attempting [pull requests] so the project maintainers can advise on the best course of action. 


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

This project is part of the 2020 [Hacktoberfest](https://hacktoberfest.digitalocean.com) initiative, designed to get more developers, especially newbies, involved in open source projects and remote contributions.

A few key points on what this means:
- Some issues will be given the `Hacktoberfest` label, meaning that we are making them available to be tackled during the month of October onwards
- **For the month of October, anyone who wants to contribute can ask to pair on an issue, and the maintainers will schedule a 60-90 minute session where we walk you through getting set up, working through the issue, and submitting a PR.**
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

The main way of submitting questions, comments, concerns, or kudos about this project is through the submission of issues. Alternatively, you can reach me at [@tkshillinz](https://twitter.com/tkshillinz) on Twitter 

# License

This repository uses the [MIT license](https://github.com/tkshill/Quarto/blob/main/LICENSE)


