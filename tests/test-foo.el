
(describe "with-test-buffer macro"

  (it "inserts buffer contents and returns them"
    (expect (with-test-buffer "hello world|")
            :to-equal (list "hello world|")))

  (it "returns multiple lines as a list"
    (expect (with-test-buffer "hello\n|world")
            :to-equal (list "hello" "|world")))

  (it "allows calling code in the given buffer"
    (expect (with-test-buffer "hello\n|world"
              ;; move cursor to end of line
              (evil-append-line 1))
            :to-equal (list "hello" "world|"))))

(describe "when inside an expression, enter insert mode at start or end"
  (it "allows inserting at the start"
    (expect (with-test-buffer "(foo-foo-|foo)"
              (evil-lispy-enter-insert-state-left))
            :to-equal (list "(| foo-foo-foo)")))

  (it "allows inserting at the end"
    (expect (with-test-buffer "(foo-foo-|foo)"
              (evil-lispy-enter-insert-state-right))
            :to-equal (list "(foo-foo-foo |)"))))
