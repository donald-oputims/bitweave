;; BitWeave - Bitcoin-Secured Decentralized Social Graph Protocol
;;
;; Summary:
;; BitWeave transforms social interactions into a trust-based ecosystem where 
;; every connection, endorsement, and contribution is secured by Bitcoin's 
;; immutable ledger through Stacks Layer 2. Users build verifiable reputation 
;; through stake-backed social actions, creating the first truly decentralized 
;; social credit system powered by sound money principles.
;;
;; Description:
;; In the age of centralized social platforms manipulating feeds and exploiting 
;; user data, BitWeave emerges as the antidote - a protocol where social value 
;; creation is transparent, stake-secured, and Bitcoin-final. Every profile, 
;; follow, post, and endorsement requires skin in the game through STX staking, 
;; ensuring authentic engagement while building a global reputation layer that 
;; transcends any single application. Users own their social graph, earn from 
;; their influence, and participate in a merit-based ecosystem where reputation 
;; is earned through provable stake and community validation. BitWeave doesn't 
;; just connect people - it creates accountable digital relationships backed 
;; by the world's most secure monetary network.
;;

;; Contract Constants
(define-constant CONTRACT_OWNER tx-sender)

;; Error Codes
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_PROFILE_EXISTS (err u101))
(define-constant ERR_PROFILE_NOT_FOUND (err u102))
(define-constant ERR_INSUFFICIENT_FUNDS (err u103))
(define-constant ERR_INVALID_AMOUNT (err u104))
(define-constant ERR_ALREADY_FOLLOWING (err u105))
(define-constant ERR_NOT_FOLLOWING (err u106))
(define-constant ERR_SELF_FOLLOW (err u107))
(define-constant ERR_ALREADY_ENDORSED (err u108))
(define-constant ERR_POST_NOT_FOUND (err u109))
(define-constant ERR_INVALID_POST_ID (err u110))

;; Stake Requirements (in microSTX)
(define-constant MIN_PROFILE_STAKE u1000000)    ;; 1 STX - Profile creation stake
(define-constant MIN_POST_BOOST u100000)        ;; 0.1 STX - Minimum post boost
(define-constant MIN_ENDORSEMENT_STAKE u500000) ;; 0.5 STX - Endorsement stake

;; Protocol State Variables

(define-data-var next-profile-id uint u1)
(define-data-var next-post-id uint u1)
(define-data-var protocol-fee-rate uint u100) ;; 1% = 100 basis points

;; Core Data Structures

;; User Profile Registry
(define-map profiles
  { profile-id: uint }
  {
    owner: principal,
    username: (string-ascii 50),
    bio: (string-utf8 280),
    avatar-url: (string-ascii 200),
    created-at: uint,
    staked-amount: uint,
    reputation-score: uint,
    follower-count: uint,
    following-count: uint,
    post-count: uint,
    total-endorsements: uint,
    is-active: bool
  }
)

;; Username Registry - Ensures Unique Handles
(define-map username-to-profile (string-ascii 50) uint)

;; Principal to Profile Mapping - Links Wallet to Identity  
(define-map principal-to-profile principal uint)

;; Social Graph Relationships
(define-map following
  { follower: uint, following: uint }
  { followed-at: uint, is-active: bool }
)

;; Content Repository
(define-map posts
  { post-id: uint }
  {
    author: uint,
    content: (string-utf8 500),
    created-at: uint,
    boosted-amount: uint,
    endorsement-count: uint,
    is-active: bool
  }
)

;; Post Endorsement System
(define-map post-endorsements
  { post-id: uint, endorser: uint }
  { endorsed-at: uint, stake-amount: uint }
)

;; Profile Endorsement Network
(define-map profile-endorsements
  { endorser: uint, endorsed: uint }
  { endorsed-at: uint, stake-amount: uint, message: (string-utf8 140) }
)

;; Reputation Staking Pools
(define-map profile-stakes
  { profile-id: uint, staker: principal }
  { amount: uint, staked-at: uint }
)

;; Content Monetization Stakes
(define-map post-boosts
  { post-id: uint, booster: principal }
  { amount: uint, boosted-at: uint }
)

;; Read-Only Functions - Data Queries

;; Retrieve Profile by ID
(define-read-only (get-profile (profile-id uint))
  (map-get? profiles { profile-id: profile-id })
)

;; Find Profile by Username
(define-read-only (get-profile-by-username (username (string-ascii 50)))
  (match (map-get? username-to-profile username)
    profile-id (get-profile profile-id)
    none
  )
)

