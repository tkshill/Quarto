// Initial data passed to Elm (should match `Flags` defined in `Shared.elm`)
// https://guide.elm-lang.org/interop/flags.html
var flags = null

// Start our Elm application
var app = Elm.Main.init({ flags: { width: window.innerWidth, height: window.innerHeight } })

// Ports go here
// https://guide.elm-lang.org/interop/ports.html