# Acronyms

This Lua filter allows to define and use acronyms in a document.

> **Note**
>
> This is work in progress and some details may still change.
> Feedback is welcome!

See `sample.md` for an example and usage notes.

## Usage

Acronyms should be defined in the `acronyms` part of the document
metadata. E.g.:

``` yaml
acronyms:
  html:
    short: HTML
    long: Hypertext Markup Language
  css:
    short: CSS
    long: Cascading Style Sheets
  amphetamine: alpha-methylphenethylamine
```

The acronyms can then be used by referencing an acronym *id* in a
span with class `acro`:

``` markdown
Webpages are styled with [css]{.acro}
```

Pandoc 3.0 and later added support for wikilinks in Markdown;
enabling the respective extension allows to use wikilink syntax
for acronyms.

``` markdown
This page uses [[html]] and [[css]].
```

Capitalize the acronym ID to uppercase the first letter of the
replacement text: `[Amphetamine]{.acro}` will produce
`Alpha-methylphenethylamine`.

### Placing the list of acronyms

The list of acronyms will be placed in the div with id
`acronym-defs` if any such div is part of the document.

``` Markdown
## Acronyms

The following acronyms are used in this thesis:

::: {#acronym-defs}
:::
```

## Setup

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
