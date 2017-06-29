;; ========================================================================================================
;; Kayhan Dehghani Mohammadi
;; 301243781
;; kdehghan@sfu.ca
;; Assignment 4
;; ========================================================================================================

(load "env1.scm")

;; ========================================================================================================
;; Main function: 
;; ========================================================================================================
(define myeval
    (lambda (expr env)
        (cond
            ((symbol? expr)    ;; find the value of expression in the environment
                (apply-env env expr)
            )
            ((number? expr)    ;; return the number itslef
                expr
            )
            ((is-add? expr)    ;; (e1 + e2)
                (+  (myeval (first expr) env) 
                    (myeval (third expr) env)
                )
            )
            ((is-sub? expr)    ;; (e1 - e2)
                (-  (myeval (first expr) env) 
                    (myeval (third expr) env)
                )
            )
            ((is-mul? expr)    ;; (e1 * e2)
                (*  (myeval (first expr) env) 
                    (myeval (third expr) env)
                )
            )
            ((is-pow? expr)    ;; (e1 * e2)
                (power  (myeval (first expr) env) 
                    (myeval (third expr) env)
                )
            )
            ((is-div? expr)    ;; (e1 / e2)
                (if (= 0 (myeval (third expr) env))
                    (error "my-eval: division by 0")    ;; division by zero
                    (/  (myeval (first expr) env)           ;; valid division
                        (myeval (third expr) env)
                    )
                )
                
            )
            ((is-inc? expr)    ;; (inc e)
                (+  1 
                    (myeval (second expr) env) 
                )
            )
            ((is-dec? expr)    ;; (dec e)
                (-   (myeval (second expr) env) 
                     1
                )
            )
            (else        ;; raise error if expression is invalid
                (error "my-eval: invalid expression")
            )
        )
    )
)
;; ========================================================================================================
;; Helper: returns true if the argument follows the following grammar:
;; expr =  "(" expr "+" expr ")"
;;         | "(" expr "-" expr ")"
;;         | "(" expr "*" expr ")"
;;         | "(" expr "/" expr ")"
;;         | "(" expr "**" expr ")"  ;; e.g. (2 ** 3) is 8, (3 ** 3) is 27
;;         | "(" "inc" expr ")"      ;; adds 1 to expr
;;         | "(" "dec" expr ")"      ;; subtracts 1 from expr
;;         | var
;;         | number
;; number = a Scheme number
;; var    = a Scheme symbol
;; ========================================================================================================
(define is-expr?
    (lambda (e)
        (cond
            ((or    (number? e)    ;; return true if e is number or symbol
                    (symbol? e))
                #t
            )
            ((is-add? e)        ;; (e1 + e2)
                (and
                    (is-expr? (first e))
                    (is-expr? (third e))
                )
            )
            ((is-sub? e)        ;; (e1 - e2)
                (and
                    (is-expr? (first e))
                    (is-expr? (third e))
                )
            )
            ((is-mul? e)        ;; (e1 * e2)
                (and
                    (is-expr? (first e))
                    (is-expr? (third e))
                )
            )
            ((is-div? e)        ;; (e1 / e2)
                (and
                    (is-expr? (first e))
                    (is-expr? (third e))
                )
            )
            ((is-pow? e)        ;; (e1 ** e2)
                (and
                    (is-expr? (first e))
                    (is-expr? (third e))
                )
            )
            ((is-inc? e)        ;; (inc e2)
                (is-expr? (second e))
            )
            ((is-dec? e)        ;; (dec e2)
                (is-expr? (second e))
            )
            (else
                #f)
        )
    )
) 
;; ========================================================================================================
;; Helper: returns true if the expression is of the form: "(" "inc" expr ")"         example: (inc e)
;; ========================================================================================================
(define is-inc?
    (lambda (e)
        (and 
            (nlist? 2 e)
            (equal? 'inc (car e))
        )
    )
) 
;; ========================================================================================================
;; Helper: returns true if the expression is of the form: "(" "dec" expr ")"         example: (dec e)
;; ========================================================================================================
(define is-dec?
    (lambda (e)
        (and 
            (nlist? 2 e)
            (equal? 'dec (car e))
        )
    )
) 
;; ========================================================================================================
;; Helper: returns true if the expression is of the form: "(" expr "+" expr ")"        example: (e1 + e2)
;; ========================================================================================================
(define is-add?
    (lambda (e)
        (and 
            (nlist? 3 e)
            (equal? '+ (second e))
        )
    )
) 
;; ========================================================================================================
;; Helper: returns true if the expression is of the form: "(" expr "-" expr ")"        example: (e1 - e2)
;; ========================================================================================================
(define is-sub?
    (lambda (e)
        (and 
            (nlist? 3 e)
            (equal? '- (second e))
        )
    )
) 
;; ========================================================================================================
;; Helper: returns true if the expression is of the form: "(" expr "*" expr ")"         example: (e1 * e2)
;; ========================================================================================================
(define is-mul?
    (lambda (e)
        (and 
            (nlist? 3 e)
            (equal? '* (second e))
        )
    )
) 
;; ========================================================================================================
;; Helper: returns true if the expression is of the form: "(" expr "/" expr ")"         example: (e1 / e2)
;; ========================================================================================================
(define is-div?
    (lambda (e)
        (and 
            (nlist? 3 e)
            (equal? '/ (second e))
        )
    )
) 
;; ========================================================================================================
;; Helper: returns true if the expression is of the form: "(" expr "**" expr ")"        example: (e1 ** e2)
;; ========================================================================================================
(define is-pow?
    (lambda (e)
        (and 
            (nlist? 3 e)
            (equal? '** (second e))
        )
    )
) 
;; ========================================================================================================
;; Helper: returns true if lst is a list with size n, else false
;; ========================================================================================================
(define nlist?
    (lambda (n lst)
        (and 
            (list? lst)
            (= n (length lst))
        )
    )
)

;; ========================================================================================================
;; Helper: returns x to the power of y. Assumes x and y are numbers
;; ========================================================================================================
(define power
    (lambda (x y)
        (cond
            ((= 0 y)    ;; 5**0=1 and 0**0=1 and (-5)**0=1
                1
            )
            ((positive? y)    ;; 2**3=2*2*2*1
                (* x (power x (- y 1)))
            )
            (else             ;; 2**(-3)=((1/2)/2)/2
                (/ (power x (+ y 1)) x)
            )
        )
    )
)
