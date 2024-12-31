;; crowdfunding.clar

;; Constants
(define-constant contract-owner tx-sender)
(define-constant minimum-funding u1000000) ;; 1 STX = 1,000,000 microSTX
(define-constant campaign-duration u43200) ;; Approximately 30 days in blocks

;; Error constants
(define-constant ERR-BELOW-MINIMUM (err u1))
(define-constant ERR-CAMPAIGN-NOT-FOUND (err u2))
(define-constant ERR-CAMPAIGN-ENDED (err u3))
(define-constant ERR-FUNDS-CLAIMED (err u4))
(define-constant ERR-NOT-OWNER (err u5))
(define-constant ERR-GOAL-NOT-REACHED (err u6))
(define-constant ERR-CAMPAIGN-NOT-ENDED (err u7))
(define-constant ERR-ALREADY-CLAIMED (err u8))

;; Data variables
(define-data-var total-campaigns uint u0)

;; Data maps for storing campaign information
(define-map campaigns
    uint  ;; campaign ID
    {
        owner: principal,
        title: (string-utf8 100),
        description: (string-utf8 500),
        goal: uint,
        raised: uint,
        end-block: uint,
        claimed: bool
    }
)

;; Map to track contributions
(define-map contributions
    {campaign-id: uint, contributor: principal}
    uint
)

;; Public functions

;; Create a new campaign
(define-public (create-campaign (title (string-utf8 100)) 
                              (description (string-utf8 500)) 
                              (goal uint))
    (let
        (
            (campaign-id (var-get total-campaigns))
            (end-block (+ stacks-block-height campaign-duration))
        )
        ;; Verify goal amount meets minimum
        (asserts! (>= goal minimum-funding) ERR-BELOW-MINIMUM)
        
        ;; Store campaign data
        (map-set campaigns campaign-id
            {
                owner: tx-sender,
                title: title,
                description: description,
                goal: goal,
                raised: u0,
                end-block: end-block,
                claimed: false
            }
        )
        
        ;; Increment total campaigns
        (var-set total-campaigns (+ campaign-id u1))
        (ok campaign-id)
    )
)

;; Contribute to a campaign
(define-public (contribute (campaign-id uint))
    (let
        (
            (campaign (unwrap! (map-get? campaigns campaign-id) ERR-CAMPAIGN-NOT-FOUND))
            (amount (stx-get-balance tx-sender))
            (current-contribution (default-to u0 
                (map-get? contributions {campaign-id: campaign-id, contributor: tx-sender})))
        )
        ;; Verify campaign is still active
        (asserts! (< stacks-block-height (get end-block campaign)) ERR-CAMPAIGN-ENDED)
        (asserts! (not (get claimed campaign)) ERR-FUNDS-CLAIMED)
        
        ;; Transfer STX
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        ;; Update campaign data
        (map-set campaigns campaign-id
            (merge campaign {raised: (+ (get raised campaign) amount)}))
            
        ;; Update contribution record
        (map-set contributions 
            {campaign-id: campaign-id, contributor: tx-sender}
            (+ current-contribution amount))
        (ok true)
    )
)

;; Claim campaign funds
(define-public (claim-funds (campaign-id uint))
    (let
        (
            (campaign (unwrap! (map-get? campaigns campaign-id) ERR-CAMPAIGN-NOT-FOUND))
        )
        ;; Verify claimer is campaign owner
        (asserts! (is-eq (get owner campaign) tx-sender) ERR-NOT-OWNER)
        ;; Verify campaign goal was reached
        (asserts! (>= (get raised campaign) (get goal campaign)) ERR-GOAL-NOT-REACHED)
        ;; Verify campaign has ended
        (asserts! (>= stacks-block-height (get end-block campaign)) ERR-CAMPAIGN-NOT-ENDED)
        ;; Verify funds haven't been claimed
        (asserts! (not (get claimed campaign)) ERR-ALREADY-CLAIMED)
        
        ;; Transfer funds to campaign owner
        (try! (as-contract (stx-transfer? (get raised campaign) tx-sender (get owner campaign))))
        
        ;; Update campaign as claimed
        (map-set campaigns campaign-id
            (merge campaign {claimed: true}))
        (ok true)
    )
)

;; Read-only functions

;; Get campaign details
(define-read-only (get-campaign (campaign-id uint))
    (map-get? campaigns campaign-id)
)

;; Get contribution amount
(define-read-only (get-contribution (campaign-id uint) (contributor principal))
    (map-get? contributions {campaign-id: campaign-id, contributor: contributor})
)

;; Get total number of campaigns
(define-read-only (get-total-campaigns)
    (var-get total-campaigns)
)