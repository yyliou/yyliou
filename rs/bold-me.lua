-- Set the author's own name in bold in the reference list.
--
-- rmarkdown may run Lua filters before --citeproc, so the filter builds the
-- bibliography itself, bolds the name inside the refs div, and removes the
-- bibliography from the metadata so that citeproc has nothing left to redo.

local OWN_GIVEN = "Yu-You"
local OWN_FAMILY = "Liou"

local function is_own_name(given, gap, family)
  return given and given.t == "Str" and given.text == OWN_GIVEN
    and gap and gap.t == "Space"
    and family and family.t == "Str"
    and family.text:sub(1, #OWN_FAMILY) == OWN_FAMILY
end

local function bold_own_name(inlines)
  local result = pandoc.Inlines{}
  local i = 1
  while i <= #inlines do
    local given, gap, family = inlines[i], inlines[i + 1], inlines[i + 2]
    if is_own_name(given, gap, family) then
      local trailing = family.text:sub(#OWN_FAMILY + 1)
      result:insert(pandoc.Strong{pandoc.Str(OWN_GIVEN), pandoc.Space(), pandoc.Str(OWN_FAMILY)})
      if trailing ~= "" then result:insert(pandoc.Str(trailing)) end
      i = i + 3
    else
      result:insert(given)
      i = i + 1
    end
  end
  return result
end

local function bold_in_refs(div)
  if div.identifier == "refs" then
    return pandoc.walk_block(div, {Inlines = bold_own_name})
  end
end

function Pandoc(doc)
  doc = pandoc.utils.citeproc(doc)
  doc = doc:walk({Div = bold_in_refs, Cite = function(cite) return cite.content end})
  doc.meta.bibliography = nil
  doc.meta.references = nil
  return doc
end
