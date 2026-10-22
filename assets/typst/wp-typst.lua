-- Working Paper · encadrés du site traduits en blocs Typst (fonctions de assets/typst/typst-template.typ).
-- Sans effet hors Typst (en HTML, components.scss suffit). Classes : celles du guide de rédaction, § 5.

if not quarto.doc.is_format("typst") then return {} end

-- classe → étiquette, couleur, fond, tirets (même grammaire que components.scss)
local ENCADRES = {
  rappel  = { "Rappel", "wp-encre-2", "wp-teinte" },
  s1      = { "Rappel", "wp-encre-2", "wp-teinte" },
  retenir = { "À retenir", "wp-accent", "wp-teinte" },
  droit   = { "Et le droit ?", "wp-encre-2" },
  piege   = { "Point d'attention", "wp-rouge" },
  auteur  = { "Auteur · école", "wp-encre-2" },
  methode = { "Méthode", "wp-encre-2", nil, true },
}

local function str(s) return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"' end
local function raw(s) return pandoc.RawBlock("typst", s) end
local function wrap(open, content)
  local out = pandoc.Blocks({ raw(open .. "[") })
  out:extend(content)
  out:insert(raw("]"))
  return out
end

-- Vidéo : l'iframe disparaît, la légende devient un lien vers YouTube
local function video(div)
  local src, legende
  div:walk({
    RawBlock = function(r) src = src or r.text:match('src="([^"]+)"') end,
    RawInline = function(r) src = src or r.text:match('src="([^"]+)"') end,
  })
  for _, b in ipairs(div.content) do
    if b.t == "Para" or b.t == "Plain" then legende = b.content end
  end
  if not src then return div.content end
  local id = src:match("/embed/([%w_-]+)")
  local url = id and ("https://www.youtube.com/watch?v=" .. id) or src
  local blocs = pandoc.Blocks({ pandoc.Plain(legende or { pandoc.Str(url) }) })
  return wrap("#wp-video(" .. str(url) .. ")", blocs)
end

-- Portraits (.wp-portrait) d'un encadré : retirés du texte, rendus en colonne par wp-encadre
local function portraits(blocks)
  local reste, items = pandoc.Blocks({}), {}
  for _, b in ipairs(blocks) do
    if b.t == "Div" and b.classes:includes("wp-portrait") then
      local src, credit = nil, {}
      b:walk({
        Image = function(i) src = src or i.src end,
        Span = function(sp) if sp.classes:includes("wp-credit") then credit = sp.content end end,
      })
      if src then
        local cr = pandoc.write(pandoc.Pandoc({ pandoc.Plain(credit) }), "typst"):gsub("%s+$", "")
        items[#items + 1] = string.format('(image(%s, width: 2.1cm, height: 2.8cm, fit: "cover"), [%s])', str(src), cr)
      end
    else
      reste:insert(b)
    end
  end
  return reste, (#items > 0 and ("(" .. table.concat(items, ", ") .. ",)") or "()")
end

function Div(div)
  local c = div.classes
  local label = div.attributes["data-label"] or div.attributes["label"]
  for classe, s in pairs(ENCADRES) do
    if c:includes(classe) then
      local contenu, pts = portraits(div.content)
      return wrap(string.format("#wp-encadre(label: %s, couleur: %s, fond: %s, tirets: %s, portraits: %s)",
        str(label or s[1]), s[2], s[3] or "none", s[4] and "true" or "false", pts), contenu)
    end
  end
  if c:includes("wp-document") then
    return wrap("#wp-document(label: " .. str(label or "Document") .. ")", div.content)
  end
  if c:includes("wp-entete") then
    local items = {}
    for _, b in ipairs(div.content) do
      items[#items + 1] = "[" .. pandoc.write(pandoc.Pandoc({ pandoc.Plain(b.content or {}) }), "typst"):gsub("%s+$", "") .. "]"
    end
    return raw("#wp-entete(" .. table.concat(items, ", ") .. ")")
  end
  if c:includes("wp-video") then return video(div) end
  if c:includes("note-td") then return wrap("#wp-note-td", div.content) end
end

-- Liens internes (.qmd) : vers la page en ligne, seule cible valable depuis un PDF
local SITE = "https://pierrebeaucoral.github.io/intro-eco-2/"
function Link(link)
  local t = link.target
  if t:match("^%a+:") or t:match("^#") or not t:match("%.qmd") then return nil end
  local dir = pandoc.path.directory(pandoc.path.make_relative(quarto.doc.input_file, quarto.project.directory))
  local parts = {}
  for seg in pandoc.path.join({ dir, (t:gsub("%.qmd", ".html")) }):gmatch("[^/]+") do
    if seg == ".." then table.remove(parts) elseif seg ~= "." then parts[#parts + 1] = seg end
  end
  link.target = SITE .. table.concat(parts, "/")
  return link
end

-- Corrigé (tdN-corrige.qmd) : le site ajoute « Corrigé » au titre en CSS ; le PDF l'écrit
function Meta(meta)
  if quarto.doc.input_file:match("%-corrige%.qmd$") and meta.title then
    meta.title = pandoc.Inlines(meta.title):clone()
    meta.title:extend({ pandoc.Str(" ·"), pandoc.Space(), pandoc.Str("Corrigé") })
    return meta
  end
end

-- Typographie française : espace insécable avant ; : ! ? » % et après «
local function avant(t) return t:match("^[;:!?%%]") or t:sub(1, 2) == "»" end  -- » : 2 octets, hors classe
local function apres(t) return t:sub(-2) == "«" end
-- Espace fine insécable (U+202F) : l'insécable U+00A0 devient « ~ » en Typst, visible tel quel dans les titres d'exemples
local FINE = "\u{202F}"
function Str(el)
  if el.text:find("\u{00A0}") then return pandoc.Str((el.text:gsub("\u{00A0}", FINE))) end
end
function Inlines(els)
  for i = #els - 1, 2, -1 do
    local prev, nxt = els[i - 1], els[i + 1]
    if els[i].t == "Space" and ((nxt.t == "Str" and avant(nxt.text)) or (prev.t == "Str" and apres(prev.text))) then
      els[i] = pandoc.Str(FINE)
    end
  end
  return els
end

local SPANS = {
  bareme = '#h(0.3em)#text(font: wp-mono, size: 0.78em, fill: wp-accent)',
  ["wp-source"] = '#text(size: 0.85em, fill: wp-encre-2)',
  ["wp-cc"] = '#text(font: wp-mono, size: 0.75em, fill: wp-rouge)',
  ["wp-mono"] = '#text(font: wp-mono)',
}

function Span(span)
  for classe, open in pairs(SPANS) do
    if span.classes:includes(classe) then
      local out = pandoc.Inlines({ pandoc.RawInline("typst", open .. "[") })
      out:extend(span.content)
      out:insert(pandoc.RawInline("typst", "]"))
      return out
    end
  end
end
