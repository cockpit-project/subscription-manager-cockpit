# Hacking on subscription-manager-cockpit

The commands here assume you're in the top level of the subscription-manager-cockpit
git repository checkout.

## Running out of git checkout

For development, you usually want to run your module straight out of the git
tree. To do that, run `make devel-install`, which links your checkout to the
location were cockpit-bridge looks for packages. If you prefer to do
this manually:

```
mkdir -p ~/.local/share/cockpit
ln -s `pwd`/dist ~/.local/share/cockpit/subscription-manager
```

After changing the code and running `make` again, reload the Cockpit page in
your browser.

You can also use
[watch mode](https://esbuild.github.io/api/#watch) to
automatically update the webpack on every code change with

    $ ./build.js -w

or

    $ make watch

When developing against a virtual machine, webpack can also automatically upload
the code changes by setting the `RSYNC` environment variable to
the remote hostname.

    $ RSYNC=c make watch

To "uninstall" the locally installed version, run `make devel-uninstall`, or
remove manually the symlink:

    rm ~/.local/share/cockpit/subscription-manager

# Running eslint

subscription-manager-cockpit uses [ESLint](https://eslint.org/) to automatically check
JavaScript code style in `.js` and `.jsx` files.

The linter is executed within every build as a webpack preloader.

For developer convenience, the ESLint can be started explicitly by:

    $ npm run eslint

Violations of some rules can be fixed automatically by:

    $ npm run eslint:fix

Rules configuration can be found in the `.eslintrc.json` file.

# Running tests locally

Run `make check` to build an RPM, install it into a standard Cockpit test VM
(centos-9-stream by default), and run the test/check-application integration test on
it. This uses Cockpit's Chrome DevTools Protocol based browser tests, through a
Python API abstraction. Note that this API is not guaranteed to be stable, so
if you run into failures and don't want to adjust tests, consider checking out
Cockpit's test/common from a tag instead of main (see the `test/common`
target in `Makefile`).

After the test VM is prepared, you can manually run the test without rebuilding
the VM, possibly with extra options for tracing and halting on test failures
(for interactive debugging):

    TEST_OS=centos-9-stream test/check-subscriptions -tvs

It is possible to setup the test environment without running the tests:

    TEST_OS=centos-9-stream make prepare-check

You can also run the test against a different Cockpit image, for example:

    TEST_OS=fedora-36 make check

In addition to `TEST_OS`, `Makefile` supports also `TEST_SCENARIO` to specify
which branch of subscription-manager.git to test. This is only possible
for local testing because CI is not able to download RHEL packages
during image-customize step. If not specified, the default is the distribution
packaged version. The `TEST_OS=devel` means that the distribution packaged
subscription-manager is tested but also collects code coverage and runs pixel tests.
For compatibility, setting `TEST_OS=system` also runs tests against
the distribution packaged version.

Please see [Cockpit's test documentation](https://github.com/cockpit-project/cockpit/blob/main/test/README.md)
for details how to run against existing VMs, interactive browser window,
interacting with the test VM, and more.

# Updating `node_modules`

During a normal build from a git checkout, the `node_modules` will be
automatically unpacked from a cache kept in a separate git repository.  You can
force the unpack to occur using the `tools/node-modules checkout` command, but
this shouldn't be necessary.  In the event that you need to modify
`package.json` (to install a new module, for example) then you'll need to run
`tools/node-modules install` to create a new cache from the result of running
`npm install` on your new `package.json`.

Your locally rebuilt changes to `node_modules` won't be used by others.  A new
version will be created by a GitHub workflow when you open your pull request.

The `tools/node-modules` script inspects the `GITHUB_BASE` environment variable
to determine the correct repository to use when fetching and pushing.  It will
strip the repository name (leaving the project- or username) and use the
`node-cache.git` repository in that namespace.  If `GITHUB_BASE` is unset, it
will default to `cockpit-project/node-cache.git`.

A local cache is maintained in `~/.cache/cockpit-dev`.

