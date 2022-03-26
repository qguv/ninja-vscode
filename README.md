# ninja-vsx

A syntax highlighter for [Ninja build][Ninja] files ported from [SublimeNinja][Sublime].

[Ninja]: https://martine.github.io/ninja/
[Sublime]: https://github.com/pope/SublimeNinja

- [changelog](CHANGELOG.md)
- [Ninja file reference](https://ninja-build.org/manual.html)

## releasing

- run `./release.sh X.Y.Z` to update `package.json` and compile commit messages into the changelog
- edit `CHANGELOG.md` to clean up the newly generated entry
- run `./release.sh --continue` to commit, tag, and push the changes
- upload to Open VSX
- upload to the VS Marketplace
