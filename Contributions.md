# Contribution Guidelines

**Note:** If these contribution guidelines are not followed your issue or PR might be closed, so
please read these instructions carefully.


### Bug Reports

- If you find a bug, please first report it using [Github issues].
    - First check if there is not already an issue for it; duplicated issues will be closed.


### Bug Fix

- If you'd like to submit a fix for a bug, please read the [How To](#how-to-contribute) for how to
  send a Pull Request.
- Indicate on the open issue that you are working on fixing the bug and the issue will be assigned
  to you.
- Write `Fixes #xxxx` in your PR text, where xxxx is the issue number (if there is one).
- Include a test that isolates the bug and verifies that it was fixed.


### New Features

- If you'd like to add a feature to the library that doesn't already exist, feel free to describe
  the feature in a new [GitHub issue].
    - You can also join us on [GitHub Discussion] to discuss some initials thoughts.
- If you'd like to implement the new feature, please wait for feedback from the project maintainers
  before spending too much time writing the code. In some cases, enhancements may not align well
  with the project future development direction.
- Implement the code for the new feature and please read the [How To](#how-to-contribute).



## How To Contribute


### Requirements

For a contribution to be accepted:

- Follow the [Style Guide] when writing the code;
- Format the code using `dart format .`;
- Documentation should always be updated or added (if applicable);
- Examples should always be updated or added (if applicable);
- Tests should always be updated or added (if applicable) -- check the [Test writing guide] for
  more details;
- The PR title should start with a [conventional commit] prefix (`feat:`, `fix:` etc).

If the contribution doesn't meet these criteria, a maintainer will discuss it with you on the issue
or PR. You can still continue to add more commits to the branch you have sent the Pull Request from
and it will be automatically reflected in the PR.


## Open an issue and fork the repository

- If it is a bigger change or a new feature, first of all
  [file a bug or feature report][GitHub issues], so that we can discuss what direction to follow.
- [Fork the project][fork guide] on GitHub.
- Clone the forked repository to your local development machine
  (e.g. `git clone git@github.com:<YOUR_GITHUB_USER>/flutter_calendar_view.git`).
## Maintainers

These instructions are for the maintainers of Workout Manager.


### Merging a pull request

When merging a pull request, make sure that the title of the merge commit has the correct
conventional commit tag and a descriptive title. This is extra important since sometimes the title
of the PR doesn't reflect what GitHub defaults to for the merge commit title (if the title has been
changed during the life time of the PR for example).

All the default text should be removed from the commit message and the PR description and the
instructions from the "Migration instruction" (if the PR is breaking) should be copied into the
commit message.



[GitHub issue]: https://github.com/SimformSolutionsPvtLtd/flutter_calendar_view/issues/new
[GitHub issues]: https://github.com/SimformSolutionsPvtLtd/flutter_calendar_view/issues/new
[GitHub Discussion]: https://github.com/SimformSolutionsPvtLtd/flutter_calendar_view/discussions
[style guide]: https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo
[test writing guide]: https://docs.flutter.dev/cookbook/testing/unit/introduction
[pubspec doc]: https://dart.dev/tools/pub/pubspec
[conventional commit]: https://www.conventionalcommits.org
[fork guide]: https://guides.github.com/activities/forking/#fork
[PRs]: https://github.com/SimformSolutionsPvtLtd/flutter_calendar_view/pulls
[gitmoji]: https://gist.github.com/parmentf/035de27d6ed1dce0b36a
