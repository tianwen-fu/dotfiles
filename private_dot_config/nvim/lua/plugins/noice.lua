return {
  "folke/noice.nvim",
  opts = {
    routes = {
      {
        -- silence the command echo
        filter = {
          event = "msg_show",
          find = "^:!",
        },
        opts = {
          skip = true,
        },
      },
      {
        filter = {
          event = "msg_show",
          kind = {
            "shell_out",
            "shell_err",
          },
        },
        view = "split",
        opts = {
          enter = false,
          size = 10,
          position = "bottom",
          -- Press Ctrl+[h, j, k, l] to navigate the windows
          -- Press q in the command window to close it
        },
      },
    },
  },
  config = function(_, opts)
    -- This part runs the setup using the opts above
    require("noice").setup(opts)

    -- ADD THE AUTOCMD HERE (Inside the config function)
    -- 3. THE DEBOUNCED AUTO-SCROLL
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "noice",
      callback = function(args)
        local buf = args.buf

        -- THE SAFETY GUARD: If this isn't a read-only scratch buffer, abort!
        if vim.api.nvim_get_option_value("buftype", { buf = buf }) ~= "nofile" then
          return
        end

        local timer = nil

        -- Attach a listener to the buffer
        vim.api.nvim_buf_attach(buf, false, {
          on_lines = function()
            -- If the timer is already running (meaning text is still streaming), cancel it
            if timer then
              timer:stop()
              timer:close()
            end

            -- Start a new timer.
            -- This code ONLY runs once the text has stopped changing for 100ms.
            timer = vim.defer_fn(function()
              timer = nil -- Reset the timer variable

              -- Safety check: ensure buffer and window still exist
              if not vim.api.nvim_buf_is_valid(buf) then
                return
              end
              local win = vim.fn.bufwinid(buf)

              if win ~= -1 then
                local line_count = vim.api.nvim_buf_line_count(buf)
                -- We get the last laugh: forcefully scroll to the bottom
                pcall(vim.api.nvim_win_set_cursor, win, { line_count, 0 })
              end
            end, 50) -- 100ms delay. Bump to 200 if Noice is still winning!
          end,
        })
      end,
    })
  end,
}