;; Find Profile by Wallet Address
(define-read-only (get-profile-by-principal (user principal))
  (match (map-get? principal-to-profile user)
    profile-id (get-profile profile-id)
    none
  )
)

;; Check Username Availability
(define-read-only (is-username-available (username (string-ascii 50)))
  (is-none (map-get? username-to-profile username))
)

;; Verify Following Relationship
(define-read-only (is-following (follower-id uint) (following-id uint))
  (match (map-get? following { follower: follower-id, following: following-id })
    follow-data (get is-active follow-data)
    false
  )
)

;; Retrieve Post Data
(define-read-only (get-post (post-id uint))
  (map-get? posts { post-id: post-id })
)

;; Get Next Available Profile ID
(define-read-only (get-next-profile-id)
  (var-get next-profile-id)
)

;; Get Next Available Post ID
(define-read-only (get-next-post-id)
  (var-get next-post-id)
)

;; Calculate Dynamic Reputation Score
(define-read-only (calculate-reputation-score (profile-id uint))
  (match (get-profile profile-id)
    profile-data
    (let
      (
        (base-score (get staked-amount profile-data))
        (follower-bonus (* (get follower-count profile-data) u1000))
        (endorsement-bonus (* (get total-endorsements profile-data) u2000))
        (post-bonus (* (get post-count profile-data) u500))
      )
      (+ base-score (+ follower-bonus (+ endorsement-bonus post-bonus)))
    )
    u0
  )
)

;; Public Functions - Core Protocol Actions

;; Bootstrap User Identity with Stake Commitment
(define-public (create-profile 
  (username (string-ascii 50))
  (bio (string-utf8 280))
  (avatar-url (string-ascii 200))
)
  (let
    (
      (profile-id (var-get next-profile-id))
      (current-block stacks-block-height)
    )
    ;; Prevent duplicate profile creation
    (asserts! (is-none (map-get? principal-to-profile tx-sender)) ERR_PROFILE_EXISTS)
    
    ;; Ensure username uniqueness
    (asserts! (is-username-available username) ERR_PROFILE_EXISTS)
    
    ;; Verify minimum stake requirement
    (asserts! (>= (stx-get-balance tx-sender) MIN_PROFILE_STAKE) ERR_INSUFFICIENT_FUNDS)
    
    ;; Lock initial reputation stake
    (try! (stx-transfer? MIN_PROFILE_STAKE tx-sender (as-contract tx-sender)))
    
    ;; Initialize profile with stake-backed reputation
    (map-set profiles
      { profile-id: profile-id }
      {
        owner: tx-sender,
        username: username,
        bio: bio,
        avatar-url: avatar-url,
        created-at: current-block,
        staked-amount: MIN_PROFILE_STAKE,
        reputation-score: MIN_PROFILE_STAKE,
        follower-count: u0,
        following-count: u0,
        post-count: u0,
        total-endorsements: u0,
        is-active: true
      }
    )
    
    ;; Establish identity mappings
    (map-set username-to-profile username profile-id)
    (map-set principal-to-profile tx-sender profile-id)
    (map-set profile-stakes 
      { profile-id: profile-id, staker: tx-sender }
      { amount: MIN_PROFILE_STAKE, staked-at: current-block }
    )
    
    ;; Increment global profile counter
    (var-set next-profile-id (+ profile-id u1))
    
    (ok profile-id)
  )
)

