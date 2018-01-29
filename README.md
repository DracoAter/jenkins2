# Jenkins2

Jenkins2 gem is a command line interface and API client for Jenkins 2 CI Server. This gem has been
tested with Jenkins 2.73.2 LTS.

# Features available

## Global

- Jenkins version
- Quiet Down Jenkins
- Cancel Quiet Down Jenkins
- Immediate and Safe Restart

## Users / People

- Get authenticated user (who-am-i)

## Node / Slave / Computer

- Create slave from config.xml
- Delete slave
- Toggle slave offline / online
- Launch slave agent
- Disconnect slave
- Get slave's config.xml
- Get slave state in json
- Get all slaves state in json

## Plugins

- List installed plugins
- Install a plugin either from a file, an URL or from update center (by short name like
  thinBackup)
- Show plugin info
- Uninstall a plugin

## Credentials

- Create username with password credentials (Requires credentials plugin on Jenkins)
- Create ssh username with private key credentials (Requires ssh-credentials plugin on Jenkins)
- Create secret string credentials (Requires plain-credentials plugin on Jenkins)
- Create secret file credentials (Requires plain-credentials plugin on Jenkins)
- Get credentials by id
- Delete credentials
- List credentials in particular store and domain

## Views

- List views
- Get view configuraiton xml
- Update view configuraiton xml
- Create View
- Delete View

## Jobs

- List jobs
- Create job from config.xml or by copying another one
- Set (Update) job configuration
- Get job configuration
- Delete job
- Enable, disable job
- Run build (with parameters, if required)

# Installation

    gem install jenkins2

# Usage

Either run it from command line:

    jenkins2 -s http://jenkins.example.com offline-node -n mynode
    jenkins2 --help # => for help and list of available commands
    jenkins2 --help <command> # => for help on particular command

Or use it in your ruby code:

    require 'jenkins2'
    jc = Jenkins2.connect( server: 'http://jenkins.example.com', user: 'admin',
      key:  'mysecretkey' )
    jc.version
    jc.computer( 'mynode' ).toggle_offline( 'Some reason, why' )

# Configuration

The gem does not require any configuration. However, if your Jenkins is secured you will have to
provide credentials with every CLI call.

    jenkins2 -s http://jenkins.example.com -u admin -k mysecretkey offline-node -n mynode

This can be avoided by creating a json configuration file like this

    {
      "server": "http://jenkins.example.com",
      "user": "admin",
      "key": "mysecretkey",
      "verbose": 3,
      "log": "/var/log/jenkins2.log"
    }

and putting global options there. By default Jenkins2 expects this file to be at ~/.jenkins2.json,
but you can provide your own path with --config-file switch. This way the above mentioned command
will be much shorter.

    jenkins2 -c offline-node -n mynode # => -c switch tells Jenkins2 to read configuration file

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
