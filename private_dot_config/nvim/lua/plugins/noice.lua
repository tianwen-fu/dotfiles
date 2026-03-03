return {
  "folke/noice.nvim",
  opts = {
    routes = {
      {
        filter = {
          event = "msg_show",
          kind = {
            "shell_out",
            "shell_err",
          },
        },
        view = "notify",
      },
    },
  },
}
