#!/bin/sh

## first test : develop is ahead master, hotfix applied to master, then rebase develop on master
# First lets make develop ahead master
git checkout develop
echo "develop world" > test2
git add .
git commit -m 'This commit makes develop ahead master' --no-edit
git push origin develop

# Now create hotfix
git checkout master
git checkout -b hotfix/my-hotfix
echo "bye world" > test
git add .
git commit -m 'This is the commit from my hotfix -example 1' --no-edit
git push origin hotfix/my-hotfix

# Merge hotfix in master and delete hotfix
git checkout master
git merge hotfix/my-hotfix --no-edit
git branch -D hotfix/my-hotfix
git push origin --delete hotfix/my-hotfix

# Retrieve hotfix on develop by rebasing
git checkout develop
git rebase master # No problem here. Conflict will happen if and only if the same lines are modified, just like for any other rebase
git push origin develop --force-with-lease # Force needed here

# What happens if we merge develop into master ?
git checkout master
git merge develop --no-edit # No conflict here, commit is the same
git push origin master

## Now another thing : lets merge hotfix in master AND develop
# Now create hotfix
git checkout -b hotfix/my-hotfix
echo "hallo munde" > test
git add .
git commit -m 'This is the commit from my hotfix - example 2' --no-edit
git push origin hotfix/my-hotfix

# Merge hotfix into master
git checkout master
git merge hotfix/my-hotfix --no-edit # hotfix is now on master
git push origin master

# Rebase & merge hotfix in develop
git checkout hotfix/my-hotfix
git rebase develop
git push origin hotfix/my-hotfix
git checkout develop
git merge hotfix/my-hotfix --no-edit # hotfix is also now on develop
git push origin develop

# Delete hotfix
git checkout master
git branch -D hotfix/my-hotfix
git push origin --delete hotfix/my-hotfix

# What happens if we merge develop into master ?
git merge develop --no-edit # No conflict here, commit is the same
git push origin master

## One last thing : cherry-pick
# We add a commit directly on master
echo "hola que tal" > test
git add .
git commit -m 'This commit will be cherry picked' --no-edit
commit="$(git rev-parse HEAD)"
git push origin master

# Now we cherry-pick it on develop
git checkout develop
git cherry-pick $commit
git push origin develop

# Lets now rebase
git rebase master
git push origin develop --force-with-lease # Needed here, yup

# What happens if we merge develop into master ?
git checkout master
git merge develop --no-edit # No conflict here again, commit is the same
git push origin master
