```markdown
# Contribution Guidelines

**Note:** If these contribution guidelines are not followed your issue or PR might be closed, so
please read these instructions carefully.

## Contribution Types

### Bug Reports

- If you find a bug, please first report it using [GitHub issues](https://github.com/wger-project/flutter/issues).
    - First check if there is not already an issue for it; duplicated issues will be closed.

### Bug Fix

- If you'd like to submit a fix for a bug, please read the [How To Contribute](#how-to-contribute) section for instructions on how to send a Pull Request.
- Indicate on the open issue that you are working on fixing the bug and the issue will be assigned to you.
- Write `Fixes #xxxx` in your PR text, where xxxx is the issue number (if there is one).
- Include a test that isolates the bug and verifies that it was fixed.

### New Features

- If you'd like to add a feature to the app that doesn't already exist, feel free to describe the feature in a new [GitHub issue](https://github.com/wger-project/flutter/issues).
    - You can also join us in the [Discussions](https://github.com/wger-project/flutter/discussions) section to discuss initial thoughts.
- If you'd like to implement the new feature, please wait for feedback from the project maintainers before spending too much time writing the code. In some cases, enhancements may not align well with the project's future development direction.
- Implement the code for the new feature and please read the [How To Contribute](#how-to-contribute).

### Documentation & Miscellaneous

- If you have suggestions for improvements to the documentation, tutorial, examples, or anything else, we would love to hear about it.
- As always, first file a [GitHub issue](https://github.com/wger-project/flutter/issues).
- Implement the changes to the documentation, and please read the [How To Contribute](#how-to-contribute).

## How To Contribute

### Requirements

For a contribution to be accepted:

- Follow the [Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo) when writing the code.
- Format the code using `dart format .`.
- Documentation should always be updated or added (if applicable).
- Examples should always be updated or added (if applicable).
- Tests should always be updated or added (if applicable) -- check the [Test Writing Guide](https://docs.flutter.dev/cookbook/testing/unit/introduction) for more details.
- The PR title should start with a [conventional commit](https://www.conventionalcommits.org) prefix (`feat:`, `fix:` etc).

If the contribution doesn't meet these criteria, a maintainer will discuss it with you on the issue or PR. You can still continue to add more commits to the branch you have sent the Pull Request from and it will be automatically reflected in the PR.

### Open an Issue and Fork the Repository

- If it is a bigger change or a new feature, first of all [file a bug or feature report](https://github.com/wger-project/flutter/issues), so that we can discuss what direction to follow.
- [Fork the project](https://guides.github.com/activities/forking/#fork) on GitHub.
- Clone the forked repository to your local development machine (e.g. `git clone git@github.com:<YOUR_GITHUB_USER>/flutter.git`).

### Performing Changes

- Create a new local branch from `master` (e.g. `git checkout -b my-new-feature`).
- Make your changes (try to split them up with one PR per feature/fix).
- When committing your changes, make sure that each commit message is clear (e.g. `git commit -m 'Fixes duplicate key found in example'`).
- Push your new branch to your own fork into the same remote branch (e.g. `git push origin my-username.my-new-feature`, replace `origin` if you use another remote).


### Open a Pull Request

Go to the [pull request page](https://github.com/wger-project/flutter/pulls) and at the top of the page, it will ask you if you want to open a pull request from your newly created branch.

The title of the pull request should start with a [conventional commit](https://www.conventionalcommits.org) type. Use [gitmoji](https://gist.github.com/parmentf/035de27d6ed1dce0b36a) for commit messages.

Allowed types are:

- `fix:` -- patches a bug and is not a new feature;
- `feat:` -- introduces a new feature;
- `docs:` -- updates or adds documentation or examples;
- `test:` -- updates or adds tests;
- `refactor:` -- refactors code but doesn't introduce any changes or additions to the public API;
- `perf:` -- code change that improves performance;
- `build:` -- code change that affects the build system or external dependencies;
- `ci:` -- changes to the CI configuration files and scripts;
- `chore:` -- other changes that don't modify source or test files;
- `revert:` -- reverts a previous commit.

Examples of PR titles:

- feat: ✨ Added smooth transition to tooltip
- fix: 🐛 Fixes duplicate key found in example
- docs: 💡 ToolTip BorderRadius setting support doc update
- docs: 📚 Improve the ToolTipWidget README
- test: 🚨 Add unit test for `Event Controller`
- refactor: 🔨 Optimize the structure of the example

## Code of Conduct

Please note that this project is released with a Contributor Code of Conduct. By participating in this project, you agree to abide by its terms. You can read the Code of Conduct [here](CODE_OF_CONDUCT.md).

## Reporting Issues

If you find a bug or have a feature request, please create an issue on GitHub. Provide as much detail as possible to help us understand and address your issue promptly.

## Community

Join our community discussions, ask questions, and share your feedback in the [Discussions](https://github.com/wger-project/flutter/discussions) section of this repository.

---

Thank you for contributing to the wger Flutter App! We appreciate your support and efforts to improve the project.
```

