(require 'lispy)
(require 'hydra)

(defhydra evil-lispy-hydra ()
  "
evil-lispy basics

^Navigate^                 ^Refactor^               ^Evaluate^
^^^^^^^^-----------------------------------------------------------------------
_h_: backward & up         _t_: teleport            _e_: eval
_j_: next                  _d_: drag                _E_: eval and insert
_k_: previous              _c_: clone
_l_: forward & up          _w_: move up
_o_: other side            _s_: move down
_i_: inside                _r_: raise
_q_: jump to ()            _O_: to oneliner
_-_: go to subword         _M_: to multiline


"
  ("h" special-lispy-left)
  ("j" special-lispy-down)
  ("k" special-lispy-up)
  ("l" special-lispy-right)
  ("o" special-lispy-different)
  ("i" special-lispy-flow)
  ("q" special-lispy-ace-paren)
  ("-" special-lispy-ace-subword)

  ("c" special-lispy-clone)
  ("t" special-lispy-teleport)
  ("d" special-lispy-other-mode)
  ("w" special-lispy-move-up)
  ("s" special-lispy-move-down)
  ("r" special-lispy-raise)
  ("O" special-lispy-oneline)
  ("M" lispy-multiline)

  ("e" special-lispy-eval)
  ("E" special-lispy-eval-and-insert))

(defun evil-lispy-show-help ()
  (interactive)
  (evil-lispy-hydra/body))

(provide 'evil-lispy-help)
