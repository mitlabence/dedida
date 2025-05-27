# dedida

Der, die, oder das? Practice German. A simple application for Android and iOS to learn the genders 
of words in specific datasets (currently A1, A2, B1) and track user record for optimized learning 
and repetition.

# Development structure
* main branch – The stable production-ready branch. Merging here should only happen once features are fully developed and tested.
* dev branch – The active development branch where new features are integrated.
  * Feature branches – Created off dev for targeted modifications. Once completed, merge them back into dev via pull requests.
  * Manual testing is encouraged at this point. Run relevant tests on-site before attempting to create pull request into dev.
* test branch (optional, tbd if useful) - dev branch should be merged here before going to main. Things to do here:
  * QA testing – Run automated tests before merging dev into main.
  * Release candidate staging – Keep a preview build before making an official release.
  * Do a closed testing phase before accepting it as an app update (if possible in google store)

# Work on a feature
To begin working on feature x, make a branch dev-x (e.g. dev/123-dark-mode from issue #123 about dark mode) from dev. Assuming user has privilege to create branches in this repository:
1. in LOCAL repository, switch to dev: `git checkout dev`
2. synch branch dev `git pull origin dev`
3. create the feature branch `git checkout -b dev/123-dark-mode`
4. push the branch to the remote repository `git push origin dev/123-dark-mode`
