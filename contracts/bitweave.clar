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