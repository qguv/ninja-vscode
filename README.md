# ninja-vsx

A VSCode extension providing syntax highlighting for [Ninja build](https://ninja-build.org/) files.

- [changelog](CHANGELOG.md)
- [Ninja file reference](https://ninja-build.org/manual.html)

## building

- `npm install -g vsce` or use the [vsce AUR package](https://aur.archlinux.org/packages/vsce).
- `vsce package`
- the package will be built into `ninja-X.Y.Z.vsix` where `X.Y.Z` is the version

## releasing

- run `./release.sh X.Y.Z` to update `package.json` and compile commit messages into the changelog
- edit `CHANGELOG.md` to clean up the newly generated entry
- run `./release.sh --continue` to commit, tag, and push the changes
- upload to Open VSX
- upload to the VS Marketplace

## acknowledgements

- originally ported from [SublimeNinja](https://github.com/pope/SublimeNinja) by [surajbarkale](https://marketplace.visualstudio.com/items?itemName=surajbarkale.ninja)
- forked with permission by [qguv](https://github.com/qguv)
