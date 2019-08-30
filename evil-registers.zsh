# {{{ set system clipboard
zmodload zsh/parameter
declare -gA ZSH_EVIL_PASTE_HANDLERS
declare -gA ZSH_EVIL_COPY_HANDLERS
# "(e)*" to remove special meaning of "*"
if (( $+commands[termux-clipboard-get] )); then
	ZSH_EVIL_PASTE_HANDLERS[(e)*]="${ZSH_EVIL_PASTE_HANDLERS[(e)*]:-termux-clipboard-get}"
	ZSH_EVIL_PASTE_HANDLERS[+]="${ZSH_EVIL_PASTE_HANDLERS[+]:-termux-clipboard-get}"
	ZSH_EVIL_COPY_HANDLERS[(e)*]="${ZSH_EVIL_COPY_HANDLERS[(e)*]:-termux-clipboard-set}"
	ZSH_EVIL_COPY_HANDLERS[+]="${ZSH_EVIL_COPY_HANDLERS[+]:-termux-clipboard-set}"
elif (( $+WAYLAND_DISPLAY & $+commands[wl-paste] )); then
	ZSH_EVIL_PASTE_HANDLERS[(e)*]="${ZSH_EVIL_PASTE_HANDLERS[(e)*]:-wl-paste -p -n}"
	ZSH_EVIL_PASTE_HANDLERS[+]="${ZSH_EVIL_PASTE_HANDLERS[+]:-wl-paste -n}"
	ZSH_EVIL_COPY_HANDLERS[(e)*]="${ZSH_EVIL_COPY_HANDLERS[(e)*]:-wl-copy -p}"
	ZSH_EVIL_COPY_HANDLERS[+]="${ZSH_EVIL_COPY_HANDLERS[+]:-wl-copy}"
elif (( $+DISPLAY & $+commands[xclip] )); then
	ZSH_EVIL_PASTE_HANDLERS[(e)*]="${ZSH_EVIL_PASTE_HANDLERS[(e)*]:-xclip -out}"
	ZSH_EVIL_PASTE_HANDLERS[+]="${ZSH_EVIL_PASTE_HANDLERS[+]:-xclip -selection clipboard -out}"
	ZSH_EVIL_COPY_HANDLERS[(e)*]="${ZSH_EVIL_COPY_HANDLERS[(e)*]:-xclip}"
	ZSH_EVIL_COPY_HANDLERS[+]="${ZSH_EVIL_COPY_HANDLERS[+]:-xclip -selection clipboard}"
elif (( $+DISPLAY & $+commands[xsel] )); then
	ZSH_EVIL_PASTE_HANDLERS[(e)*]="${ZSH_EVIL_PASTE_HANDLERS[(e)*]:-xsel -o}"
	ZSH_EVIL_PASTE_HANDLERS[+]="${ZSH_EVIL_PASTE_HANDLERS[+]:-xsel -b -o}"
	ZSH_EVIL_COPY_HANDLERS[(e)*]="${ZSH_EVIL_COPY_HANDLERS[(e)*]:-xsel -i}"
	ZSH_EVIL_COPY_HANDLERS[+]="${ZSH_EVIL_COPY_HANDLERS[+]:-xsel -b -i}"
fi
(( ${#ZSH_EVIL_PASTE_HANDLERS} + ${#ZSH_EVIL_COPY_HANDLERS} )) || return
# }}}
# {{{ shadow all vi commands
fpath+="${0:h}"
autoload -Uz evil-register::paste evil-register::yank

.evil-register::vi-delete(){ evil-register::yank .vi-delete }

.evil-register::vi-delete-char(){ evil-register::yank .vi-delete-char }

.evil-register::vi-kill-line(){ evil-register::yank .vi-kill-line }

.evil-register::vi-kill-eol(){ evil-register::yank .vi-kill-eol }

.evil-register::vi-change(){ evil-register::yank .vi-change }

.evil-register::vi-change-eol(){ evil-register::yank .vi-change-eol }

.evil-register::vi-change-whole-line(){ evil-register::yank .vi-change-whole-line }

.evil-register::vi-yank(){ evil-register::yank .vi-yank }

.evil-register::vi-yank-whole-line(){ evil-register::yank .vi-yank-whole-line }

.evil-register::vi-yank-eol(){ evil-register::yank .vi-yank-eol }

.evil-register::vi-put-after(){ evil-register::paste .vi-put-after }

.evil-register::vi-put-before(){ evil-register::paste .vi-put-before }
# }}}
# {{{ shadow vi-set-buffer
-evil-vi-set-buffer(){
	read -k 1
	_evil_register="$REPLY"
	zle .vi-set-buffer "$REPLY"
}
# }}}
# {{{ register new widgets
for w in vi-delete vi-delete-char vi-kill-line vi-kill-eol \
	vi-change vi-change-eol vi-change-whole-line \
	vi-yank vi-yank-whole-line vi-yank-eol \
	vi-put-after vi-put-before vi-set-buffer
do
	# TODO: best practice?
	# overwrite old widgets
	zle -N "$w" ".evil-register::${w}"
done
# }}}
# vim:foldmethod=marker
