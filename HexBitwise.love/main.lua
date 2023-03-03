local PIXEL_WIDTH = 25
local PIXEL_HEIGHT = 25
local ROWS = 3 --// Works kind of like ROW_OFFSET
local ROW_OFFSET = 1 --// How many rows should be cut off, 3 for only showing result, 1 for showing all operands to the left of result
local ROW_CUT_REPEAT = false --// To avoid repetition of values that already exist in table, not required to be on

local function Or(Left, Right)
    local Result = ""

    local Length = #Left
    for i = Length, 1, -1 do
        local BitL = Left:sub(i, i)
        local BitR = Right:sub(i, i)
        if BitL == "0" and BitR == "0" then Result = "0" .. Result end
        if BitL == "1" and BitR == "0" then Result = "1" .. Result end
        if BitL == "0" and BitR == "1" then Result = "1" .. Result end
        if BitL == "1" and BitR == "1" then Result = "1" .. Result end
    end

    return Result
end

local function And(Left, Right)
    local Result = ""

    local Length = #Left
    for i = Length, 1, -1 do
        local BitL = Left:sub(i, i)
        local BitR = Right:sub(i, i)
        if BitL == "0" and BitR == "0" then Result = "0" .. Result end
        if BitL == "1" and BitR == "0" then Result = "0" .. Result end
        if BitL == "0" and BitR == "1" then Result = "0" .. Result end
        if BitL == "1" and BitR == "1" then Result = "1" .. Result end
    end

    return Result
end

local function Xor(Left, Right)
    local Result = ""

    local Length = #Left
    for i = Length, 1, -1 do
        local BitL = Left:sub(i, i)
        local BitR = Right:sub(i, i)
        if BitL == "0" and BitR == "0" then Result = "0" .. Result end
        if BitL == "1" and BitR == "0" then Result = "1" .. Result end
        if BitL == "0" and BitR == "1" then Result = "1" .. Result end
        if BitL == "1" and BitR == "1" then Result = "0" .. Result end
    end

    return Result
end

local function Nor(Left, Right)
    local Result = ""

    local Length = #Left
    for i = Length, 1, -1 do
        local BitL = Left:sub(i, i)
        local BitR = Right:sub(i, i)
        if BitL == "0" and BitR == "0" then Result = "1" .. Result end
        if BitL == "1" and BitR == "0" then Result = "0" .. Result end
        if BitL == "0" and BitR == "1" then Result = "0" .. Result end
        if BitL == "1" and BitR == "1" then Result = "0" .. Result end
    end

    return Result
end

local function Nand(Left, Right)
    local Result = ""

    local Length = #Left
    for i = Length, 1, -1 do
        local BitL = Left:sub(i, i)
        local BitR = Right:sub(i, i)
        if BitL == "0" and BitR == "0" then Result = "1" .. Result end
        if BitL == "1" and BitR == "0" then Result = "1" .. Result end
        if BitL == "0" and BitR == "1" then Result = "1" .. Result end
        if BitL == "1" and BitR == "1" then Result = "0" .. Result end
    end

    return Result
end

local function Xnor(Left, Right)
    local Result = ""

    local Length = #Left
    for i = Length, 1, -1 do
        local BitL = Left:sub(i, i)
        local BitR = Right:sub(i, i)
        if BitL == "0" and BitR == "0" then Result = "1" .. Result end
        if BitL == "1" and BitR == "0" then Result = "0" .. Result end
        if BitL == "0" and BitR == "1" then Result = "0" .. Result end
        if BitL == "1" and BitR == "1" then Result = "1" .. Result end
    end

    return Result
end

local function ShiftLeft(Left)
    local Result = ""

    local Length = #Left
    for i = Length, 1, -1 do
        if i ~= 1 then
            local BitL = Left:sub(i, i)
            Result = BitL .. Result
        end
    end
    
    Result = Result .. "0"

    return Result
end

