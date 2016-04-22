
(describe "with-test-buffer macro"
  (it "inserts buffer contents and returns them"
    (expect (with-test-buffer "hello world|")
            :to-have-buffer-contents "hello world|"))

  (it "returns multiple lines as a list"
    (expect (with-test-buffer "hello\n|world")
            :to-have-buffer-contents (list "hello"
                                           "|world")))

  (it "allows calling code in the given buffer"
    (expect (with-test-buffer "hello\n|world"
              ;; move cursor to end of line
              (evil-append-line 1))
            :to-have-buffer-contents (list "hello"
                                           "world|"))))

(describe "when inside an expression, enter insert mode at start or end"
  (it "allows inserting at the start"
    (expect (with-test-buffer "(foo-foo-|foo)"
              (evil-lispy-enter-insert-state-left))
            :to-have-buffer-contents "(| foo-foo-foo)"))

  (it "allows inserting at the end"
    (expect (with-test-buffer "(foo-foo-|foo)"
              (evil-lispy-enter-insert-state-right))
            :to-have-buffer-contents "(foo-foo-foo |)")))

(describe "entering lispy marked state"
  (it "selects a symbol"
    (expect (with-test-buffer "hello the|re, world"
              (evil-lispy-enter-marked-state))
            :to-have-buffer-contents "hello ~there|, world"))

  (it "selects an expression"
    (expect (with-test-buffer "(hello the|re world)"
              (evil-lispy-enter-marked-state))
            :to-have-buffer-contents "(hello ~there| world)"))

  (it "allows entering from evil-visual-state"
    (-doto (with-test-buffer "some words |in the buffer"
             ;; select the current word
             (evil-visual-state)
             (evil-inner-word)
             (evil-lispy-enter-visual-state))
           (expect :to-be-in-lispy-mode)
           (expect :to-have-buffer-contents "some words ~in| the buffer"))))

(describe "enter lispy-mode at edges of the current expression"
  (it "before an expression"
    (expect (with-test-buffer "(an expression| here)"
              (evil-lispy-enter-state-left))
            :to-have-buffer-contents "|(an expression here)"))

  (it "after an expression"
    (expect (with-test-buffer "(an expression| here)"
              (evil-lispy-enter-state-right))
            :to-have-buffer-contents "(an expression here)|")))

(describe "insert-mode -> evil-lispy-mode"
  (it "jumps out of the current sexp and enters evil-lispy-mode with )"
    (-doto (with-test-buffer "(expression| one)"
             (evil-insert-state)
             (ot--keyboard-input
              (ot--type ")")))
           (expect :to-be-in-lispy-mode)
           (expect :to-have-buffer-contents "(expression one)|")))

  (it "jumps to the left with ["
    (-doto (with-test-buffer "(hello| world)"
             (evil-insert-state)
             (ot--keyboard-input
              (ot--type "[")))
           (expect :to-be-in-lispy-mode)
           (expect :to-have-buffer-contents "|(hello world)")))

  (it "jumps to the right with ]"
    (-doto (with-test-buffer "(hello| world)"
             (evil-insert-state)
             (ot--keyboard-input
              (ot--type "]")))
           (expect :to-be-in-lispy-mode)
           (expect :to-have-buffer-contents "(hello world)|"))))

(describe "inserting plain text"
  (it "inserts characters without any specific bindings"
    (expect (with-test-buffer "|"
              (evil-lispy-enter-state-right)
              (ot--keyboard-input
               (ot--type "Y")))
            :to-have-buffer-contents "Y|")))

(describe "lispy interop"
  (it "allows repeating commands with a count, like evil/vim"
    (expect (with-test-buffer "(expression| one)\n(expression two)\n(expression three)"
              (ot--keyboard-input
               (ot--type ")2j")))
            :to-have-buffer-contents
            '("(expression one)"
              "(expression two)"
              "(expression three)|"))))
