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

This is a small open source project to create a functional, _accessible_ web app based on the popular (and highly entertaining) board game [Quarto](https://en.wikipedia.org/wiki/Quarto_(board_game)).

# Table of Contents
- [Project Goals](https://github.com/tkshill/Quarto/blob/main/README.md#project-goals)
- [What is Quarto](https://github.com/tkshill/Quarto/blob/main/README.md#what-is-quarto)
- [Run and Install](https://github.com/tkshill/Quarto/blob/main/README.md#run-and-install)
- [Contributing and Code of Conduct](https://github.com/tkshill/Quarto/blob/main/README.md#contributing-and-code-of-conduct)
- [Tech Stack](https://github.com/tkshill/Quarto/blob/main/README.md#tech-stack-proposed)
- [Contact](https://github.com/tkshill/Quarto/blob/main/README.md#contact)
- [License](https://github.com/tkshill/Quarto/blob/main/README.md#license)

# Project Goals

The plan is to create both a single player and multiplayer [Progressive Web App](https://www.howtogeek.com/342121/what-are-progressive-web-apps/) representation of the game. The front elm will be primarily designed using the [Elm](https://elm-lang.org) programming language, with the backend handled using Google [Firebase](https://firebase.google.com). All the code will be freely available for use and reuse where possible.

This will likely be a long running project, with many software themes explored. Some of the concepts we hope to cover are:
- Functional Programming techniques
- Domain driven design and advanced domain modelling
- Progressive Web Apps
- 3D graphics and design
- Animations in the browser
- Machine learning
- API design
- Working with Google Firebase

If any of that sounds interesting, don't hesistate to take a look at one of our [issues](https://github.com/tkshill/Quarto/issues) and dive in.

For more details on Project Goals, please check out the Quarto [Github Project](https://github.com/tkshill/Quarto/projects/2) where tasks, thoughts, bugs, and features are tracked.

For more long form, in depth content, check out the project [wiki](https://github.com/tkshill/Quarto/wiki) where you can find blog style posts and articles about technology and project management.

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

## Affiliations

This app has no affiliation with the official Quarto game, and will never *ever* become any sort've profit-seeking venture based on the Quarto IP. This is strictly for educational and entertainment purposes. If you wish to purchase the official game (we high recommend it), you can do so [here](https://en.gigamic.com/game/quarto-classic) at the official Gigamic website.

# Contributing and Code of Conduct

The incentive to start this project was out of a desire to learn more about good front-end desire and accessiblity, but also as part of the 2020 [Hacktoberfest]() initiative. This is an open source project that accepts anyone and everyone who is willing to help out. If you are unsure how to do your first contributions, please check out the [contributing](https://github.com/tkshill/Quarto/blob/main/CONTRIBUTING.md) file that lays out exactly how to get involved in open source.

Also please check out the [Code of Conduct](https://github.com/tkshill/Quarto/blob/main/CODE_OF_CONDUCT.md). This repo will serve as a learning experience not only in functional programming and UI design, but also in good community interactions. As much as possible, all contributors should feel safe, respected, and appreciated for their efforts.

## Warning about contributions before October 1st

This project is set to be ready for contributions by October 1st, 2020. Until that time, projects code, folders, available issues and many of the static files (including this README) may change. Contributors aren't necessarily discouraged from contributing during this setup stage, but we ask contributors create an [issue]() first, before attempting [pull requests] so the project maintainers can advise on the best course of action. 

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

# Tech Stack (proposed)

- [Elm v 0.19.x](https://guide.elm-lang.org) as the front-end language of choice
- [Elm-spa](https://www.elm-spa.dev) as a single page app framework for use with the Elm language
- [Elm-UI](https://package.elm-lang.org/packages/mdgriffith/elm-ui/latest/) for content and layout framework
- [tota11y](https://khan.github.io/tota11y/#Try-it) as an accessibility visualization toolkit
- [Firebase](https://firebase.google.com) as the mobile backend as a service
- [Elm test](https://package.elm-lang.org/packages/elm-explorations/test/latest/) for unit testing

# Contact

The main way of submitting questions, comments, concerns, or kudos about this project is through the submission of issues. Alternatively, you can reach me at [@tkshillinz](https://twitter.com/tkshillinz) on Twitter 

# License

This repository uses the [MIT license](https://github.com/tkshill/Quarto/blob/main/LICENSE)