local function ShiftRight(Left)
    local Result = ""

    local Length = #Left
    for i = Length, 1, -1 do
        if i ~= Length then
            local BitL = Left:sub(i, i)
            Result = BitL .. Result
        end
    end
    
    Result = "0" .. Result

    return Result
end

function print_table(node)
    local cache, stack, output = {},{},{}
    local depth = 1
    local output_str = "{\n"

    while true do
        local size = 0
        for k,v in pairs(node) do
            size = size + 1
        end

        local cur_index = 1
        for k,v in pairs(node) do
            if (cache[node] == nil) or (cur_index >= cache[node]) then

                if (string.find(output_str,"}",output_str:len())) then
                    output_str = output_str .. ",\n"
                elseif not (string.find(output_str,"\n",output_str:len())) then
                    output_str = output_str .. "\n"
                end

                -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
                table.insert(output,output_str)
                output_str = ""

                local key
                if (type(k) == "number" or type(k) == "boolean") then
                    key = "["..tostring(k).."]"
                else
                    key = "['"..tostring(k).."']"
                end

                if (type(v) == "number" or type(v) == "boolean") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = "..tostring(v)
                elseif (type(v) == "table") then
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = {\n"
                    table.insert(stack,node)
                    table.insert(stack,v)
                    cache[node] = cur_index+1
                    break
                else
                    output_str = output_str .. string.rep('\t',depth) .. key .. " = '"..tostring(v).."'"
                end

                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                else
                    output_str = output_str .. ","
                end
            else
                -- close the table
                if (cur_index == size) then
                    output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
                end
            end

            cur_index = cur_index + 1
        end

        if (size == 0) then
            output_str = output_str .. "\n" .. string.rep('\t',depth-1) .. "}"
        end

        if (#stack > 0) then
            node = stack[#stack]
            stack[#stack] = nil
            depth = cache[node] == nil and depth + 1 or depth - 1
        else
            break
        end
    end

    -- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
    table.insert(output,output_str)
    output_str = table.concat(output)

    return output_str
end

local function EncodeBin(Bin) --// BinToHex
    Bin = tostring(Bin)
    if Bin == "0000" then return '0' end
    if Bin == "0001" then return '1' end
    if Bin == "0010" then return '2' end
    if Bin == "0011" then return '3' end
    if Bin == "0100" then return '4' end
    if Bin == "0101" then return '5' end
    if Bin == "0110" then return '6' end
    if Bin == "0111" then return '7' end
    if Bin == "1000" then return '8' end
    if Bin == "1001" then return '9' end
    if Bin == "1010" then return 'a' end
    if Bin == "1011" then return 'b' end
    if Bin == "1100" then return 'c' end
    if Bin == "1101" then return 'd' end
    if Bin == "1110" then return 'e' end
    if Bin == "1111" then return 'f' end
end

local function DecodeBin(Hex) --// HexToBin
    Hex = tostring(Hex)
    if Hex == '0' then return "0000" end
    if Hex == '1' then return "0001" end
    if Hex == '2' then return "0010" end
    if Hex == '3' then return "0011" end
    if Hex == '4' then return "0100" end
    if Hex == '5' then return "0101" end
    if Hex == '6' then return "0110" end
    if Hex == '7' then return "0111" end
    if Hex == '8' then return "1000" end
    if Hex == '9' then return "1001" end
    if Hex == 'a' then return "1010" end
    if Hex == 'b' then return "1011" end
    if Hex == 'c' then return "1100" end
    if Hex == 'd' then return "1101" end
    if Hex == 'e' then return "1110" end
    if Hex == 'f' then return "1111" end
end

local function DecToHex(Dec)
    Dec = tonumber(Dec)
    if Dec == 0 then return '0' end
    if Dec == 1 then return '1' end
    if Dec == 2 then return '2' end
    if Dec == 3 then return '3' end
    if Dec == 4 then return '4' end
    if Dec == 5 then return '5' end
    if Dec == 6 then return '6' end
    if Dec == 7 then return '7' end
    if Dec == 8 then return '8' end
    if Dec == 9 then return '9' end
    if Dec == 10 then return 'a' end
    if Dec == 11 then return 'b' end
    if Dec == 12 then return 'c' end
    if Dec == 13 then return 'd' end
    if Dec == 14 then return 'e' end
    if Dec == 15 then return 'f' end
end

local ColorClass = {}
ColorClass.__index = ColorClass

function ColorClass.new(R, G, B, A)
    local self = setmetatable({
        r = R or 0;
        g = G or 0;
        b = B or 0;
        a = A or 255;
    }, ColorClass)
    return self
end

local function HexToColor(Hex)
    Hex = tostring(Hex)
    if Hex == '0' then return ColorClass.new(255, 0, 0) end --// Red
    if Hex == '1' then return ColorClass.new(250, 181, 52) end --// Orange
    if Hex == '2' then return ColorClass.new(255, 255, 0) end --// Yellow
    if Hex == '3' then return ColorClass.new(0, 255, 0) end --// Lime
    if Hex == '4' then return ColorClass.new(39, 99, 42) end --// Green
    if Hex == '5' then return ColorClass.new(0, 255, 255) end --// Light Blue
    if Hex == '6' then return ColorClass.new(40, 166, 168) end --// Cyan
    if Hex == '7' then return ColorClass.new(40, 46, 168) end --// Blue
    if Hex == '8' then return ColorClass.new(255, 200, 255) end --// Pink
    if Hex == '9' then return ColorClass.new(210, 48, 242) end --// Magenta
    if Hex == 'a' then return ColorClass.new(87, 35, 97) end --// Purple
    if Hex == 'b' then return ColorClass.new(99, 70, 34) end --// Brown
    if Hex == 'c' then return ColorClass.new(255, 255, 255) end --// White
    if Hex == 'd' then return ColorClass.new(140, 140, 140) end --// Light Gray
    if Hex == 'e' then return ColorClass.new(71, 71, 71) end --// Gray
    if Hex == 'f' then return ColorClass.new(36, 36, 36) end --/ Black
end






--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 

local Bitwise = Or         --// Set this to your bitwise operation function

--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 










local function GetTable()
    local Table = {}
    local o = 0

    for i = 0, 15, 1 do
        local Row = {}

        local Dec = i
        local LeftHex = DecToHex(Dec)

        if ROW_CUT_REPEAT == false then o = 0 end
        for y = o, 15, 1 do
            local RightHex = DecToHex(y)

            local LeftBin = DecodeBin(LeftHex)
            local RightBin = DecodeBin(RightHex)
            local Result = Bitwise(LeftBin, RightBin)
            local HexResult = EncodeBin(Result)
            Row[#Row+1] = {LeftHex, RightHex, HexResult}
        end

        o = o + 1 --// Set Offset Start

        --// Set Row
        Table[i + 1] = Row
    end

    return Table
end

function love.load() end
function love.update(dt) if love.keyboard.isDown("escape") then love.event.quit() end end

local function DrawRect(x, y, Color)
    love.graphics.setColor(Color.r / 255, Color.g / 255, Color.b / 255, Color.a / 255)
    love.graphics.rectangle("fill", x, y, PIXEL_WIDTH, PIXEL_HEIGHT)
end

function love.draw()
    local HexTable = GetTable()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(print_table(HexTable))
    for i, row in ipairs(HexTable) do
        local x = ((i * PIXEL_WIDTH * 4) + PIXEL_WIDTH) + 15
        for j, Hex in ipairs(row) do
            local Y = (j * PIXEL_WIDTH) + 15
            for k = 1, ROWS, 1 do
                if k >= ROW_OFFSET then
                    local Value = Hex[k]
                    local X = x + (PIXEL_WIDTH * (k - 1))
                    DrawRect(X, Y, HexToColor(Value))
                end
            end
        end
    end
end