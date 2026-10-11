-- Keep the original TeX for the locally embedded KaTeX renderer. Quarto 1.4's
-- built-in self-contained math loader still fetches its library at runtime.
function Math(el)
  if FORMAT:match('html') or FORMAT:match('revealjs') then
    local tex = el.text:gsub('&', '&amp;'):gsub('<', '&lt;'):gsub('>', '&gt;')
    local kind = el.mathtype == 'DisplayMath' and 'display' or 'inline'
    return pandoc.RawInline('html', '<span class="math ' .. kind .. '">' .. tex .. '</span>')
  end
end
