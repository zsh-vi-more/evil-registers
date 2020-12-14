# {{{ set system clipboard
zmodload zsh/parameter

if (( $+commands[termux-clipboard-get] )); then
	zstyle :zle:evil-registers:handlers:'*' put  termux-clipboard-get
	zstyle :zle:evil-registers:handlers:'+' put  termux-clipboard-get
	zstyle :zle:evil-registers:handlers:'*' yank termux-clipboard-set
	zstyle :zle:evil-registers:handlers:'+' yank termux-clipboard-set
elif (( $+WAYLAND_DISPLAY & $+commands[wl-paste] )); then
	zstyle :zle:evil-registers:handlers:'*' put  wl-put -p -n
	zstyle :zle:evil-registers:handlers:'+' put  wl-put -n
	zstyle :zle:evil-registers:handlers:'*' yank wl-copy -p
	zstyle :zle:evil-registers:handlers:'+' yank wl-copy
elif (( $+DISPLAY & $+commands[xclip] )); then
	zstyle :zle:evil-registers:handlers:'*' put  xclip -out
	zstyle :zle:evil-registers:handlers:'+' put  xclip -selection clipboard -out
	zstyle :zle:evil-registers:handlers:'*' yank xclip
	zstyle :zle:evil-registers:handlers:'+' yank xclip -selection clipboard
elif (( $+DISPLAY & $+commands[xsel] )); then
	zstyle :zle:evil-registers:handlers:'*' put  xsel -o
	zstyle :zle:evil-registers:handlers:'+' put  xsel -b -o
	zstyle :zle:evil-registers:handlers:'*' yank xsel -i
	zstyle :zle:evil-registers:handlers:'+' yank xsel -b -i
fi
# }}}
# {{{ Handle fpath/$0
# ref: zdharma.org/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html#zero-handling
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
[[ $PMSPEC = *f* ]] || fpath+=("${0:h}/functions")
autoload -Uz .evil-registers::{track-insert,put,yank}
# }}}
# {{{ shadow vi-set-buffer
.evil-registers::vi-set-buffer(){
	typeset -g _evil_register
	read -k 1 _evil_register
	zle .vi-set-buffer "$_evil_register"
}
# }}}
(){ # {{{ register new widgets
	local w
	# TODO: best practice?
	# overwrite old widgets
	for w (
		vi-delete vi-delete-char vi-kill-line vi-kill-eol
		vi-change vi-change-eol vi-change-whole-line
		vi-yank vi-yank-whole-line vi-yank-eol
	); do
		zle -N "$w" ".evil-registers::yank"
	done
	for w (vi-put-after vi-put-before); do
		zle -N "$w" ".evil-registers::put"
	done
	zle -N vi-set-buffer .evil-registers::vi-set-buffer
} # }}}

# vim:foldmethod=marker
