local savedata = {}
savedata.FILE_PATH = "nestlink.json"

savedata.DEFAULTS = {
    ["theme"] = 1,
    ["hosts"] = {},
    ["port"] =  8000
}

local json = require("libraries.json")

local theme = require("gui.data.themes")

function savedata:load()
    if not love.filesystem.getInfo(savedata.FILE_PATH) then
        love.filesystem.write(savedata.FILE_PATH, json:encode_pretty(savedata.DEFAULTS))
    end
    self.data = json:decode(love.filesystem.read(savedata.FILE_PATH))

    theme:set(self.data.theme)
end

function savedata:get(name)
    assert:some(self.data, "this shouldn't happen")
    return assert:some(self.data[name], "tried to index '" .. name .. "' in data table")
end

function savedata:updateField(name, value, forceSaved)
    assert:some(self.data, "this shouldn't happen")
    assert:some(self.data[name], "tried to index '" .. name .. "' in data table")

    self.data[name] = value

    if forceSaved then
        self:encode()
    end
end

function savedata:addValueToField(name, value, forceSaved)
    assert:some(self.data, "this shouldn't happen")
    assert:type(self.data[name], "table", "field '" .. name .. "' is not a table")

    table.insert(self.data[name], value)

    if forceSaved then
        self:encode()
    end
end

function savedata:encode()
    love.filesystem.write(savedata.FILE_PATH, json:encode_pretty(self.data))
end

return savedata
