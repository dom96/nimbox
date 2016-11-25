# Nimbox

Nimbox is a [Rustbox][rb]-inspired [termbox][tb] wrapper for [Nim][nim].

Nimbox uses an object-oriented style, making writing text-based user
interfaces easy and intuitive.

Nimbox is still in development and may eat your laundry. **You have been
warned.**

## Installation

Nimbox can be installed through [Nimble][nimble], Nim's package manager,
though you currently have to install directly from this Git repository,
as there's [a bug][nimblebug] which prevents it working correctly when
installed from the Nimble package listing.

```shell
nimble install https://notabug.org/vktec/nimbox.git
```

[rb]: https://github.com/gchp/rustbox
[tb]: https://github.com/nsf/termbox
[nim]: http://nim-lang.org/
[nimble]: https://github.com/nim-lang/nimble
[nimblebug]: https://github.com/nim-lang/nimble/issues/280
