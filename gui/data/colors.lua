local hex_colors =
{
    [1] =
    {
        menubar = "F3F3F3",
        background = "F9F9F9",
        shadow = "E5E5E5",
        textHint = "A2A2A2",
        text = "1B1B1B",
        unfocused = "868686",
        hover = "E6ECEB"
    },

    [2] =
    {
        menubar = "202020",
        background = "272727",
        shadow = "1D1D1D",
        textHint = "CFCFCF",
        text = "FFFFFF",
        unfocused = "9A9A9A",
        hover = "2B2E2D"
    },

    [3] =
    {
        accentColor = "0069BA"
    }
}

local function translate()
    local results = {}

    local lambda = function(str)
        local out = {}
        for index = 1, #str, 2 do
            table.insert(out,  tonumber(str:sub(index, index + 1), 16))
        end
        return { love.math.colorFromBytes(out) }
    end

    for theme, values in pairs(hex_colors) do
        results[theme] = {}
        for name, hex in pairs(values) do
            results[theme][name] = lambda(hex)
        end
    end

    for name, value in pairs(results[3]) do
        for theme, _ in pairs(results) do
            if theme ~= 3 then
                results[theme][name] = value
            end
        end
    end

    return results
end

return translate()