;; Establish Social Connection with Accountability
(define-public (follow-user (following-id uint))
  (let
    (
      (follower-profile-result (map-get? principal-to-profile tx-sender))
      (current-block stacks-block-height)
    )
    ;; Resolve follower identity
    (match follower-profile-result
      follower-id
      (begin
        ;; Prevent self-following
        (asserts! (not (is-eq follower-id following-id)) ERR_SELF_FOLLOW)
        
        ;; Verify target profile exists
        (asserts! (is-some (get-profile following-id)) ERR_PROFILE_NOT_FOUND)
        
        ;; Prevent duplicate follows
        (asserts! (not (is-following follower-id following-id)) ERR_ALREADY_FOLLOWING)
        
        ;; Record social connection
        (map-set following
          { follower: follower-id, following: following-id }
          { followed-at: current-block, is-active: true }
        )
        
        ;; Update follower metrics for followed user
        (match (get-profile following-id)
          following-profile
          (map-set profiles
            { profile-id: following-id }
            (merge following-profile { follower-count: (+ (get follower-count following-profile) u1) })
          )
          false
        )
        
        ;; Update following metrics for follower
        (match (get-profile follower-id)
          follower-profile
          (map-set profiles
            { profile-id: follower-id }
            (merge follower-profile { following-count: (+ (get following-count follower-profile) u1) })
          )
          false
        )
        
        (ok true)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Dissolve Social Connection
(define-public (unfollow-user (following-id uint))
  (let
    (
      (follower-profile-result (map-get? principal-to-profile tx-sender))
    )
    ;; Resolve follower identity
    (match follower-profile-result
      follower-id
      (begin
        ;; Verify existing follow relationship
        (asserts! (is-following follower-id following-id) ERR_NOT_FOLLOWING)
        
        ;; Remove social connection
        (map-delete following { follower: follower-id, following: following-id })
        
        ;; Decrease follower count for unfollowed user
        (match (get-profile following-id)
          following-profile
          (map-set profiles
            { profile-id: following-id }
            (merge following-profile { follower-count: (- (get follower-count following-profile) u1) })
          )
          false
        )
        
        ;; Decrease following count for unfollower
        (match (get-profile follower-id)
          follower-profile
          (map-set profiles
            { profile-id: follower-id }
            (merge follower-profile { following-count: (- (get following-count follower-profile) u1) })
          )
          false
        )
        
        (ok true)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Publish Content to Social Graph
(define-public (create-post (content (string-utf8 500)))
  (let
    (
      (author-profile-result (map-get? principal-to-profile tx-sender))
      (post-id (var-get next-post-id))
      (current-block stacks-block-height)
    )
    ;; Resolve author identity
    (match author-profile-result
      author-id
      (begin
        ;; Create immutable content record
        (map-set posts
          { post-id: post-id }
          {
            author: author-id,
            content: content,
            created-at: current-block,
            boosted-amount: u0,
            endorsement-count: u0,
            is-active: true
          }
        )
        
        ;; Update author's content metrics
        (match (get-profile author-id)
          author-profile
          (map-set profiles
            { profile-id: author-id }
            (merge author-profile { post-count: (+ (get post-count author-profile) u1) })
          )
          false
        )
        
        ;; Increment global post counter
        (var-set next-post-id (+ post-id u1))
        
        (ok post-id)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Monetize Content through Stake-Based Boosting
(define-public (boost-post (post-id uint) (amount uint))
  (let
    (
      (current-block stacks-block-height)
    )
    ;; Verify minimum boost threshold
    (asserts! (>= amount MIN_POST_BOOST) ERR_INVALID_AMOUNT)
    
    ;; Ensure post exists
    (asserts! (is-some (get-post post-id)) ERR_POST_NOT_FOUND)
    
    ;; Verify sufficient balance
    (asserts! (>= (stx-get-balance tx-sender) amount) ERR_INSUFFICIENT_FUNDS)
    
    ;; Commit boost stake to protocol
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    
    ;; Record boost commitment
    (map-set post-boosts
      { post-id: post-id, booster: tx-sender }
      { amount: amount, boosted-at: current-block }
    )
    
    ;; Update post's total boost value
    (match (get-post post-id)
      post-data
      (map-set posts
        { post-id: post-id }
        (merge post-data { boosted-amount: (+ (get boosted-amount post-data) amount) })
      )
      false
    )
    
    (ok true)
  )
)

;; Stake-Based Content Endorsement System
(define-public (endorse-post (post-id uint) (stake-amount uint))
  (let
    (
      (endorser-profile-result (map-get? principal-to-profile tx-sender))
      (current-block stacks-block-height)
    )
    ;; Verify minimum endorsement stake
    (asserts! (>= stake-amount MIN_ENDORSEMENT_STAKE) ERR_INVALID_AMOUNT)
    
    ;; Ensure target post exists
    (asserts! (is-some (get-post post-id)) ERR_POST_NOT_FOUND)
    
    ;; Resolve endorser identity
    (match endorser-profile-result
      endorser-id
      (begin
        ;; Prevent duplicate endorsements
        (asserts! (is-none (map-get? post-endorsements { post-id: post-id, endorser: endorser-id })) ERR_ALREADY_ENDORSED)
        
        ;; Verify sufficient stake balance
        (asserts! (>= (stx-get-balance tx-sender) stake-amount) ERR_INSUFFICIENT_FUNDS)
        
        ;; Lock endorsement stake
        (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))
        
        ;; Record stake-backed endorsement
        (map-set post-endorsements
          { post-id: post-id, endorser: endorser-id }
          { endorsed-at: current-block, stake-amount: stake-amount }
        )
        
        ;; Increment post endorsement counter
        (match (get-post post-id)
          post-data
          (map-set posts
            { post-id: post-id }
            (merge post-data { endorsement-count: (+ (get endorsement-count post-data) u1) })
          )
          false
        )
        
        ;; Boost author's reputation through endorsement
        (match (get-post post-id)
          post-data
          (match (get-profile (get author post-data))
            author-profile
            (map-set profiles
              { profile-id: (get author post-data) }
              (merge author-profile { total-endorsements: (+ (get total-endorsements author-profile) u1) })
            )
            false
          )
          false
        )
        
        (ok true)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Profile-to-Profile Reputation Endorsement
(define-public (endorse-profile (endorsed-id uint) (stake-amount uint) (message (string-utf8 140)))
  (let
    (
      (endorser-profile-result (map-get? principal-to-profile tx-sender))
      (current-block stacks-block-height)
    )
    ;; Verify minimum endorsement stake
    (asserts! (>= stake-amount MIN_ENDORSEMENT_STAKE) ERR_INVALID_AMOUNT)
    
    ;; Ensure target profile exists
    (asserts! (is-some (get-profile endorsed-id)) ERR_PROFILE_NOT_FOUND)
    
    ;; Resolve endorser identity
    (match endorser-profile-result
      endorser-id
      (begin
        ;; Prevent self-endorsement
        (asserts! (not (is-eq endorser-id endorsed-id)) ERR_UNAUTHORIZED)
        
        ;; Prevent duplicate profile endorsements
        (asserts! (is-none (map-get? profile-endorsements { endorser: endorser-id, endorsed: endorsed-id })) ERR_ALREADY_ENDORSED)
        
        ;; Verify sufficient stake balance
        (asserts! (>= (stx-get-balance tx-sender) stake-amount) ERR_INSUFFICIENT_FUNDS)
        
        ;; Lock endorsement stake
        (try! (stx-transfer? stake-amount tx-sender (as-contract tx-sender)))
        
        ;; Record profile endorsement with message
        (map-set profile-endorsements
          { endorser: endorser-id, endorsed: endorsed-id }
          { endorsed-at: current-block, stake-amount: stake-amount, message: message }
        )
        
        ;; Boost endorsed profile's reputation metrics
        (match (get-profile endorsed-id)
          endorsed-profile
          (map-set profiles
            { profile-id: endorsed-id }
            (merge endorsed-profile { total-endorsements: (+ (get total-endorsements endorsed-profile) u1) })
          )
          false
        )
        
        (ok true)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Update Profile Metadata
(define-public (update-profile (bio (string-utf8 280)) (avatar-url (string-ascii 200)))
  (let
    (
      (profile-result (map-get? principal-to-profile tx-sender))
    )
    (match profile-result
      profile-id
      (match (get-profile profile-id)
        profile-data
        (begin
          ;; Update mutable profile fields
          (map-set profiles
            { profile-id: profile-id }
            (merge profile-data { bio: bio, avatar-url: avatar-url })
          )
          (ok true)
        )
        ERR_PROFILE_NOT_FOUND
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Amplify Reputation through Additional Staking
(define-public (stake-for-reputation (amount uint))
  (let
    (
      (profile-result (map-get? principal-to-profile tx-sender))
      (current-block stacks-block-height)
    )
    ;; Verify minimum stake increment
    (asserts! (>= amount MIN_POST_BOOST) ERR_INVALID_AMOUNT)
    
    ;; Verify sufficient balance
    (asserts! (>= (stx-get-balance tx-sender) amount) ERR_INSUFFICIENT_FUNDS)
    
    (match profile-result
      profile-id
      (begin
        ;; Lock additional reputation stake
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        
        ;; Increase profile stake amount
        (match (get-profile profile-id)
          profile-data
          (map-set profiles
            { profile-id: profile-id }
            (merge profile-data { staked-amount: (+ (get staked-amount profile-data) amount) })
          )
          false
        )
        
        ;; Record additional stake commitment
        (map-set profile-stakes
          { profile-id: profile-id, staker: tx-sender }
          { amount: amount, staked-at: current-block }
        )
        
        (ok true)
      )
      ERR_PROFILE_NOT_FOUND
    )
  )
)

;; Administrative Functions

;; Protocol Fee Management (Owner Only)
(define-public (set-protocol-fee-rate (new-rate uint))
  (begin
    ;; Restrict to contract owner
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    ;; Cap maximum fee at 10%
    (asserts! (<= new-rate u1000) ERR_INVALID_AMOUNT)
    ;; Update protocol fee rate
    (var-set protocol-fee-rate new-rate)
    (ok true)
  )
)