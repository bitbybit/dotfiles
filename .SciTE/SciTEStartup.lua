-- Scite Xml Autocompletion
-- automatically closes tags and quotes attributes in XHTML and any XML files
-- executing if property tags.autoclose=1 (see file SciTEGlobal.properties)
-- Author: Romain Vallet (http://lua-users.org/wiki/SciteXmlAutocompletion)
-- Modified by: VladVRO
-----------------------------------------------

HTML_SINGLE_TAGS_LIST = {
    ["br"] = true,
    ["hr"] = true,
    ["img"] = true,
    ["input"] = true,
    ["meta"] = true,
}

function XMLTagsAutoClose (c)
    local nLexer = editor.Lexer
    if nLexer ~= 4 and nLexer ~= 5 then return end
    -- tag completion
    local pEnd = editor.CurrentPos - 1
    if pEnd < 1 then return end
    local ch = editor.CharAt[pEnd]
    if ch == 62 then -- ">"
        local nStyle = editor.StyleAt[pEnd - 1]
        if nStyle > 8 then return end
        local nLastChar = editor.CharAt[pEnd - 1]
        if nStyle == 6 and nLastChar ~= 34 then return end
        if nStyle == 7 and nLastChar ~= 39 then return end
        if nLastChar == 47 or nLastChar == 37 or nLastChar == 60 or nLastChar == 63 then return end
        local pStart = pEnd
        repeat
            pStart = pStart - 1
            if (editor.CharAt[pStart] == 32) then
                pEnd = pStart
            end
        until editor.CharAt[pStart] == 60 or pStart == 0
        if editor.CharAt[pStart + 1] == 47 then return end
        if pStart == 0 and editor.CharAt[pStart] ~= 60 then return end
        local tag = editor:textrange(pStart + 1, pEnd)
        if nLexer == 4 and HTML_SINGLE_TAGS_LIST[tag] then return end -- exclude html single tags
        editor:BeginUndoAction()
        editor:InsertText(editor.CurrentPos, "</" .. tag .. ">")
        editor:EndUndoAction()
    end

    -- attribute quotes
    if ch == 61 then -- "="
        local nStyle = editor.StyleAt[editor.CurrentPos - 2]
        if nStyle == 3 or nStyle == 4 then
            editor:BeginUndoAction()
            editor:InsertText(editor.CurrentPos, "\"\"")
            editor:GotoPos(editor.CurrentPos + 1)
            editor:EndUndoAction()
        end
    end
end

-- Добавляем свой обработчик события OnChar
local old_OnChar = OnChar
function OnChar(char)
	local result
	if old_OnChar then result = old_OnChar(char) end
  if props['macro-recording'] ~= '1' and tonumber(props['tags.autoclose']) == 1 then
      if XMLTagsAutoClose(char) then return true end
  end
	return result
end


--[[--------------------------------------------------
Paired Tags (логическое продолжение скриптов highlighting_paired_tags.lua и HTMLFormatPainter.lua)
Version: 2.2.2
Author: mozers, VladVRO
------------------------------
Подсветка парных и непарных тегов в HTML и XML
В файле настроек задается цвет подсветки парных и непарных тегов

Скрипт позволяет копировать и удалять (текущие подсвеченные) теги, а также
вставлять в нужное место ранее скопированные (обрамляя тегами выделенный текст)

Внимание:
В скрипте используются функции из COMMON.lua (EditorMarkText, EditorClearMarks)

------------------------------
Подключение:
Добавить в SciTEStartup.lua строку:
        dofile (props["SciteDefaultHome"].."\\tools\\paired_tags.lua")
Добавить в файл настроек параметр:
        hypertext.highlighting.paired.tags=1
Дополнительно можно задать стили используемых маркеров (1 и 2):
        find.mark.1=#0099FF
        find.mark.2=#FF0000 (если этот параметр не задан, то непарные теги не подсвечиваются)

Команды копирования, вставки, удаления тегов добавляются в меню Tools обычным порядком:
        tagfiles=$(file.patterns.html);$(file.patterns.xml)

        command.name.5.$(tagfiles)=Copy Tags
        command.5.$(tagfiles)=CopyTags
        command.mode.5.$(tagfiles)=subsystem:lua,savebefore:no
        command.shortcut.5.$(tagfiles)=Alt+C

        command.name.6.$(tagfiles)=Paste Tags
        command.6.$(tagfiles)=PasteTags
        command.mode.6.$(tagfiles)=subsystem:lua,savebefore:no
        command.shortcut.6.$(tagfiles)=Alt+P

        command.name.7.$(tagfiles)=Delete Tags
        command.7.$(tagfiles)=DeleteTags
        command.mode.7.$(tagfiles)=subsystem:lua,savebefore:no
        command.shortcut.7.$(tagfiles)=Alt+D

Для быстрого включения/отключения подсветки можно добавить команду:
        command.checked.8.$(tagfiles)=$(hypertext.highlighting.paired.tags)
        command.name.8.$(tagfiles)=Highlighting Paired Tags
        command.8.$(tagfiles)=highlighting_paired_tags_switch
        command.mode.8.$(tagfiles)=subsystem:lua,savebefore:no
--]]----------------------------------------------------










------[[ T E X T   M A R K S ]]-------------------------

-- Выделение текста маркером определенного стиля
function EditorMarkText(start, length, style_number)
        local current_mark_number = scite.SendEditor(SCI_GETINDICATORCURRENT)
        scite.SendEditor(SCI_SETINDICATORCURRENT, style_number)
        scite.SendEditor(SCI_INDICATORFILLRANGE, start, length)
        scite.SendEditor(SCI_SETINDICATORCURRENT, current_mark_number)
end

-- Очистка текста от маркерного выделения заданного стиля
--   если параметры отсутсвуют - очищаются все стили во всем тексте
--   если не указана позиция и длина - очищается весь текст
function EditorClearMarks(style_number, start, length)
        local _first_style, _end_style, style
        local current_mark_number = scite.SendEditor(SCI_GETINDICATORCURRENT)
        if style_number == nil then
                _first_style, _end_style = 0, 31
        else
                _first_style, _end_style = style_number, style_number
        end
        if start == nil then
                start, length = 0, editor.Length
        end
        for style = _first_style, _end_style do
                scite.SendEditor(SCI_SETINDICATORCURRENT, style)
                scite.SendEditor(SCI_INDICATORCLEARRANGE, start, length)
        end
        scite.SendEditor(SCI_SETINDICATORCURRENT, current_mark_number)
end

----------------------------------------------------------------------------
-- Задание стиля для маркеров (затем эти маркеры можно будет использовать в скриптах, вызывая их по номеру)

-- Translate color from RGB to win
local function encodeRGB2WIN(color)
        if string.sub(color,1,1)=="#" and string.len(color)>6 then
                return tonumber(string.sub(color,6,7)..string.sub(color,4,5)..string.sub(color,2,3), 16)
        else
                return color
        end
end

local function InitMarkStyle(style_number, indic_style, color, alpha_fill)
        editor.IndicStyle[style_number] = indic_style
        editor.IndicFore[style_number] = encodeRGB2WIN(color)
        editor.IndicAlpha[style_number] = alpha_fill
end

local function style(mark_string)
        local mark_style_table = {
        plain    = INDIC_PLAIN,    squiggle = INDIC_SQUIGGLE,
        tt       = INDIC_TT,       diagonal = INDIC_DIAGONAL,
        strike   = INDIC_STRIKE,   hidden   = INDIC_HIDDEN,
        roundbox = INDIC_ROUNDBOX, box      = INDIC_BOX
        }
        return mark_style_table[mark_string]
end

local function EditorInitMarkStyles()
        for style_number = 0, 31 do
                local mark = props["find.mark."..style_number]
                if mark ~= "" then
                        local mark_color = mark:match("#%x%x%x%x%x%x") or (props["find.mark"]):match("#%x%x%x%x%x%x") or "#0F0F0F"
                        local mark_style = style(mark:match("%l+")) or INDIC_ROUNDBOX
                        local alpha_fill = tonumber((mark:match("%@%d+") or ""):sub(2)) or 30
                        InitMarkStyle(style_number, mark_style, mark_color, alpha_fill)
                end
        end
end

-- Add user event handler OnOpen
local old_OnOpen = OnOpen
local OnOpenOne = true
function OnOpen(file)
        local result
        if old_OnOpen then result = old_OnOpen(file) end
        if OnOpenOne then
                EditorInitMarkStyles()
                OnOpenOne = false
        end
        return result
end









local t = {}
-- t.tag_start, t.tag_end, t.paired_start, t.paired_end  -- positions
-- t.begin, t.finish  -- contents of tags (when copying)
local old_current_pos

function CopyTags()
        local tag = editor:textrange(t.tag_start, t.tag_end+1)
        if t.paired_start~=nil then
                local paired = editor:textrange(t.paired_start, t.paired_end+1)
                if t.tag_start < t.paired_start then
                        t.begin = tag
                        t.finish = paired
                else
                        t.begin = paired
                        t.finish = tag
                end
        else
                t.begin = tag
                t.finish = nil
        end
end

function PasteTags()
        if t.begin~=nil then
                if t.finish~=nil then
                        local sel_text = editor:GetSelText()
                        editor:ReplaceSel(t.begin..sel_text..t.finish)
                        if sel_text == '' then
                                editor:GotoPos(editor.CurrentPos - #t.finish)
                        end
                else
                        editor:ReplaceSel(t.begin)
                end
        end
end

function DeleteTags()
        if t.tag_start~=nil then
                editor:BeginUndoAction()
                if t.paired_start~=nil then
                        if t.tag_start < t.paired_start then
                                editor:SetSel(t.paired_start, t.paired_end+1)
                                editor:DeleteBack()
                                editor:SetSel(t.tag_start, t.tag_end+1)
                                editor:DeleteBack()
                        else
                                editor:SetSel(t.tag_start, t.tag_end+1)
                                editor:DeleteBack()
                                editor:SetSel(t.paired_start, t.paired_end+1)
                                editor:DeleteBack()
                        end
                else
                        editor:SetSel(t.tag_start, t.tag_end+1)
                        editor:DeleteBack()
                end
                editor:EndUndoAction()
        end
end

function highlighting_paired_tags_switch()
        local prop_name = 'hypertext.highlighting.paired.tags'
        props[prop_name] = 1 - tonumber(props[prop_name])
        EditorClearMarks(1)
        EditorClearMarks(2)
end

local function PairedTagsFinder()
        local current_pos = editor.CurrentPos
        if current_pos == old_current_pos then return end
        old_current_pos = current_pos

        EditorClearMarks(1)
        EditorClearMarks(2)

        t.tag_start = nil
        t.tag_end = nil
        t.paired_start = nil
        t.paired_end = nil

        local tag_start = editor:findtext("[<>]", SCFIND_REGEXP, current_pos, 0)
        if tag_start == nil then return end
        if editor.CharAt[tag_start] ~= 60 then return end
        if editor.StyleAt[tag_start+1] ~= 1 then return end
        if tag_start == t.tag_start then return end
        t.tag_start = tag_start

        t.tag_end = editor:findtext("[<>]", SCFIND_REGEXP, current_pos, editor.Length)
        if t.tag_end == nil then return end
        if editor.CharAt[t.tag_end] ~= 62 then t.tag_end = nil return end

        local dec, find_end
        if editor.CharAt[t.tag_start+1] == 47 then
                dec, find_end = -1, 0
        else
                dec, find_end =  1, editor.Length
        end

        -- Find paired tag
        local tag = editor:textrange(editor:findtext("\\w+", SCFIND_REGEXP, t.tag_start, t.tag_end))
        local count = 1
        local find_start = t.tag_start+dec
        repeat
                t.paired_start, t.paired_end = editor:findtext("</*"..tag.."[^>]*", SCFIND_REGEXP, find_start, find_end)
                if t.paired_start == nil then break end
                if editor.CharAt[t.paired_start+1] == 47 then
                        count = count - dec
                else
                        count = count + dec
                end
                if count == 0 then break end
                find_start = t.paired_start + dec
        until false

        if t.paired_start ~= nil then
                -- paint in Blue
                EditorMarkText(t.tag_start + 1, t.tag_end - t.tag_start - 1, 1)
                EditorMarkText(t.paired_start + 1, t.paired_end - t.paired_start - 1, 1)
        else
                if props["find.mark.2"] ~= '' then
                        -- paint in Red
                        EditorMarkText(t.tag_start + 1, t.tag_end - t.tag_start - 1, 2)
                end
        end
end

-- Add user event handler OnUpdateUI
local old_OnUpdateUI = OnUpdateUI
function OnUpdateUI ()
        local result
        if old_OnUpdateUI then result = old_OnUpdateUI() end
        -- if props['FileName'] ~= '' then
                if tonumber(props["hypertext.highlighting.paired.tags"]) == 1 then
                        -- if editor.GetLexerLanguage() == "hypertext" or editor.GetLexerLanguage() == "xml" then
                                PairedTagsFinder()
                        -- end
                end
        -- end
        return result
end
