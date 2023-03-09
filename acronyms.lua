-- Print warnings to stderr
warn('@on')

local stringify = pandoc.utils.stringify
local acronyms = {}

local function normalize_acronyms (acronyms)
  local result = {}
  for k, v in pairs(acronyms) do
    if type(v) == 'string' or pandoc.utils.type(v) == 'Inlines' then
      result[k] = {
        short = pandoc.Inlines(k),
        long = pandoc.Inlines(v),
        seen = false,
      }
    elseif pandoc.utils.type(v) == 'table' then
      result[k] = {
        short = v.short or pandoc.Inlines(k),
        long = pandoc.Inlines(v.long) or
          error('Acronym without a long form: ' .. tostring(k)),
        seen = false
      }
    else
      -- weird acronym entry. Ignore.
      warn("Ignoring acronym definition for " .. tostring(k))
    end
  end
  return result
end

--
-- Format specific rendering of acronyms
--

--- Returns a generic Span for the given acronym.
local function render_acronym_span (id, acro, uppercase)
  local contents = acro.seen and acro.short or acro.long
  return pandoc.Span(contents, {acronym=id}):walk{
    Str = function (str)
      if uppercase then
        uppercase = false
        return str.text:gsub(
          '^([a-z])(.*)',
          function (fst, rst)
            return pandoc.text.upper(fst) .. rst
          end
        )
      end
    end
  }
end

--- Returns generic `Inlines` output for the given acronym.
--
-- Note that this function is overwritten for certain output formats.
-- See below.
local render_acronym = function (id, acro, uppercase)
  return pandoc.Inlines{render_acronym_generic(id, acro, uppercase)}
end

--- Returns the code that should be included in the document
-- header/preamble.
--
-- Should be overwritten for specific formats.
local acronyms_header = function (acronyms)
  return nil
end

if FORMAT:match 'latex' then
  render_acronym = function (id, acro, uppercase)
    if uppercase then
      return pandoc.RawInline('latex', ('\\Ac{%s}'):format(id))
    end
    return pandoc.RawInline('latex', ('\\ac{%s}'):format(id))
  end

  acronyms_header = function (acronyms)
    local tmpl = [[
\usepackage{acro}
$for(acronyms)$
\DeclareAcronym{$acronyms.id$}{
  $for(acronyms.properties/pairs)$$it.key$ = $it.value$$sep$,
  $endfor$
}
$endfor$
]]
    local objects = pandoc.List{}
    for id, acro in pairs(acronyms) do
      if acro.seen then
        objects:insert {
          id = id,
          properties = {
            long = acro.long,
            short = acro.short,
          }
        }
      end
    end
    local defs = pandoc.write(
      pandoc.Pandoc({}, {['acronyms'] = objects}),
      'latex',
      {template = pandoc.template.compile(tmpl)}
    )
    return pandoc.RawBlock('latex', defs)
  end

elseif FORMAT:match 'html' then
  render_acronym = function (id, acro, uppercase)
    if not acro.seen then
      return pandoc.Inlines{render_acronym_span(id, acro, uppercase)}
    end

    local long = stringify(acro.long):gsub([["]], '&quot;')
    local tag_open = ('<abbr title="%s" data-acronym="%s">'):format(long, id)
    return {pandoc.RawInline('html', tag_open)} ..
      render_acronym_span(id, acro, uppercase).content ..
      {pandoc.RawInline('html', '</abbr>')}
  end
end

--
-- Replace acronym references in the document
--

local function replace_acronym (id)
  local acro = acronyms[id]
  local uppercase = false
  if not acro then
    -- try to lowercase the first letter
    local lcid = id:gsub(
      '^([A-Z])(.*)$',
      function (fst, rest) return pandoc.text.lower(fst) .. rest end
    )
    acro = acronyms[lcid]
    uppercase = true
    if not acro then
      return nil
    end
  end

  local inlines = render_acronym(id, acro, uppercase)
  acro.seen = true
  return inlines
end

local function replace_wikilink_acronym (link)
  if link.title ~= 'wikilink' then
    return nil
  end

  local id = stringify(link.content)
  return replace_acronym(id)
end

local function replace_span_acronym (span)
  if not span.classes:includes 'acro' then
    return nil
  end

  local id = stringify(span.content)
  return replace_acronym(id)
end

local function append_to_list (list, elem)
  if elem == nil then
    return list
  elseif (pandoc.utils.type(list) == 'List') or
     (pandoc.utils.type(list) == 'table' and #list > 0) then
    list = pandoc.List(list)
    list:insert(elem)
    return list
  else
    return pandoc.List{elem}
  end
end

function Pandoc (doc)
  acronyms = doc.meta.acronyms or acronyms
  acronyms = normalize_acronyms(acronyms)
  doc = doc:walk {
    Link = replace_wikilink_acronym,
    Span = replace_span_acronym,
  }
  doc.meta['header-includes'] = append_to_list(
    doc.meta['header-includes'] or pandoc.List{},
    acronyms_header(acronyms)
  )
  return doc
end

--[=[
---
acronyms:
  html:
    short: HTML
    long: Hypertext Markup Language
  css: Cascading Style Sheets
---

This page uses [[html]] and [[css]]

]=]
