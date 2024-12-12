local M = {}

local yop = require("yop")

local miniclue = nil
local has_clue = false

local function set_mapping_for_miniclue(mode, lhs, desc)
    if miniclue ~= nil then
	    if desc ~= nil then
		if mode[1] ~= nil then
		    for _, v in ipairs(mode) do
			miniclue.set_mapping_desc(v, lhs, desc)
		    end
		else
		    miniclue.set_mapping_desc(mode, lhs, desc)
		end
	    end
    end
end

local looking_for_replace = false
local first_position = nil
local second_position = nil

local function set_visual_selection(start_row, start_col, end_row, end_col)
    -- Adjust row and column for 0-based indexing in Lua and 1-based indexing in Neovim API
    start_row, start_col = start_row - 1, start_col - 1
    end_row, end_col = end_row - 1, end_col - 1
    -- Move the cursor to the starting position
    vim.api.nvim_win_set_cursor(0, {start_row + 1, start_col})
    -- Enter visual mode
    vim.cmd("normal! v")
    -- Move the cursor to the end position to extend the selection
    vim.api.nvim_win_set_cursor(0, {end_row + 1, end_col})
end

local namespace_id = vim.api.nvim_create_namespace("temporary_highlight")

local function enable_highlight(bufnr, start_line, start_col, end_line, end_col, highlight_group, type)
    start_line,start_col=start_line-1,start_col-1
    if type == "char" then
        end_line = end_line - 1
        vim.api.nvim_buf_set_extmark(bufnr, namespace_id, start_line, start_col, {
            end_line = end_line,
            end_col = end_col,
            hl_group = highlight_group,
            hl_eol = true,
        })
    else
        vim.api.nvim_buf_set_extmark(bufnr, namespace_id, start_line, start_col, {
            end_line = end_line,
            hl_group = highlight_group,
            hl_eol = true,
        })
    end
end

local function disable_highlight(bufnr)
    if namespace_id ~= nil then
        vim.api.nvim_buf_clear_namespace(bufnr, namespace_id, 0, -1)
    end
end

local function do_mapping(mapping_table, default_mapping, func, default_description)
    if mapping_table ~= nil then
        local mode = mapping_table.mode or {"n","v"}
        local prefix = mapping_table.prefix or default_mapping
        yop.op_map(
            mode,
            prefix,
            func
        )
        if has_clue then
            set_mapping_for_miniclue(mode, prefix, mapping_table.desc or default_description)
        end
    end
end

function M.setup(config)

    if config.miniclue then
        miniclue = require("mini.clue")
        has_clue = true
    end

    if config.global_replace ~= nil then
        local global_replace = config.global_replace
        do_mapping(
            global_replace,
            "<leader>gr",
            function (lines, _)
                local re_string = ""
                for index, value in ipairs(lines) do
                    re_string = re_string .. value
                end
                local command_string = ":%s/" .. re_string .. "//gcI<Left><Left><Left><Left>"
                local keys = vim.api.nvim_replace_termcodes(command_string, true, false, true)
                vim.api.nvim_feedkeys(keys, "n", false)
            end,
            "Global Replace"
        )
    end

    if config.local_replace ~= nil then
        local local_replace = config.local_replace
        do_mapping(
            local_replace,
            "<leader>lr",
            function (lines, info)
                if looking_for_replace then
                    looking_for_replace = false
                    disable_highlight(0)
                    set_visual_selection(first_position[1],first_position[2],second_position[1],second_position[2])
                    local re_string = ""
                    for index, value in ipairs(lines) do
                        re_string = re_string .. value
                    end
                    local command_string = ":s/" .. re_string .. "//gcI<Left><Left><Left><Left>"
                    local keys = vim.api.nvim_replace_termcodes(command_string, true, false, true)
                    vim.api.nvim_feedkeys(keys, "n", false)
                else
                    looking_for_replace = true
                    first_position = info.position.first
                    second_position = info.position.last
                    enable_highlight(0,first_position[1],first_position[2],second_position[1],second_position[2],"Visual",info.type)
                end
            end,
            "Local Replace"
        )
        if local_replace.clear_mapping ~= nil then
            vim.keymap.set(
                {"n","v"},
                local_replace.clear_mapping,
                function()
                    if looking_for_replace then
                        looking_for_replace = false
                        first_position = nil
                        second_position = nil
                        disable_highlight(0)
                    end
                end,
                { noremap = true, silent = true }
            )
	set_mapping_for_miniclue({"n","v"},local_replace.clear_mapping,"Clear Local Replace")
        end
    end

end



return M
