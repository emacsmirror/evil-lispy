
(describe "with-test-buffer macro"
  (it "inserts buffer contents and returns them"
    (expect (with-test-buffer "hello world|")
            :to-have-buffer-contents "hello world|"))

  (it "returns multiple lines as a list"
    (expect (with-test-buffer (list "hello"
                                    "|world"))
            :to-have-buffer-contents (list "hello"
                                           "|world")))

  (it "allows calling code in the given buffer"
    (expect (with-test-buffer (list "hello"
                                    "|world")
              ;; move cursor to end of line
              (evil-append-line 1))
            :to-have-buffer-contents (list "hello"
                                           "world|")))

  (it "allows inserting multiple lines in a list"
    (expect (with-test-buffer
                (list "hello" "|world"))
            :to-have-buffer-contents (list "hello"
                                           "|world"))))

(describe "when inside an expression, enter insert mode at start or end"
  (it "allows inserting at the start"
    (expect (with-test-buffer "(foo-foo-|foo)"
              (ot--keyboard-input
               (ot--type "<i")))
            :to-have-buffer-contents "(| foo-foo-foo)"))

  (it "allows inserting at the end"
    (expect (with-test-buffer "(foo-foo-|foo)"
              (ot--keyboard-input
               (ot--type ">A")))
            :to-have-buffer-contents "(foo-foo-foo |)")))

(describe "entering lispy marked state"
  (it "selects a symbol"
    (-doto (with-test-buffer "hello the|re, world"
             (ot--keyboard-input
              (ot--press-key "C-SPC")))
      (expect :to-have-buffer-contents "hello ~there|, world")
      (expect :to-be-in-lispy-mode)))

  (it "selects an expression"
    (-doto (with-test-buffer "(hello the|re world)"
             (ot--keyboard-input
              (ot--press-key "C-SPC")))
      (expect :to-have-buffer-contents "(hello ~there| world)")
      (expect :to-be-in-lispy-mode)))

  (it "allows entering from evil-visual-state"
    (-doto (with-test-buffer "some words |in the buffer"
             (ot--keyboard-input
              ;; select the current word
              (ot--type "viw")
              (ot--press-key "RET")))
      (expect :to-have-buffer-contents "some words ~in| the buffer")
      (expect :to-be-in-lispy-mode)))

  (it "allows using evil-mode marks normally"
    ;; we used to have a binding for mv (mark current thing).
    ;; this caused all evil-mode marks to be unusable.
    (-doto (with-test-buffer (list "line one"
                                   "line |two")
             (ot--keyboard-input
              ;; set an evil-mode mark named a at point
              (ot--type "ma")
              ;; move to the beginning and jump back to that mark.
              ;;
              ;; note that this actually jumps to the beginning of the marked
              ;; line
              (ot--type "gg'a")
              (evil-normal-state 1)))
      ;; strangely enough it seems an evil-mode mark is the same as having a
      ;; visual selection.
      ;; It's not that important for this test though, so tolerate this error
      ;; here.
      (expect :to-have-buffer-contents (list "line one"
                                             "|line~ two")))))

(describe "enter lispy-mode at edges of the current expression"
  (it "before an expression"
    (expect (with-test-buffer "(an expression| here)"
              (ot--keyboard-input
               (ot--type "(")))
            :to-have-buffer-contents "|(an expression here)"))

  (it "after an expression"
    (expect (with-test-buffer "(an expression| here)"
              (ot--keyboard-input
               (ot--type ")")))
            :to-have-buffer-contents "(an expression here)|")))

(describe "insert-mode -> evil-lispy-mode"
  (it "jumps out of the current sexp and enters evil-lispy-mode with )"
    (-doto (with-test-buffer "(expression| one)"
             (evil-insert-state)
             (ot--keyboard-input
              (ot--type ")")))
      (expect :to-have-buffer-contents "(expression one)|")
      (expect :to-be-in-lispy-mode)))

  (it "jumps to the left with ["
    (-doto (with-test-buffer "(hello| world)"
             (evil-insert-state)
             (ot--keyboard-input
              (ot--type "[")))
      (expect :to-have-buffer-contents "|(hello world)")
      (expect :to-be-in-lispy-mode)))

  (it "jumps to the right with ]"
    (-doto (with-test-buffer "(hello| world)"
             (evil-insert-state)
             (ot--keyboard-input
              (ot--type "]")))
      (expect :to-have-buffer-contents "(hello world)|")
      (expect :to-be-in-lispy-mode))))

(describe "inserting plain text"
  (it "inserts characters without any specific bindings"
    (expect (with-test-buffer "|"
              (evil-lispy/enter-state-right)
              (ot--keyboard-input
               (ot--type "Y")))
            :to-have-buffer-contents "Y|")))

(describe "lispy interop"
  (it "allows repeating commands with a count, like evil/vim"
    (-doto (with-test-buffer (list "(expression| one)"
                                   "(expression two)"
                                   "(expression three)")
             (ot--keyboard-input
              (ot--type ")2j")))
      (expect :to-have-buffer-contents '("(expression one)"
                                         "(expression two)"
                                         "(expression three)|"))
      (expect :to-be-in-lispy-mode))))
