# Jenkins2

Jenkins2 gem is a command line interface and API client for Jenkins 2 CI Server.

# Features available
## Global
- Get Jenkins version
- Prepare for shutdown
- Cancel shutdown
- Wait for all nodes to be idle

## Node
- Set node temporarily offline / online
- Connect / Disconnect node
- Wait for node to become idle
- Get node definition as XML
- Update node definition from XML

## Job
- Run [parameterized] build

## Plugin
- Install a plugin by short name (i.e. ssh-credentials)
- Install a plugin by uploading a \*.jpi or \*.hpi file

## Credentials
- Create username with password credential ( Requires credentials plugin on Jenkins )
- Create ssh username with private key credential ( Requires ssh-credentials plugin on Jenkins )
- Create secret string credential ( Requires plain-credentials plugin on Jenkins )
- Create secret file credential ( Requires plain-credentials plugin on Jenkins )
- Get credential by id
- List credentials

# Installation

    gem install jenkins2

# Configuration

The gem does not require any configuration. However, if your Jenkins is secured you will have to
provide credentials with every CLI call.

    jenkins2 -s http://jenkins.example.com -u admin -k mysecretkey offline-node -n mynode

This can be avoided by creating a json configuration file like this

    {
      "server": "http://jenkins.example.com",
      "user": "admin",
      "key": "mysecretkey"
    }

By default Jenkins2 expects this file to be at ~/.jenkins2.json, but you can provide your own path
with --config-file switch. This way the above mentioned command will be much shorter.

    jenkins2 -c offline-node -n mynode # => -c switch tells Jenkins2 to read configuration file

# Usage

Either run it from command line:

    jenkins2 -s http://jenkins.example.com offline-node -n mynode
    jenkins2 --help # => for help and list of available commands
    jenkins2 --help <command> # => for help on particular command

Or use it in your ruby code:

    require 'jenkins2'
    jc = Jenkins2::Client.new( server: 'http://jenkins.example.com' )
    jc.version
    jc.offline_node( node: 'mynode' )

# License

MIT - see the accompanying [LICENSE](LICENSE) file for details.

# Changelog

To see what has changed in recent versions see the [CHANGELOG](CHANGELOG.md).
Jenkins2 gem follows the [Semantic Versioning Policy](http://guides.rubygems.org/patterns).

# Contributing

Additional commands and bugfixes are welcome! Please fork and submit a pull request on an
individual branch per change. The project follows GitHub Script
["Scripts To Rule Them All"] (https://github.com/github/scripts-to-rule-them-all) pattern.

## Bootstrap

After cloning the project, run:

    script/bootstrap

to download gem and other dependencies (currently tested only on ubuntu xenial).

## Tests

The project is expected to be heavily tested :) with unit and integratin tests. To run unit tests,
you will need to have some gems installed (see jenkins2.gemspec -> development\_dependencies or
run bootstrap script). To run unit tests run

    script/unit_test

Integration tests are run against a Jenkins server. Currently they require an lxd to setup it.
To run integration tests type

    script/integration_test

This will start Jenkins in lxd container, run the tests and then kill the container.

## Continuous Integration

If you would like to automate test runs the progect already has [Jenkinsfile](Jenkinsfile) for
quick and easy integration with Jenkins Pipelines. If you are using another CI server, just make
sure it runs

    script/cibuild

and then collects the data from the generated reports.
