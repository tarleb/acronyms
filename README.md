# Acronyms

This Lua filter allows to define and use acronyms in a document.

> **Note**
>
> This is work in progress and some details may still change.
> Feedback is welcome!

See `sample.md` for an example and usage notes.

## Usage

The filter modifies the internal document representation; it can
be used with many publishing systems that are based on pandoc.

### Plain pandoc

Pass the filter to pandoc via the `--lua-filter` (or `-L`) command
line option.

    pandoc --lua-filter acronyms.lua ...

### Quarto

The filter must be used as a plain Lua filter; it's not (yet)
possible to install the filter as an extension. Download the file
`acronyms.lua` to your project directory and add list it in the
`filters` section of the YAML frontmatter.

``` yaml
---
filters:
  - acronyms.lua
---
```

### R Markdown

Use `pandoc_args` to invoke the filter. See the [R Markdown
Cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/lua-filters.html)
for details.

``` yaml
---
output:
  word_document:
    pandoc_args: ['--lua-filter=acronyms.lua']
---
```

## Dedication

For Sarah and Lukas, who got the ball rolling.

## License

This work is licensed under the MIT license. See file `LICENSE`
for details.
