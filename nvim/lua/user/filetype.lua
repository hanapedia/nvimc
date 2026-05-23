vim.cmd[[ 
if exists("did_load_filetypes")
	  finish
endif
augroup filetypedetect
  au! BufRead,BufNewFile main.yaml setfiletype yaml.ansible
  au! BufRead,BufNewFile main.yml setfiletype yaml.ansible
augroup END
]]
vim.g.do_filetype_lua = 1
vim.g.did_filetype_lua = 0
