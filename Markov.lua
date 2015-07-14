math.randomseed(os.time())
local random, insert = math.random, table.insert

local Markov = {}

Markov.NO_WORD = "\n"
Markov.chain_source = {}

--setmetatable(Markov, {__call = function() return "something" end})
-- then make each function of Markov check for a self argument?

-- Returns iterator for processing text into individual words.
function Markov.words(text)
    local position = 1
    return function()
        while position < text:len()-1 do
            local wordStart, wordEnd = text:find("%S+", position)
            if wordStart then
                position = wordEnd + 1
                return text:sub(wordStart, wordEnd)
            end
        end
        return nil
    end
end

-- Adds the next_word that follows a key_word to chain_source.
function Markov.add(key_word, next_word)
    --TODO if self then use self, else set self = Markov and use self ??
    if not Markov.chain_source[key_word] then
        Markov.chain_source[key_word] = {}
    end
    insert(Markov.chain_source[key_word], next_word)
end

-- Turns a source text into chain_source to generate random text from.
function Markov.process_corpus(text)
    --TODO make sure backslashes are escaped properly
         --(they are only escaped on quotes right now)
    --TODO multiple paragraphs (or just any \n's ?) need to have their starting key be \n AND the last word of whatever preceeded them
    Markov.chain_source = {}        --clear the old chain_source if needed
    local key = Markov.NO_WORD      --always starting from nothing
    for word in Markov.words(text) do
        Markov.add(key, word)
        key = word
    end
    Markov.add(key, Markov.NO_WORD) --always ending at nothing
end

--TODO function add_corpus(text)
--      will add more text without erasing corpus

-- Generate up to maxWords words of semi-sensible text!
-- Assumes a source text has already been processed with Markov.process_corpus(text)
-- TODO find out why this sometimes returns an empty string or " "
function Markov.generate_text(maxWords)
    local key = Markov.NO_WORD      --always start at nothing
    local result = ""
    for i=1,maxWords do
        local array = Markov.chain_source[key]
        local word = array[random(#array)]
        if word == Markov.NO_WORD then
            if result == " " or result == "" then return Markov.generate_text(maxWords) end
            return result:sub(1,-2) --end if we have reached a NO_WORD
        end
        result = result .. word .. " "
        key = word
    end
    return result:sub(1,-2)
end

-- Generate up to maxWords from a specified text, without interfering with anything else.
function Markov.generate_from(text, maxWords)
    local tmp = Markov.chain_source
    Markov.process_corpus(text)
    local result = Markov.generate_text(maxWords)
    Markov.chain_source = tmp
    return result
end

-- dump_chain_source puts the chain_source into a file
   -- (find a simple way of doing this without requiring a library)

return Markov
