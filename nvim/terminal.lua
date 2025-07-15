if vim.fn.executable('nu') == 1 then
    local current_path = vim.fn.expand("<sfile>:p:h:h")
    local nushell_path = vim.fs.joinpath(current_path, "nushell")
    local nushell_config = vim.fs.joinpath(nushell_path, "config.nu")
    local nushell_env = vim.fs.joinpath(nushell_path, "env.nu")
    vim.o.shell = "nu --config " .. nushell_config .. " --env-config " .. nushell_env
end
