# {{{ set system clipboard
zmodload zsh/parameter

if (( $+commands[termux-clipboard-get] )); then
	zstyle :zle:evil-registers:'[*+]' put  termux-clipboard-get
	zstyle :zle:evil-registers:'[*+]' yank termux-clipboard-set
elif (( $+WAYLAND_DISPLAY & $+commands[wl-paste] )); then
	zstyle :zle:evil-registers:'\*' put  wl-paste -p -n
	zstyle :zle:evil-registers:'+'  put  wl-paste -n
	zstyle :zle:evil-registers:'\*' yank wl-copy -p
	zstyle :zle:evil-registers:'+'  yank wl-copy
elif (( $+DISPLAY & $+commands[xclip] )); then
	zstyle :zle:evil-registers:'\*' put  xclip -out
	zstyle :zle:evil-registers:'+'  put  xclip -selection clipboard -out
	zstyle :zle:evil-registers:'\*' yank xclip
	zstyle :zle:evil-registers:'+'  yank xclip -selection clipboard
elif (( $+DISPLAY & $+commands[xsel] )); then
	zstyle :zle:evil-registers:'\*' put  xsel -o
	zstyle :zle:evil-registers:'+'  put  xsel -b -o
	zstyle :zle:evil-registers:'\*' yank xsel -i
	zstyle :zle:evil-registers:'+'  yank xsel -b -i
elif (( $+commands[base64] )); then
	.evil-registers::osc52-yank(){
		printf ${TMUX+'\ePtmux;\e'}'\e]52;'"$1;$(base64 <<< $3)"\\a${TMUX+'\e\'}
	}
	.evil-registers::osc52-put()(
		local REPLY
		(
			STTY=-echo
			printf ${TMUX+'\ePtmux;\e'}'\e]52;'"$1"';?;\a'${TMUX+'\e\'}
			STTY=echo
		) &
		read -rs -d$'\a' REPLY
		base64 -d <<< ${REPLY##*;}
	)
	zstyle :zle:evil-registers:'\*' yanka .evil-registers::osc52-yank p
	zstyle :zle:evil-registers:'+'  yanka .evil-registers::osc52-yank c
	zstyle :zle:evil-registers:'\*' puta  .evil-registers::osc52-put  p
	zstyle :zle:evil-registers:'+'  puta  .evil-registers::osc52-put  c
fi
# other defaults:
# readonly registers "/ and ".
zstyle :zle:evil-registers:/ putv LASTSEARCH
zstyle :zle:evil-registers:. putv __last_insert
# }}}
# {{{ Handle fpath/$0
# ref: zdharma.org/Zsh-100-Commits-Club/Zsh-Plugin-Standard.html#zero-handling
0="${${ZERO:-${0:#$ZSH_ARGZERO}}:-${(%):-%N}}"
0="${${(M)0:#/*}:-$PWD/$0}"
[[ $PMSPEC = *f* ]] || fpath+=("${0:h}/functions")
autoload -Uz .evil-registers::{track-insert,put,yank,setup-editor} add-zle-hook-widget
add-zle-hook-widget zle-keymap-select .evil-registers::track-insert
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
