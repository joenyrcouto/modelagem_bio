-- remove source code in CodeBlocks from main body and save to appendix
appendix = {}

function CodeBlock(el)
  -- Verifica se é uma célula de código do Quarto/Jupyter
  local is_cell_code = el.classes[2] == "cell-code"
  
  if is_cell_code then
    -- Processa o texto do bloco para extrair metadados de comentários
    local lines = {}
    for line in el.text:gmatch("[^\r\n]+") do
      table.insert(lines, line)
    end
    
    local title = nil
    local caption = nil
    local label = nil
    local figlabel = nil
    local new_lines = {}
    
    for _, line in ipairs(lines) do
      -- Procura comentários no formato "# @chave: valor"
      local key, value = line:match("^#%s*@(%w+)%s*:%s*(.*)$")
      if key then
        if key == "title" then
          title = value
        elseif key == "caption" then
          caption = value
        elseif key == "label" then
          label = value
        elseif key == "figlabel" then
          figlabel = value
        end
        -- Não adiciona esta linha ao novo código (comentário removido)
      else
        table.insert(new_lines, line)
      end
    end
    
    -- Atualiza o texto do bloco sem os comentários de metadados
    el.text = table.concat(new_lines, "\n")
    
    -- Armazena os metadados no bloco para uso posterior
    if title then
      el.attributes["custom-title"] = title
    end
    if caption then
      el.attributes["custom-caption"] = caption
    end
    if label then
      el.attributes["custom-label"] = label
    end
    if figlabel then
      el.attributes["custom-figlabel"] = figlabel
    end
    
    table.insert(appendix, el)
    return {}   -- remove do corpo principal
  else
    return el   -- mantém no corpo
  end
end

-- reads yaml to obtain desired header for code appendix
-- writes appendix to file
function Meta(m)

  if m["code-appendix-title"] ~= nil then
    codeAppendixTitle = pandoc.utils.stringify(m["code-appendix-title"])
  else
    codeAppendixTitle = pandoc.Str("Code Appendix")
  end

  if m["code-appendix-header-level"] ~= nil then
    codeAppendixHeaderLevel = tonumber(pandoc.utils.stringify(m["code-appendix-header-level"]))
  else
    codeAppendixHeaderLevel = 1
  end

  if m["code-appendix-write"] ~= nil then
    codeAppendixWrite = m["code-appendix-write"]
  else
    codeAppendixWrite = true
  end

  -- write appendix to file
  if m["code-appendix-file"] ~= nil then

    codeAppendixFile = pandoc.utils.stringify(m["code-appendix-file"])    
    codeAppendixExt = codeAppendixFile:match("%.[^.]+$")    

    if codeAppendixExt == nil then
      codeAppendixExt = ".md"
      codeAppendixFile = codeAppendixFile .. codeAppendixExt
    end

    local f = io.open(pandoc.system.get_working_directory() .. "/" .. codeAppendixFile, 'w')
 
    for index, value in ipairs(pandoc.List(appendix)) do
      if codeAppendixExt == ".md" or codeAppendixExt == ".qmd" then
        f:write(
          "```" .. "\n" .. pandoc.List(appendix)[index].text .. "\n" .. "```" .. "\n\n"
        )
      else 
        f:write(
          pandoc.List(appendix)[index].text .. "\n\n"
        )  
      end
    end
    
    f:close()

  end

  return m

end

-- append pandoc document with source code
function Pandoc(doc)

  if codeAppendixWrite then
    -- Cabeçalho principal do apêndice (sem numeração)
    local appendixHeader = pandoc.Header(codeAppendixHeaderLevel, codeAppendixTitle)
    appendixHeader.classes = {"unnumbered"}

    -- Lista para os blocos com títulos
    local appendixWithHeadings = pandoc.List()
    appendixWithHeadings:insert(appendixHeader)

    for _, cb in ipairs(appendix) do
      -- Obtém linguagem
      local lang = cb.classes[1] or "código"
      
      -- Obtém metadados customizados
      local title = cb.attributes["custom-title"]
      local caption = cb.attributes["custom-caption"]
      local label = cb.attributes["custom-label"]
      local figlabel = cb.attributes["custom-figlabel"]
      
      -- Constrói título de nível 2
      local heading_text
      if title then
        heading_text = title
      else
        heading_text = "Código em " .. lang:gsub("^%l", string.upper)
      end
      
      -- Cria título sem numeração
      local header = pandoc.Header(2, pandoc.Str(heading_text))
      header.classes = {"unnumbered"}
      
      -- Cria um container para agrupar tudo
      local container_content = pandoc.List()
      
      -- Âncora vazia (span) para que o link vá para o início do bloco
      if label then
        local anchor = pandoc.Span({}, {})
        anchor.identifier = "code-" .. label
        container_content:insert(anchor)
      end
      
      container_content:insert(header)
      container_content:insert(cb)
      
      -- Legenda
      if caption then
        local caption_para = pandoc.Para(pandoc.Str(caption))
        container_content:insert(caption_para)
      end
      
      -- Link de volta para a figura
      if figlabel then
        local backlink_text = "↩︎ Voltar para a figura"
        local backlink = pandoc.Link(pandoc.Str(backlink_text), "#fig-" .. figlabel)
        local backlink_para = pandoc.Para(pandoc.List({backlink}))
        container_content:insert(backlink_para)
      end
      
      -- Adiciona o container
      local container = pandoc.Div(container_content, {})
      appendixWithHeadings:insert(container)
      
      -- Espaço entre blocos
      appendixWithHeadings:insert(pandoc.Para(pandoc.Str(" ")))
    end
    
    -- Adiciona todos os elementos ao documento
    doc.blocks:extend(appendixWithHeadings)
  end
  
  return doc
  
end
