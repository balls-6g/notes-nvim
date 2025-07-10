-- fields: file_ext, auto_save, namespace
local settings = {} -- settings

local M = {}

local errno = true

function M.setup(user_settings)
	settings = user_settings or {}

	if settings.namespace == nil then
		vim.notify("Namespace is not set", vim.log.levels.ERROR)
		-- panic
		errno = false
		return
	end
end

-- ---------- Funcs & todos ---------- --
if errno == true then
	local proj_dir = vim.fn.getcwd()
	local current_note = nil
	local loaded_notes = {}
	local pub_current_note = nil
	local pub_loaded_notes = {}

	local function open_floating_note(opts, buf)
		opts = opts or {}
		local width = opts.width or math.floor(vim.o.columns * 0.8)
		local height = opts.width or math.floor(vim.o.lines * 0.8)

		-- calculate center
		local col = math.floor((vim.o.columns - width) / 2)
		local row = math.floor((vim.o.lines - height) / 2)

		local win_config = {
			relative = "editor",
			width = width,
			height = height,
			col = col,
			row = row,
			style = "minimal",
			border = "rounded",
		}

		local win = vim.api.nvim_open_win(buf, true, win_config)
		return { floating = { win = win, buf = buf } }
	end

	local function notes_open_latest()
		if current_note == nil then
			vim.notify("Can not open latest note, no note is loaded")
		else
			open_floating_note({}, loaded_notes[current_note].floating.buf)
		end
	end

	local function pub_notes_open_latest()
		if pub_current_note == nil then
			vim.notify("Can not open latest public note, no note is loaded")
		else
			open_floating_note({}, pub_loaded_notes[pub_current_note].floating.buf)
		end
	end

	local function notes_new()
		local name = vim.fn.input("Enter note name")
		if name == nil or name == "" then
			vim.notify("Name is empty, cannot create new note", vim.log.levels.ERROR)
			return
		end
		current_note = name

		local buf = nil
		if
			vim.fn.filereadable(
				proj_dir .. "/notes/" .. settings.namespace .. "/" .. name .. "." .. (settings.file_ext or "norg")
			)
		then
			vim.notify("File already exist, openning....", vim.log.levels.WARN)
			buf = vim.fn.bufadd(
				proj_dir .. "/notes/" .. settings.namespace .. "/" .. name .. "." .. (settings.file_ext or "norg")
			)
		else
			buf = vim.api.nvim_create_buf(false, true)
		end
		loaded_notes[current_note] = open_floating_note({}, buf)
		if vim.bo[loaded_notes[current_note].floating.buf].filetype ~= (settings.file_ext or "norg") then
			vim.bo[loaded_notes[current_note].floating.buf].filetype = (settings.file_ext or "norg")
		end
		vim.cmd(
			"silent write! "
				.. vim.fn.fnameescape(
					proj_dir
						.. "/notes/"
						.. settings.namespace
						.. "/"
						.. current_note
						.. "."
						.. (settings.file_ext or "norg")
				)
		)
	end

	local function pub_notes_new()
		local name = vim.fn.input("Enter note name")
		if name == nil or name == "" then
			vim.notify("Name is empty, cannot create new note", vim.log.levels.ERROR)
			return
		end
		pub_current_note = name

		local buf = nil
		if
			vim.fn.filereadable(
				proj_dir .. "/notes/" .. "public" .. "/" .. name .. "." .. (settings.file_ext or "norg")
			)
		then
			vim.notify("File already exist, openning....", vim.log.levels.WARN)
			buf =
				vim.fn.bufadd(proj_dir .. "/notes/" .. "public" .. "/" .. name .. "." .. (settings.file_ext or "norg"))
		else
			buf = vim.api.nvim_create_buf(false, true)
		end
		pub_loaded_notes[pub_current_note] = open_floating_note({}, buf)
		if vim.bo[pub_loaded_notes[pub_current_note].floating.buf].filetype ~= (settings.file_ext or "norg") then
			vim.bo[pub_loaded_notes[pub_current_note].floating.buf].filetype = (settings.file_ext or "norg")
		end
		vim.cmd(
			"silent write! "
				.. vim.fn.fnameescape(
					proj_dir .. "/notes/" .. "public" .. "/" .. current_note .. "." .. (settings.file_ext or "norg")
				)
		)
	end

	local function notes_save()
		if current_note == nil then
			vim.notify("Invalid buffer to save!", vim.log.levels.ERROR)
			return
		elseif not vim.api.nvim_win_is_valid(loaded_notes[current_note].floating.win) then
			vim.notify("Windows hided, unable to save", vim.log.levels.WARN)
		else
			vim.cmd(
				"silent write! "
					.. vim.fn.fnameescape(
						proj_dir
							.. "/notes/"
							.. settings.namespace
							.. "/"
							.. current_note
							.. "."
							.. (settings.file_ext or "norg")
					)
			)
			vim.notify(
				"Saved to "
					.. proj_dir
					.. "/notes/"
					.. settings.namespace
					.. "/"
					.. current_note
					.. "."
					.. (settings.file_ext or "norg")
			)
		end
	end

	local function pub_notes_save()
		if pub_current_note == nil then
			vim.notify("Invalid buffer to save!", vim.log.levels.ERROR)
			return
		elseif not vim.api.nvim_win_is_valid(pub_loaded_notes[pub_current_note].floating.win) then
			vim.notify("Windows hided, unable to save", vim.log.levels.WARN)
		else
			vim.cmd(
				"silent write! "
					.. vim.fn.fnameescape(
						proj_dir
							.. "/notes/"
							.. "public"
							.. "/"
							.. pub_current_note
							.. "."
							.. (settings.file_ext or "norg")
					)
			)
			vim.notify(
				"Saved to "
					.. proj_dir
					.. "/notes/"
					.. "public"
					.. "/"
					.. pub_current_note
					.. "."
					.. (settings.file_ext or "norg")
			)
		end
	end

	local function notes_open()
		local name = vim.fn.input("Enter note name:")
		if name == nil or name == "" then
			vim.notify("Unable to open note, name is empty")
			return
		end
		local buf = nil
		if
			vim.fn.filereadable(
				proj_dir .. "/notes/" .. settings.namespace .. "/" .. name .. "." .. (settings.file_ext or "norg")
			)
		then
			buf = vim.fn.bufadd(
				proj_dir .. "/notes/" .. settings.namespace .. "/" .. name .. "." .. (settings.file_ext or "norg")
			)
			open_floating_note({}, buf)
		else
			vim.notify("Unable to open note, note `" .. name .. "` is not exist", vim.log.levels.ERROR)
		end
	end

	local function pub_notes_open()
		local name = vim.fn.input("Enter note name:")
		if name == nil or name == "" then
			vim.notify("Unable to open note, name is empty")
			return
		end
		local buf = nil
		if
			vim.fn.filereadable(
				proj_dir .. "/notes/" .. "public" .. "/" .. name .. "." .. (settings.file_ext or "norg")
			)
		then
			buf =
				vim.fn.bufadd(proj_dir .. "/notes/" .. "public" .. "/" .. name .. "." .. (settings.file_ext or "norg"))
			open_floating_note({}, buf)
		else
			vim.notify("Unable to open note, note `" .. name .. "` is not exist", vim.log.levels.ERROR)
		end
	end

	local function notes_fzf()
		local ok, fl = pcall(require, "fzf-lua")
		if ok then
			fl.files({
				prompt = "Notes >",
				cwd = proj_dir .. "/notes" .. "/" .. settings.namespace,
				cmd = "fd . -e " .. (settings.file_ext or "norg"),
				file_icons = false,
				actions = {
					["default"] = function(selected)
						local full = selected[1]
						local name = full:gsub("%." .. (settings.file_ext or "norg") .. "$", "")
						current_note = name
						local buf = vim.fn.bufadd(proj_dir .. "/notes/" .. settings.namespace .. "/" .. full)
						loaded_notes[current_note] = open_floating_note({}, buf)
					end,
				},
			})
		else
			vim.notify("FzfLua not found!", vim.log.levels.ERROR)
		end
	end

	local function pub_notes_fzf()
		local ok, fl = pcall(require, "fzf-lua")
		if ok then
			fl.files({
				prompt = "Notes >",
				cwd = proj_dir .. "/notes" .. "/public",
				cmd = "fd . -e " .. (settings.file_ext or "norg"),
				file_icons = false,
				actions = {
					["default"] = function(selected)
						local full = selected[1]
						local name = full:gsub("%." .. (settings.file_ext or "norg") .. "$", "")
						pub_current_note = name
						local buf = vim.fn.bufadd(proj_dir .. "/notes/" .. "public" .. "/" .. full)
						pub_loaded_notes[pub_current_note] = open_floating_note({}, buf)
					end,
				},
			})
		else
			vim.notify("FzfLua not found!", vim.log.levels.ERROR)
		end
	end

	vim.api.nvim_create_user_command("Notes", function(opts)
		local actions = opts.args

		if actions == "new" then
			notes_new()
		elseif actions == "save" then
			notes_save()
		elseif actions == "open" then
			notes_open()
		elseif actions == "open-latest" then
			notes_open_latest()
		elseif actions == "fzf" then
			notes_fzf()
		elseif actions == "pub-new" then
			pub_notes_new()
		elseif actions == "pub-save" then
			pub_notes_save()
		elseif actions == "pub-open" then
			pub_notes_open()
		elseif actions == "pub-open-latest" then
			pub_notes_open_latest()
		elseif actions == "pub-fzf" then
			pub_notes_fzf()
		else
			vim.notify("Unknown subcommand: " .. actions, vim.log.levels.ERROR)
		end
	end, {
		nargs = 1,
		complete = function()
			return {
				"new",
				"save",
				"open",
				"open-latest",
				"fzf",
				"pub-new",
				"pub-save",
				"pub-open",
				"pub-open-latest",
				"pub-fzf",
			}
		end,
	})

	if settings.auto_save or true then
		vim.api.nvim_create_autocmd("BufLeave", {
			callback = function(args)
				for name, note in pairs(loaded_notes) do
					if args.buf == note.floating.buf then
						vim.cmd(
							"silent write! "
								.. vim.fn.fnameescape(
									proj_dir .. "/notes/" .. name .. "." .. (settings.file_ext or "norg")
								)
						)
					end
				end
			end,
		})
	end
end

-- ---------- End ---------- --
return M
