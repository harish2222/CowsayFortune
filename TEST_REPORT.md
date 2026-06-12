# CowsayFortune Local Test Report

**Date:** 2026-06-12 19:07:31
**Result:** 31 passed, 0 failed, 31 total

| # | Test | Status | Detail |
|---|------|--------|--------|
| 1 | Import-Module CowsayFortune | PASS | CowsayFortune |
| 2 | Cowsay default text | PASS | ###############
  // Hello World //
  ###############
\   ^__^
          \  (... |
| 3 | Cowsay with CowFile tux | PASS | #################
  // Linux penguin //
  #################
\
     \
        ... |
| 4 | Cowsay with CowFile dragon | PASS | ##################
  // Fire breathing //
  ##################
\             ... |
| 5 | Cowsay with CowFile elephant | PASS | ############
  // Big ears //
  ############
\     /\  ___  /\
   \   // \/  ... |
| 6 | Cowsay with CowFile cat | PASS | ########
  // Meow //
  ########
\
    \                       _
            ... |
| 7 | Cowsay thought bubble | PASS | ################
  // Hmm thinking //
  ################
o   ^__^
          o... |
| 8 | Cowsay custom eyes | PASS | ###############
  // Custom eyes //
  ###############
\   ^__^
          \  (... |
| 9 | Cowsay custom tongue | PASS | #################
  // Custom tongue //
  #################
\   ^__^
        ... |
| 10 | Cowsay long message | PASS | #############################################################
  // This is a ... |
| 11 | Cowsay empty message | PASS | ####
  //  //
  ####
\   ^__^
          \  (oo)\_______
             (__)\   ... |
| 12 | Get-Fortune default | PASS | "If just one piece of mail gets lost, well, they'll just think they
forgot to... |
| 13 | Get-Fortune database fortunes | PASS | There was a young man who said "God,
I find it exceedingly odd,
	That the wil... |
| 14 | Get-Fortune second call | PASS | The modern child will answer you back before you've said anything.
		-- Laure... |
| 15 | Get-Fortune third call | PASS | Sorry, no fortune this time. |
| 16 | Get-Fortune fourth call | PASS | "Always try to do things in chronological order; it's less confusing
that way." |
| 17 | List all cows | PASS | 107 |
| 18 | Get cow default | PASS | $thoughts   ^__^
          $thoughts  ($eyes)\_______
             (__)\     ... |
| 19 | Get cow tux | PASS | $thoughts
     $thoughts
         .--.
        /$eye_$eye /
        /:_/ /
  ... |
| 20 | Get-CFConfig | PASS | default / lolcat=False |
| 21 | Set-CFConfig WhatIf | PASS | WhatIf OK |
| 22 | Set-CFConfig round-trip | PASS | Set to tux, got: tux |
| 23 | CowsayFortune default | PASS | #############################################################
  // Everybody ... |
| 24 | CowsayFortune with CowFile | PASS | ############################################################
  // The penalty... |
| 25 | CowsayFortune with Think | PASS | ################################################################
  // Economi... |
| 26 | CowsayFortune with Eyes | PASS | ###############################################################
  // Today's ... |
| 27 | Special chars in message | PASS | ############################
  // Test <hello> & "world" ! //
  #############... |
| 28 | Very long single word | PASS | ######################################
  // Supercalifragilisticexpialidociou... |
| 29 | Unicode in message | PASS | ###################
  // Hello from cafe //
  ###################
\   ^__^
  ... |
| 30 | Show-FortuneCow exists | PASS |  |
| 31 | Profile cow count check | PASS | Module has 107 cow files |

