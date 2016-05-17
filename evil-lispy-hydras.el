(defhydra evil-lispy-hydra ()
  "
^Navigate^            ^Refactor^
^^^^^^^^---------------------------------
_h_: backward & up    _t_: teleport
_j_: next             _d_: drag
_k_: previous
_l_: forward & up
_o_: other side
_i_: in


"
  ("h" special-lispy-left)
  ("j" special-lispy-down)
  ("k" special-lispy-up)
  ("l" special-lispy-right)
  ("t" special-lispy-teleport)
  ("o" special-lispy-different)
  ("i" special-lispy-flow)
  ("d" special-lispy-other-mode))

;; testing
(evil-lispy-hydra/body)

(provide 'evil-lispy-hydras)
